import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'chat_message_entry.dart';

/// Local EcoChef session: JSON in [SharedPreferences], 24h TTL, capped length.
class ChatSessionStorage {
  ChatSessionStorage._();

  static const _key = 'ecochef_chat_session';
  static const ttl = Duration(hours: 24);
  static const maxMessages = 50;

  /// Loads messages if the session is still within [ttl]; otherwise clears and
  /// returns an empty list.
  static Future<List<ChatMessageEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const [];

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final updatedAtRaw = map['updatedAt'] as String?;
      final updatedAt =
          updatedAtRaw != null ? DateTime.tryParse(updatedAtRaw) : null;
      if (updatedAt == null || DateTime.now().difference(updatedAt) > ttl) {
        await prefs.remove(_key);
        return const [];
      }

      final list = map['messages'] as List<dynamic>? ?? const [];
      return list
          .map((e) => ChatMessageEntry.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    } catch (_) {
      await prefs.remove(_key);
      return const [];
    }
  }

  /// Persists [messages], refreshing [updatedAt]. Empty list removes the key.
  static Future<void> save(List<ChatMessageEntry> messages) async {
    final prefs = await SharedPreferences.getInstance();
    if (messages.isEmpty) {
      await prefs.remove(_key);
      return;
    }

    final trimmed = messages.length > maxMessages
        ? messages.sublist(messages.length - maxMessages)
        : messages;

    await prefs.setString(
      _key,
      jsonEncode({
        'updatedAt': DateTime.now().toIso8601String(),
        'messages': trimmed.map((e) => e.toJson()).toList(),
      }),
    );
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<bool> hasStoredSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    return raw != null && raw.isNotEmpty;
  }
}
