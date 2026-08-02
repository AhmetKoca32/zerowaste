/// Single EcoChef chat bubble (user or assistant).
class ChatMessageEntry {
  const ChatMessageEntry({
    required this.text,
    required this.isUser,
  });

  final String text;
  final bool isUser;

  Map<String, dynamic> toJson() => {
        'text': text,
        'isUser': isUser,
      };

  factory ChatMessageEntry.fromJson(Map<String, dynamic> json) {
    return ChatMessageEntry(
      text: json['text'] as String? ?? '',
      isUser: json['isUser'] as bool? ?? false,
    );
  }
}
