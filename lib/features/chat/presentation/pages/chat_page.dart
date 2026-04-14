import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/chat_providers.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/ecochef_typing_indicator.dart';
import '../widgets/ecochef_welcome.dart';

/// Chat with EcoChef (AI mascot). Pastel bubbles, DeepSeek, auto-scroll.
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key, this.inTabs = false});

  final bool inTabs;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    _controller.clear();

    final notifier = ref.read(chatMessagesProvider.notifier);
    notifier.add(ChatMessageEntry(text: text, isUser: true));
    _scrollToBottom();

    setState(() => _isSending = true);

    String reply;
    try {
      final deepSeek = ref.read(deepSeekServiceProvider);
      reply = await deepSeek.chatWithMascot(text);
    } catch (e) {
      reply =
          'Bir şeyler yanlış gitti. Bağlantınızı kontrol edin veya tekrar deneyin. ($e)';
    }

    if (!mounted) return;
    notifier.add(ChatMessageEntry(text: reply, isUser: false));
    setState(() => _isSending = false);
    _scrollToBottom();
  }

  /// Called when a suggestion chip is tapped from the welcome screen.
  void _sendSuggestion(String text) {
    _controller.text = text;
    _sendMessage();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    // BottomNav bar'ın boyu (yaklaşık 84px) + margin (12px) + ekstra 12px boşluk
    final bottomSpacing = widget.inTabs
        ? bottomSafe + 12.0 + 84.0 + 12.0
        : bottomSafe + 12.0;

    final inputBar = Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        children: [
          if (messages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () =>
                    ref.read(chatMessagesProvider.notifier).clear(),
                icon: const Icon(
                  Icons.delete_sweep_rounded,
                  color: AppColors.inkLight,
                ),
                tooltip: 'Sohbeti Temizle',
              ),
            ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: const Color(0xFFE8E8E8), width: 0.5),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.05),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.02),
                    ],
                    stops: const [0.0, 0.15, 0.85, 1.0],
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'EcoChef\'e yazın...',
                    hintStyle: const TextStyle(
                      fontFamily: 'Manrope',
                      color: AppColors.inkLight,
                      fontSize: 14,
                    ),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.only(
                      left: 20,
                      right: 6,
                      top: 12,
                      bottom: 12,
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 6, top: 4, bottom: 4),
                      child: IconButton.filled(
                        onPressed: _isSending ? null : _sendMessage,
                        icon: const Icon(Icons.send_rounded, size: 18),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.brandOrange,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  enabled: !_isSending,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 15,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final chatUI = Stack(
      children: [
        // Arka planda serbestçe akan sohbetler
        Positioned.fill(
          child: messages.isEmpty && !_isSending
              ? EcoChefWelcome(onSuggestionTap: _sendSuggestion)
              : ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  // Mesajların navbar'ın altından akması ama son mesaja ulaşıldığında örtülmemesi için padding
                  padding: EdgeInsets.fromLTRB(16, 8, 16, widget.inTabs ? 160 : 80),
                  itemCount: messages.length + (_isSending ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isSending && index == 0) {
                      return const EcoChefTypingIndicator();
                    }
                    final actualIndex = _isSending ? index - 1 : index;
                    final message = messages.reversed.toList()[actualIndex];
                    return ChatBubble(entry: message);
                  },
                ),
        ),
        // Yüzen, bağımsız ve şeffaf giriş alanı
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            top: false,
            child: Padding(
              // Kendi tutturduğun o sıfıra sıfır 0 değeri
              padding: EdgeInsets.only(bottom: widget.inTabs ? 0 : 12),
              child: inputBar,
            ),
          ),
        ),
      ],
    );

    if (widget.inTabs) return chatUI;

    return Scaffold(backgroundColor: AppColors.paper, body: chatUI);
  }
}
