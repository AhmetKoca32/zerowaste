import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

/// Ensures a Firebase Auth session exists for Storage uploads.
/// Uses anonymous sign-in so nickname-only users can upload post photos.
class AnonymousAuthService {
  AnonymousAuthService({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  static const _signInTimeout = Duration(seconds: 20);

  /// Signs in anonymously if no user is signed in. Safe to call repeatedly.
  Future<User> ensureSignedIn() async {
    final current = _auth.currentUser;
    if (current != null) return current;

    final credential = await _auth.signInAnonymously().timeout(
      _signInTimeout,
      onTimeout: () => throw TimeoutException('Anonymous sign-in timed out.'),
    );
    final user = credential.user;
    if (user == null) {
      throw StateError('Anonymous sign-in returned no user.');
    }
    return user;
  }
}
