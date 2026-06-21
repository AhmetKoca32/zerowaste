import 'package:cloud_firestore/cloud_firestore.dart';

/// Post approval status — admin reviews before points are awarded.
enum PostStatus {
  pending,  // Submitted, waiting for admin review
  approved, // Admin approved → points awarded
  rejected, // Admin rejected → no points
}

/// A single post entry stored in Firestore.
class PostEntry {
  PostEntry({
    this.id,
    required this.nickname,
    required this.category,
    required this.points,
    this.localImagePath,
    this.imageColor,
    this.status = PostStatus.pending,
    this.isAdminBonus = false,
    this.isAdminPenalty = false,
    this.adminNote,
    this.adminNoteEn,
    this.leaderboardOptIn = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String? id;
  final String nickname;
  final String category;
  final int points;
  final String? localImagePath;
  final int? imageColor;
  final PostStatus status;
  final bool isAdminBonus;
  final bool isAdminPenalty;
  final String? adminNote;
  final String? adminNoteEn;
  final bool leaderboardOptIn;
  final DateTime createdAt;

  /// Returns the admin note appropriate for the given locale.
  /// Falls back to the other language if the primary is missing.
  String? localizedAdminNote(String localeCode) {
    if (localeCode == 'en') return adminNoteEn ?? adminNote;
    return adminNote ?? adminNoteEn;
  }

  PostEntry copyWith({
    String? id,
    String? nickname,
    String? category,
    int? points,
    String? localImagePath,
    int? imageColor,
    PostStatus? status,
    bool? isAdminBonus,
    bool? isAdminPenalty,
    String? adminNote,
    String? adminNoteEn,
    bool? leaderboardOptIn,
    DateTime? createdAt,
  }) {
    return PostEntry(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      category: category ?? this.category,
      points: points ?? this.points,
      localImagePath: localImagePath ?? this.localImagePath,
      imageColor: imageColor ?? this.imageColor,
      status: status ?? this.status,
      isAdminBonus: isAdminBonus ?? this.isAdminBonus,
      isAdminPenalty: isAdminPenalty ?? this.isAdminPenalty,
      adminNote: adminNote ?? this.adminNote,
      adminNoteEn: adminNoteEn ?? this.adminNoteEn,
      leaderboardOptIn: leaderboardOptIn ?? this.leaderboardOptIn,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory PostEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostEntry(
      id: doc.id,
      nickname: data['nickname'] as String? ?? '',
      category: data['category'] as String? ?? '',
      points: data['points'] as int? ?? 0,
      localImagePath: data['imagePath'] as String?,
      imageColor: data['imageColor'] as int?,
      status: _parseStatus(data['status'] as String?),
      isAdminBonus: data['isAdminBonus'] as bool? ?? false,
      isAdminPenalty: data['isAdminPenalty'] as bool? ?? false,
      adminNote: data['adminNote'] as String?,
      adminNoteEn: data['adminNoteEn'] as String?,
      leaderboardOptIn: data['leaderboardOptIn'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'nickname': nickname,
        'category': category,
        'points': points,
        if (localImagePath != null) 'imagePath': localImagePath,
        if (imageColor != null) 'imageColor': imageColor,
        'status': status.name,
        'isAdminBonus': isAdminBonus,
        'isAdminPenalty': isAdminPenalty,
        if (adminNote != null) 'adminNote': adminNote,
        if (adminNoteEn != null) 'adminNoteEn': adminNoteEn,
        'leaderboardOptIn': leaderboardOptIn,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  static PostStatus _parseStatus(String? s) {
    switch (s) {
      case 'approved':
        return PostStatus.approved;
      case 'rejected':
        return PostStatus.rejected;
      default:
        return PostStatus.pending;
    }
  }
}
