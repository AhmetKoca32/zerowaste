import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/chat_providers.dart';

/// Pastel-themed chat bubble for user or EcoChef.
/// EcoChef messages render Markdown; user messages render plain text.
class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.entry});

  final ChatMessageEntry entry;

  @override
  Widget build(BuildContext context) {
    final isUser = entry.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) _ecoChefAvatar(),
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
              child: isUser
                  ? Text(
                      entry.text,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            height: 1.4,
                          ),
                    )
                  : _MarkdownBody(text: entry.text),
            ),
          ),
          if (isUser) const SizedBox(width: 10),
          if (isUser) _userAvatar(),
        ],
      ),
    );
  }

  Widget _ecoChefAvatar() {
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

/// Renders Markdown content inside EcoChef's chat bubble.
/// Styled to match the cream-colored bubble aesthetic.
class _MarkdownBody extends StatelessWidget {
  const _MarkdownBody({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: text,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        // Body text
        p: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.ink,
          height: 1.5,
        ),
        // Bold
        strong: const TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        // Italic
        em: const TextStyle(
          fontFamily: 'Manrope',
          fontStyle: FontStyle.italic,
          color: AppColors.inkLight,
        ),
        // Headers
        h1: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        h2: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        h3: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        // Lists
        listBullet: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 15,
          color: AppColors.brandOrange,
          fontWeight: FontWeight.w700,
        ),
        listIndent: 16,
        // Code
        code: TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          color: AppColors.brandOrange.withOpacity(0.9),
          backgroundColor: AppColors.brandOrange.withOpacity(0.08),
        ),
        codeblockDecoration: BoxDecoration(
          color: AppColors.brandOrange.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.brandOrange.withOpacity(0.12),
          ),
        ),
        codeblockPadding: const EdgeInsets.all(12),
        // Block quote
        blockquoteDecoration: BoxDecoration(
          color: AppColors.brandCream.withOpacity(0.5),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
          border: Border(
            left: BorderSide(
              color: AppColors.brandOrange.withOpacity(0.6),
              width: 3,
            ),
          ),
        ),
        blockquotePadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        // Horizontal rule
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.stone.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        // Link
        a: const TextStyle(
          fontFamily: 'Manrope',
          color: AppColors.brandOrange,
          decoration: TextDecoration.underline,
        ),
        // Spacing
        pPadding: const EdgeInsets.only(bottom: 4),
        h1Padding: const EdgeInsets.only(bottom: 6),
        h2Padding: const EdgeInsets.only(bottom: 5),
        h3Padding: const EdgeInsets.only(bottom: 4),
      ),
    );
  }
}
