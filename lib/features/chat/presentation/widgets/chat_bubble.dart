import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/chat_providers.dart';

/// Pastel-themed chat bubble for user or EcoChef.
/// EcoChef messages render Markdown; user messages render plain text.
/// Animates in with fade + slide on first build.
/// When [typewriter] is true, EcoChef text appears character by character.
class ChatBubble extends StatefulWidget {
  const ChatBubble({
    super.key,
    required this.entry,
    this.typewriter = false,
    this.onTypewriterComplete,
  });

  final ChatMessageEntry entry;

  /// If true, EcoChef messages appear with a typewriter (character-by-character) effect.
  final bool typewriter;

  /// Called when the typewriter animation finishes.
  final VoidCallback? onTypewriterComplete;

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Typewriter state
  Timer? _typewriterTimer;
  int _visibleChars = 0;
  bool _typewriterDone = false;

  @override
  void initState() {
    super.initState();

    // ── Fade + Slide animation ──
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    final slideBegin = widget.entry.isUser
        ? const Offset(0.15, 0.05)
        : const Offset(-0.15, 0.05);

    _slideAnimation = Tween<Offset>(
      begin: slideBegin,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();

    // ── Typewriter effect (EcoChef only) ──
    if (widget.typewriter && !widget.entry.isUser) {
      _startTypewriter();
    } else {
      _typewriterDone = true;
      _visibleChars = widget.entry.text.length;
    }
  }

  void _startTypewriter() {
    final fullText = widget.entry.text;
    _visibleChars = 0;
    _typewriterDone = false;

    // Characters per tick — speed adapts to text length
    const tickDuration = Duration(milliseconds: 18);
    final charsPerTick = fullText.length > 500 ? 3 : (fullText.length > 200 ? 2 : 1);

    _typewriterTimer = Timer.periodic(tickDuration, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _visibleChars += charsPerTick;
        if (_visibleChars >= fullText.length) {
          _visibleChars = fullText.length;
          _typewriterDone = true;
          timer.cancel();
          widget.onTypewriterComplete?.call();
        }
      });
    });
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  String get _displayText {
    final fullText = widget.entry.text;
    if (_typewriterDone) return fullText;
    return fullText.substring(0, _visibleChars.clamp(0, fullText.length));
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.entry.isUser;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) _ecoChefAvatar(),
              if (!isUser) const SizedBox(width: 10),
              Flexible(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 80),
                  curve: Curves.easeOut,
                  alignment: Alignment.topLeft,
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
                            widget.entry.text,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.white,
                                  height: 1.4,
                                ),
                          )
                        : _MarkdownBody(text: _displayText),
                  ),
                ),
              ),
              if (isUser) const SizedBox(width: 10),
              if (isUser) _userAvatar(),
            ],
          ),
        ),
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
