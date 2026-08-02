import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/chat_message_entry.dart';
import '../../data/chat_session_storage.dart';
import '../data/chat_suggestion_pool.dart';

export '../../data/chat_message_entry.dart';

part 'chat_providers.g.dart';

/// Tracks the number of messages sent by the user today (limit is 20).
///
/// Persisted to [SharedPreferences] so the count survives app restarts, and
/// automatically resets when the calendar day changes.
@Riverpod(keepAlive: true)
class DailyMessageCount extends _$DailyMessageCount {
  static const _kCountKey = 'daily_message_count';
  static const _kDateKey = 'daily_message_date';
  static const maxMessages = 20;
  static const _kMaxMessages = maxMessages;

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

/// EcoChef conversation. Hydrated from [ChatSessionStorage] (24h TTL).
@Riverpod(keepAlive: true)
class ChatMessages extends _$ChatMessages {
  @override
  List<ChatMessageEntry> build() {
    _hydrate();
    return const [];
  }

  Future<void> _hydrate() async {
    final loaded = await ChatSessionStorage.load();
    // Don't clobber messages the user already sent before hydrate finished.
    if (state.isEmpty && loaded.isNotEmpty) {
      state = loaded;
    }
  }

  Future<void> add(ChatMessageEntry entry) async {
    final next = [...state, entry];
    final trimmed = next.length > ChatSessionStorage.maxMessages
        ? next.sublist(next.length - ChatSessionStorage.maxMessages)
        : next;
    state = trimmed;
    await ChatSessionStorage.save(state);
  }

  Future<void> clear() async {
    state = const [];
    await ChatSessionStorage.clear();
  }

  /// Clears memory when the on-disk session is gone/expired (e.g. after 24h).
  /// Restores from disk if memory was empty but a valid session still exists.
  Future<void> purgeIfExpired() async {
    final hadSession = await ChatSessionStorage.hasStoredSession();
    final loaded = await ChatSessionStorage.load();
    if (loaded.isEmpty) {
      // Only wipe memory if disk had a session that just expired/corrupt.
      if (hadSession && state.isNotEmpty) state = const [];
    } else if (state.isEmpty) {
      state = loaded;
    }
  }
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
