import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/chat_suggestion_pool.dart';

part 'chat_providers.g.dart';

/// Tracks the number of messages sent by the user today (limit is 20).
///
/// Persisted to [SharedPreferences] so the count survives app restarts, and
/// automatically resets when the calendar day changes.
@Riverpod(keepAlive: true)
class DailyMessageCount extends _$DailyMessageCount {
  static const _kCountKey = 'daily_message_count';
  static const _kDateKey = 'daily_message_date';
  static const _kMaxMessages = 20;

  @override
  Future<int> build() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final savedDate = prefs.getString(_kDateKey);

    // Different day → reset count
    if (savedDate != today) {
      await prefs.setInt(_kCountKey, 0);
      await prefs.setString(_kDateKey, today);
      return 0;
    }

    return prefs.getInt(_kCountKey) ?? 0;
  }

  /// Increments the count by 1, capping at [_kMaxMessages].
  Future<void> increment() async {
    final current = state.valueOrNull ?? 0;
    if (current >= _kMaxMessages) return;
    final next = current + 1;
    state = AsyncValue.data(next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kCountKey, next);
  }

  /// Refunds one slot (decrements) when a message failed to send.
  Future<void> refund() async {
    final current = state.valueOrNull ?? 0;
    if (current <= 0) return;
    final next = current - 1;
    state = AsyncValue.data(next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kCountKey, next);
  }

  /// Resets the counter to 0 and persists today's date (manual reset).
  Future<void> reset() async {
    state = const AsyncValue.data(0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kCountKey, 0);
    await prefs.setString(_kDateKey, _todayKey());
  }

  static String _todayKey() {
    final now = DateTime.now();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '${now.year}-$m-$d';
  }
}

/// Placeholder: will hold chat messages and AI mascot conversation state.
@riverpod
class ChatMessages extends _$ChatMessages {
  @override
  List<ChatMessageEntry> build() => const [];

  void add(ChatMessageEntry entry) => state = [...state, entry];
  void clear() => state = [];
}

class ChatMessageEntry {
  const ChatMessageEntry({
    required this.text,
    required this.isUser,
  });
  final String text;
  final bool isUser;
}

// ── Daily suggestion rotation ───────────────────────────────────────
//
// We persist (a) the date the suggestions were last generated and (b) the
// 5 pool indexes that were picked. On a new calendar day, we re-roll and
// overwrite both. Storing indexes (rather than the full ChatSuggestion data)
// keeps the persisted payload tiny and lets us change pool wording without
// migration headaches.

const _kSuggestionsDateKey = 'chat_suggestions_date';
const _kSuggestionsIndexesKey = 'chat_suggestions_indexes';
const _kDailySuggestionsCount = 5;

/// Selects [_kDailySuggestionsCount] suggestions once per calendar day and
/// caches them in [SharedPreferences]. Re-rolls only when the local day flips.
@Riverpod(keepAlive: true)
class DailyChatSuggestions extends _$DailyChatSuggestions {
  @override
  Future<List<ChatSuggestion>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();

    final savedDate = prefs.getString(_kSuggestionsDateKey);
    if (savedDate == today) {
      final cached = _readCachedSuggestions(prefs);
      if (cached != null) return cached;
    }

    return _rollAndPersist(prefs, today);
  }

  /// Force a new selection for today. Useful for a manual refresh action.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final next = await _rollAndPersist(prefs, today);
    state = AsyncValue.data(next);
  }

  Future<List<ChatSuggestion>> _rollAndPersist(
    SharedPreferences prefs,
    String today,
  ) async {
    final indexes = List<int>.generate(kChatSuggestionPool.length, (i) => i)
      ..shuffle();
    final picked = indexes.take(_kDailySuggestionsCount).toList();

    await prefs.setString(_kSuggestionsDateKey, today);
    await prefs.setStringList(
      _kSuggestionsIndexesKey,
      picked.map((e) => e.toString()).toList(),
    );

    return picked.map((i) => kChatSuggestionPool[i]).toList(growable: false);
  }

  /// Returns null when the cached payload is missing or no longer valid
  /// (e.g. pool size shrank below a saved index after a release).
  List<ChatSuggestion>? _readCachedSuggestions(SharedPreferences prefs) {
    final raw = prefs.getStringList(_kSuggestionsIndexesKey);
    if (raw == null || raw.length != _kDailySuggestionsCount) return null;

    final result = <ChatSuggestion>[];
    for (final value in raw) {
      final idx = int.tryParse(value);
      if (idx == null || idx < 0 || idx >= kChatSuggestionPool.length) {
        return null;
      }
      result.add(kChatSuggestionPool[idx]);
    }
    return List.unmodifiable(result);
  }

  /// Stable per-local-day key. Avoids time zone surprises by using local date.
  static String _todayKey() {
    final now = DateTime.now();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '${now.year}-$m-$d';
  }
}
