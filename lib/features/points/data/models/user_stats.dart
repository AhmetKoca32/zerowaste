import 'package:cloud_firestore/cloud_firestore.dart';

/// Plan B summary document at `user_stats/{nickname}`.
///
/// [totalPoints] and [status] are written by admin/CF only.
/// [claimedByUid] binds the nick to one anonymous Auth user (uniqueness).
/// Mobile may create with defaults and update [optIn] / [pendingCount] as owner.
class UserStats {
  const UserStats({
    required this.nickname,
    this.totalPoints = 0,
    this.optIn = true,
    this.status = 'active',
    this.reason,
    this.reasonEn,
    this.pendingCount = 0,
    this.claimedByUid,
    this.updatedAt,
  });

  final String nickname;
  final int totalPoints;
  final bool optIn;
  final String status;
  final String? reason;
  final String? reasonEn;
  final int pendingCount;
  final String? claimedByUid;
  final DateTime? updatedAt;

  bool get isDeleted => status == 'deleted' || status == 'banned';

  bool isOwnedBy(String uid) =>
      claimedByUid != null && claimedByUid!.isNotEmpty && claimedByUid == uid;

  bool get hasOwner =>
      claimedByUid != null && claimedByUid!.trim().isNotEmpty;

  /// Locale-aware soft-delete reason (TR/EN with fallback).
  String? localizedReason(String localeCode) {
    final tr = reason?.trim();
    final en = reasonEn?.trim();
    final trEmpty = tr == null || tr.isEmpty;
    final enEmpty = en == null || en.isEmpty;
    if (localeCode == 'en') {
      if (!enEmpty) return en;
      if (!trEmpty) return tr;
      return null;
    }
    if (!trEmpty) return tr;
    if (!enEmpty) return en;
    return null;
  }

  UserStats copyWith({
    String? nickname,
    int? totalPoints,
    bool? optIn,
    String? status,
    String? reason,
    String? reasonEn,
    int? pendingCount,
    String? claimedByUid,
    DateTime? updatedAt,
  }) {
    return UserStats(
      nickname: nickname ?? this.nickname,
      totalPoints: totalPoints ?? this.totalPoints,
      optIn: optIn ?? this.optIn,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      reasonEn: reasonEn ?? this.reasonEn,
      pendingCount: pendingCount ?? this.pendingCount,
      claimedByUid: claimedByUid ?? this.claimedByUid,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UserStats.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    String? pick(List<String> keys) {
      for (final key in keys) {
        final value = data[key];
        if (value is String && value.trim().isNotEmpty) return value.trim();
      }
      return null;
    }

    DateTime? updatedAt;
    final rawUpdated = data['updatedAt'];
    if (rawUpdated is Timestamp) {
      updatedAt = rawUpdated.toDate();
    } else if (rawUpdated is DateTime) {
      updatedAt = rawUpdated;
    }

    final claimed = data['claimedByUid'] as String?;

    return UserStats(
      nickname: data['nickname'] as String? ?? doc.id,
      totalPoints: (data['totalPoints'] as num?)?.toInt() ?? 0,
      optIn: data['optIn'] as bool? ?? true,
      status: (data['status'] as String? ?? 'active').toLowerCase(),
      reason: pick(const ['reason', 'reasonTr', 'adminNote', 'adminNoteTr']),
      reasonEn: pick(const ['reasonEn', 'adminNoteEn']),
      pendingCount: (data['pendingCount'] as num?)?.toInt() ?? 0,
      claimedByUid: claimed != null && claimed.trim().isNotEmpty
          ? claimed.trim()
          : null,
      updatedAt: updatedAt,
    );
  }

  /// Client-safe create payload (totalPoints 0, status active, owned by [claimedByUid]).
  Map<String, dynamic> toCreateFirestore({
    required bool optIn,
    required String claimedByUid,
  }) {
    return {
      'nickname': nickname,
      'totalPoints': 0,
      'optIn': optIn,
      'status': 'active',
      'pendingCount': 0,
      'claimedByUid': claimedByUid,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

/// Result of claiming a nickname for the current Auth uid.
enum NicknameClaimStatus { success, taken, deleted }

class NicknameClaimOutcome {
  const NicknameClaimOutcome._(this.status, {this.stats});

  final NicknameClaimStatus status;
  final UserStats? stats;

  factory NicknameClaimOutcome.success(UserStats stats) =>
      NicknameClaimOutcome._(NicknameClaimStatus.success, stats: stats);

  factory NicknameClaimOutcome.taken() =>
      const NicknameClaimOutcome._(NicknameClaimStatus.taken);

  factory NicknameClaimOutcome.deleted() =>
      const NicknameClaimOutcome._(NicknameClaimStatus.deleted);

  bool get isSuccess => status == NicknameClaimStatus.success;
}
