import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_placeholder.dart';
import '../providers/chat_providers.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/leafy_typing_indicator.dart';

/// Chat with Leafy (AI mascot). Pastel bubbles, DeepSeek, auto-scroll.
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
          _scrollController.position.maxScrollExtent,
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
      reply = 'Bir şeyler yanlış gitti. Bağlantınızı kontrol edin veya tekrar deneyin. ($e)';
    }

    if (!mounted) return;
    notifier.add(ChatMessageEntry(text: reply, isUser: false));
    setState(() => _isSending = false);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);

    return Scaffold(
      appBar: (widget.inTabs == true)
          ? null
          : AppBar(
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.mint.withOpacity(0.6),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.sage),
                    ),
                    child: const Icon(Icons.eco, color: AppColors.forest, size: 22),
                  ),
                  const SizedBox(width: 10),
                  const Text('Leafy'),
                ],
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go(AppRouter.home),
              ),
            ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty && !_isSending
                ? const EmptyPlaceholder(
                    icon: Icons.chat_bubble_outline,
                    message:
                        'Merhaba! Ben Leafy, sıfır atık mutfak yardımcınız. Tarif, ipucu veya gıda israfını azaltma konusunda soru sorabilirsiniz!',
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: messages.length + (_isSending ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length) {
                        return const LeafyTypingIndicator();
                      }
                      return ChatBubble(entry: messages[index]);
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: BoxDecoration(
              color: AppColors.paper,
              boxShadow: [
                BoxShadow(
                  color: AppColors.forest.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Leafy\'ye yazın...',
                        filled: true,
                        fillColor: AppColors.cream,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      enabled: !_isSending,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _isSending ? null : _sendMessage,
                    icon: const Icon(Icons.send_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.fern,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
