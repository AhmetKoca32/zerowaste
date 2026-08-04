import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/leaderboard_doc.dart';
import '../models/post_entry.dart';
import '../models/user_stats.dart';

/// Repository for points/posts operations against Firestore (Plan B).
///
/// Nicknames are unique per [UserStats.claimedByUid] (anonymous Auth uid).
/// Leaderboard writes are admin/CF only.
class PointsRepository {
  PointsRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _postsCollection = 'posts';
  static const String _leaderboardDoc = 'leaderboard';
  static const String _leaderboardId = 'current';
  static const String _userStatsCollection = 'user_stats';

  static const int defaultPostsLimit = 12;
  static const int defaultRejectedLimit = 5;

  DocumentReference<Map<String, dynamic>> userStatsRef(String nickname) =>
      _firestore.collection(_userStatsCollection).doc(nickname);

  /// Generate a new post document ID before Storage upload.
  String newPostId() => _firestore.collection(_postsCollection).doc().id;

  /// Read Plan B summary for [nickname], or null if missing.
  Future<UserStats?> getUserStats(String nickname) async {
    final doc = await userStatsRef(nickname).get();
    if (!doc.exists) return null;
    return UserStats.fromFirestore(doc);
  }

  /// Claim [nickname] for [uid] (create, legacy attach, or verify ownership).
  ///
  /// - Missing doc → create with [claimedByUid]
  /// - Deleted → [NicknameClaimStatus.deleted]
  /// - Other owner → [NicknameClaimStatus.taken]
  /// - Same owner / legacy unclaimed → success
  Future<NicknameClaimOutcome> claimNickname(
    String nickname, {
    required String uid,
    bool optIn = true,
  }) async {
    final ref = userStatsRef(nickname);

    return _firestore.runTransaction((transaction) async {
      final snap = await transaction.get(ref);

      if (!snap.exists) {
        final created = UserStats(
          nickname: nickname,
          optIn: optIn,
          claimedByUid: uid,
        );
        transaction.set(
          ref,
          created.toCreateFirestore(optIn: optIn, claimedByUid: uid),
        );
        return NicknameClaimOutcome.success(created);
      }

      final existing = UserStats.fromFirestore(snap);
      if (existing.isDeleted) {
        return NicknameClaimOutcome.deleted();
      }

      if (!existing.hasOwner) {
        transaction.update(ref, {
          'claimedByUid': uid,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return NicknameClaimOutcome.success(
          existing.copyWith(claimedByUid: uid),
        );
      }

      if (existing.isOwnedBy(uid)) {
        return NicknameClaimOutcome.success(existing);
      }

      return NicknameClaimOutcome.taken();
    });
  }

  /// Client-safe optIn update for the owning uid only.
  Future<void> updateOptIn(
    String nickname,
    bool optIn, {
    required String uid,
  }) async {
    final outcome = await claimNickname(nickname, uid: uid, optIn: optIn);
    if (!outcome.isSuccess) {
      throw StateError('Cannot update optIn: ${outcome.status}');
    }
    await userStatsRef(nickname).update({
      'optIn': optIn,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Submit a new post and bump [pendingCount] when the nick is owned by [uid].
  Future<void> submitPost(
    PostEntry post, {
    String? id,
    String? ownerUid,
  }) async {
    final docRef = id != null
        ? _firestore.collection(_postsCollection).doc(id)
        : _firestore.collection(_postsCollection).doc();
    await docRef.set(post.copyWith(id: docRef.id).toFirestore());

    if (ownerUid == null || ownerUid.isEmpty) return;

    try {
      final outcome = await claimNickname(
        post.nickname,
        uid: ownerUid,
        optIn: post.leaderboardOptIn,
      );
      if (!outcome.isSuccess) return;

      await userStatsRef(post.nickname).update({
        'pendingCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Non-fatal: post already persisted; pendingCount can be fixed by admin.
    }
  }

  /// Recent posts for the nickname grid (1 query, bounded reads).
  Future<List<PostEntry>> getPostsByNickname(
    String nickname, {
    int limit = defaultPostsLimit,
  }) async {
    final snapshot = await _firestore
        .collection(_postsCollection)
        .where('nickname', isEqualTo: nickname)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map((doc) => PostEntry.fromFirestore(doc)).toList();
  }

  /// Recent rejected posts for overlay detection (bounded).
  Future<List<PostEntry>> getRecentRejectedPosts(
    String nickname, {
    int limit = defaultRejectedLimit,
  }) async {
    final snapshot = await _firestore
        .collection(_postsCollection)
        .where('nickname', isEqualTo: nickname)
        .where('status', isEqualTo: 'rejected')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map((doc) => PostEntry.fromFirestore(doc)).toList();
  }

  /// Voluntary opt-out: hard wipe via Cloud Function [leaveContest].
  /// Prefer [LeaveContestService]; kept here only if callers still use repo.
  @Deprecated('Use LeaveContestService.leaveContest')
  Future<void> optOutUser(String nickname, {required String uid}) async {
    throw UnsupportedError(
      'Client-side opt-out removed. Call leaveContest Cloud Function instead.',
    );
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
}
