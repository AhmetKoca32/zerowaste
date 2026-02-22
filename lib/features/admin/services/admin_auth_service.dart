import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service for admin authentication and authorization.
class AdminAuthService {
  AdminAuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  static const String _adminsCollection = 'admins';

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Giriş başarısız');
      }

      final isAdmin = await _isAdmin(credential.user!.uid);
      if (!isAdmin) {
        await signOut();
        throw Exception('Bu kullanıcı admin değil');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<bool> isCurrentUserAdmin() async {
    final user = currentUser;
    if (user == null) return false;
    return _isAdmin(user.uid);
  }

  Future<bool> _isAdmin(String userId) async {
    try {
      final doc = await _firestore
          .collection(_adminsCollection)
          .doc(userId)
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Bu email ile kayıtlı kullanıcı bulunamadı';
      case 'wrong-password':
        return 'Şifre yanlış';
      case 'invalid-email':
        return 'Geçersiz email adresi';
      case 'user-disabled':
        return 'Bu kullanıcı devre dışı bırakılmış';
      case 'too-many-requests':
        return 'Çok fazla deneme. Lütfen daha sonra tekrar deneyin';
      case 'operation-not-allowed':
        return 'Bu işlem izin verilmemiş';
      default:
        return 'Giriş yapılırken bir hata oluştu: ${e.message}';
    }
  }
}
