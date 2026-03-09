import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/chat_providers.dart';

/// Pastel-themed chat bubble for user or Leafy.
class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.entry});

  final ChatMessageEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = entry.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) _leafyAvatar(),
          if (!isUser) const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.brandOrange.withOpacity(0.9)
                    : AppColors.cream,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                border: Border.all(
                  color: isUser
                      ? AppColors.brandOrange70.withOpacity(0.5)
                      : AppColors.brandCream,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandOrange.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                entry.text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isUser ? Colors.white : AppColors.ink,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 10),
          if (isUser) _userAvatar(),
        ],
      ),
    );
  }

  Widget _leafyAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.brandCream,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.brandCream),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandOrange.withOpacity(0.2),
            blurRadius: 6,
          ),
        ],
      ),
      child: const Icon(Icons.eco, color: AppColors.brandOrange, size: 22),
    );
  }

  Widget _userAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.brandCream.withOpacity(0.6),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.brandOrange.withOpacity(0.5)),
      ),
      child: const Icon(Icons.person, color: AppColors.brandOrange, size: 20),
    );
  }
}
