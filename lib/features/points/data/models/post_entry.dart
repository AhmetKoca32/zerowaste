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
    this.imageUrl,
    this.localPreviewPath,
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

  /// Firebase Storage download URL persisted in Firestore.
  final String? imageUrl;

  /// Local file path for optimistic preview during upload (not persisted).
  final String? localPreviewPath;

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
    final tr = adminNote?.trim();
    final en = adminNoteEn?.trim();
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

  PostEntry copyWith({
    String? id,
    String? nickname,
    String? category,
    int? points,
    String? imageUrl,
    String? localPreviewPath,
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
      imageUrl: imageUrl ?? this.imageUrl,
      localPreviewPath: localPreviewPath ?? this.localPreviewPath,
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
      imageUrl: _parseImageUrl(data),
      imageColor: data['imageColor'] as int?,
      status: _parseStatus(data['status'] as String?),
      isAdminBonus: data['isAdminBonus'] as bool? ?? false,
      isAdminPenalty: data['isAdminPenalty'] as bool? ?? false,
      adminNote: _parseLocalizedString(data, const [
        'adminNote',
        'adminNoteTr',
        'reason',
        'reasonTr',
        'note',
        'noteTr',
      ]),
      adminNoteEn: _parseLocalizedString(data, const [
        'adminNoteEn',
        'reasonEn',
        'noteEn',
      ]),
      leaderboardOptIn: data['leaderboardOptIn'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// First non-empty string among [keys] in [data].
  static String? _parseLocalizedString(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  /// Reads `imageUrl` first, then legacy `imagePath` if it looks like a URL.
  static String? _parseImageUrl(Map<String, dynamic> data) {
    final url = data['imageUrl'] as String?;
    if (url != null && _isHttpUrl(url)) return url;

    final legacy = data['imagePath'] as String?;
    if (legacy != null && _isHttpUrl(legacy)) return legacy;
    return null;
  }

  static bool _isHttpUrl(String value) =>
      value.startsWith('http://') || value.startsWith('https://');

  Map<String, dynamic> toFirestore() => {
        'nickname': nickname,
        'category': category,
        'points': points,
        if (imageUrl != null) 'imageUrl': imageUrl,
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
