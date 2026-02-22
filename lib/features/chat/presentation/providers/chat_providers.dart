import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_providers.g.dart';

/// Placeholder: will hold chat messages and AI mascot conversation state.
@riverpod
class ChatMessages extends _$ChatMessages {
  @override
  List<ChatMessageEntry> build() => [];

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
