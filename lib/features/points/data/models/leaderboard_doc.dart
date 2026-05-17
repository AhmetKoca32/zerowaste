import 'package:cloud_firestore/cloud_firestore.dart';

/// Single leaderboard entry.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.nickname,
    required this.points,
  });

  final String nickname;
  final int points;

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntry(
      nickname: map['nickname'] as String? ?? '',
      points: map['points'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'nickname': nickname,
        'points': points,
      };
}

/// Leaderboard document stored in Firestore (single doc: leaderboard/current).
class LeaderboardDoc {
  const LeaderboardDoc({
    required this.entries,
    required this.lastUpdated,
  });

  final List<LeaderboardEntry> entries;
  final DateTime lastUpdated;

  factory LeaderboardDoc.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final entriesList = (data['entries'] as List<dynamic>?)
            ?.map((e) =>
                LeaderboardEntry.fromMap(e as Map<String, dynamic>))
            .toList() ??
        [];
    return LeaderboardDoc(
      entries: entriesList,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'entries': entries.map((e) => e.toMap()).toList(),
        'lastUpdated': Timestamp.fromDate(lastUpdated),
      };
}
