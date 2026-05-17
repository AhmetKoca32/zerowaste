import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/leaderboard_doc.dart';
import '../models/post_entry.dart';

/// Repository for points/posts operations against Firestore.
/// 
/// Firebase Spark kotasi: her post submit 1 write, pointsPage acilisi ~2 read,
/// admin onaylama ~1 read + 2 write. Gunluk ~200 read ile kotanin cok altinda.
class PointsRepository {
  PointsRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _postsCollection = 'posts';
  static const String _leaderboardDoc = 'leaderboard';
  static const String _leaderboardId = 'current';

  /// Submit a new post (1 Firestore write).
  Future<void> submitPost(PostEntry post) async {
    final docRef = _firestore.collection(_postsCollection).doc();
    await docRef.set(post.copyWith(id: docRef.id).toFirestore());
  }

  /// Get posts for a specific nickname (1 Firestore query).
  Future<List<PostEntry>> getPostsByNickname(String nickname) async {
    final snapshot = await _firestore
        .collection(_postsCollection)
        .where('nickname', isEqualTo: nickname)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => PostEntry.fromFirestore(doc)).toList();
  }

  /// Get all pending posts for admin review (1 Firestore query).
  Future<List<PostEntry>> getPendingPosts() async {
    final snapshot = await _firestore
        .collection(_postsCollection)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => PostEntry.fromFirestore(doc)).toList();
  }

  /// Approve a post and update leaderboard (2 writes: post + leaderboard doc).
  Future<void> approvePost(String postId, {String? adminNote}) async {
    await _firestore.collection(_postsCollection).doc(postId).update({
      'status': 'approved',
      'adminNote': ?adminNote,
    });
    await _recalculateLeaderboard();
  }

  /// Reject a post (1 write).
  Future<void> rejectPost(String postId, {String? adminNote}) async {
    await _firestore.collection(_postsCollection).doc(postId).update({
      'status': 'rejected',
      'adminNote': ?adminNote,
    });
  }

  /// Get leaderboard top N (1 Firestore read).
  Future<List<LeaderboardEntry>> getLeaderboard({int limit = 10}) async {
    try {
      final doc = await _firestore
          .collection(_leaderboardDoc)
          .doc(_leaderboardId)
          .get();
      if (!doc.exists) return [];
      final leaderboard = LeaderboardDoc.fromFirestore(doc);
      return leaderboard.entries.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  /// Recalculate leaderboard from approved posts (1 query + 1 write).
  Future<void> _recalculateLeaderboard() async {
    try {
      final snapshot = await _firestore
          .collection(_postsCollection)
          .where('status', isEqualTo: 'approved')
          .where('leaderboardOptIn', isEqualTo: true)
          .get();

      final Map<String, int> pointsMap = {};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final nick = data['nickname'] as String? ?? 'Anonim';
        final pts = data['points'] as int? ?? 0;
        pointsMap[nick] = (pointsMap[nick] ?? 0) + pts;
      }

      final entries = pointsMap.entries
          .map((e) => LeaderboardEntry(nickname: e.key, points: e.value))
          .toList();
      entries.sort((a, b) => b.points.compareTo(a.points));

      await _firestore
          .collection(_leaderboardDoc)
          .doc(_leaderboardId)
          .set(
            LeaderboardDoc(
              entries: entries,
              lastUpdated: DateTime.now(),
            ).toFirestore(),
          );
    } catch (e) {
      // Leaderboard recalculation failed silently (non-critical)
    }
  }
}
