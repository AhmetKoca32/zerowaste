import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_providers.g.dart';

/// Tracks the number of messages sent by the user today (limit is 20).
final dailyMessageCountProvider = StateProvider<int>((ref) => 0);

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
