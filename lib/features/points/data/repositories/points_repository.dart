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
  Future<void> approvePost(String postId, {String? adminNote, String? adminNoteEn}) async {
    final updateData = <String, dynamic>{
      'status': 'approved',
      'adminNote': adminNote,
    };
    if (adminNoteEn != null) updateData['adminNoteEn'] = adminNoteEn;
    await _firestore.collection(_postsCollection).doc(postId).update(updateData);
    await _recalculateLeaderboard();
  }

  /// Reject a post (1 write).
  Future<void> rejectPost(String postId, {String? adminNote, String? adminNoteEn}) async {
    final updateData = <String, dynamic>{
      'status': 'rejected',
      'adminNote': adminNote,
    };
    if (adminNoteEn != null) updateData['adminNoteEn'] = adminNoteEn;
    await _firestore.collection(_postsCollection).doc(postId).update(updateData);
  }

  /// Return all unique nicknames and their total approved + bonus points
  /// from the posts collection. Used by the admin panel to list users.
  Future<List<_UserSummary>> getAllUsers() async {
    final snapshot = await _firestore
        .collection(_postsCollection)
        .where('status', isEqualTo: 'approved')
        .get();

    final Map<String, _UserSummary> userMap = {};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final nick = data['nickname'] as String? ?? 'Anonim';
      final pts = data['points'] as int? ?? 0;
      final bonus = data['isAdminBonus'] as bool? ?? false;
      final penalty = data['isAdminPenalty'] as bool? ?? false;

      if (userMap.containsKey(nick)) {
        final existing = userMap[nick]!;
        userMap[nick] = _UserSummary(
          nickname: nick,
          totalPoints: existing.totalPoints + pts,
          postCount: existing.postCount + (penalty ? 0 : 1),
          bonusCount: existing.bonusCount + (bonus ? 1 : 0),
          leaderboardOptIn: existing.leaderboardOptIn,
        );
      } else {
        userMap[nick] = _UserSummary(
          nickname: nick,
          totalPoints: pts,
          postCount: penalty ? 0 : 1,
          bonusCount: bonus ? 1 : 0,
          leaderboardOptIn: data['leaderboardOptIn'] as bool? ?? false,
        );
      }
    }

    final users = userMap.values.toList();
    users.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
    return users;
  }

  /// Deduct points from a user as an admin penalty. Creates an approved
  /// post with negative points so it automatically feeds into the leaderboard.
  Future<void> deductPoints({
    required String nickname,
    required int points,
    String? reason,
    String? reasonEn,
  }) async {
    final docRef = _firestore.collection(_postsCollection).doc();
    await docRef.set({
      'id': docRef.id,
      'nickname': nickname,
      'category': 'Puan Kesintisi',
      'points': -points.abs(), // always negative
      'status': 'approved',
      'isAdminPenalty': true,
      'adminNote': reason ?? 'Puan kesintisi',
      'adminNoteEn': ?reasonEn,
      'leaderboardOptIn': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _recalculateLeaderboard();
  }

  /// Create a bonus-point post for a user. The post is created as
  /// `approved` so it counts immediately (1 write + leaderboard recalc).
  Future<void> addBonusPoints({
    required String nickname,
    required int points,
    String? reason,
    String? reasonEn,
  }) async {
    final docRef = _firestore.collection(_postsCollection).doc();
    await docRef.set({
      'id': docRef.id,
      'nickname': nickname,
      'category': 'Admin Bonusu',
      'points': points,
      'status': 'approved',
      'isAdminBonus': true,
      'adminNote': reason ?? 'Admin bonusu',
      'adminNoteEn': ?reasonEn,
      'leaderboardOptIn': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _recalculateLeaderboard();
  }

  /// Set all posts of a user to opt-out and recalculate leaderboard.
  /// Used when a user voluntarily leaves the contest.
  Future<void> optOutUser(String nickname) async {
    final snapshot = await _firestore
        .collection(_postsCollection)
        .where('nickname', isEqualTo: nickname)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'leaderboardOptIn': false});
    }
    await batch.commit();
    await _recalculateLeaderboard();
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
      print('Leaderboard recalculation error: $e');
    }
  }
}

/// Lightweight user summary returned by [PointsRepository.getAllUsers].
class _UserSummary {
  final String nickname;
  final int totalPoints;
  final int postCount;
  final int bonusCount;
  final bool leaderboardOptIn;

  const _UserSummary({
    required this.nickname,
    required this.totalPoints,
    required this.postCount,
    required this.bonusCount,
    required this.leaderboardOptIn,
  });
}
