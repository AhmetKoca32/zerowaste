import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/chat_providers.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/ecochef_chat_empty.dart';
import '../widgets/ecochef_typing_indicator.dart';
import '../widgets/ecochef_welcome.dart';

/// Chat with EcoChef (AI mascot). Pastel bubbles, DeepSeek, auto-scroll.
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key, this.inTabs = false});

  final bool inTabs;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;
  bool _chatStarted = false;

  /// Background auto-clear timer (5 minutes).
  Timer? _backgroundTimer;
  static const _backgroundTimeout = Duration(minutes: 5);

  @override
  bool get wantKeepAlive => true; // Keep state alive across tab switches

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _backgroundTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final hasMessages = ref.read(chatMessagesProvider).isNotEmpty;

    if (state == AppLifecycleState.paused && hasMessages) {
      // Uygulama arka plana gitti — 5 dakika sonra sohbeti temizle
      _backgroundTimer?.cancel();
      _backgroundTimer = Timer(_backgroundTimeout, () {
        if (mounted) {
          ref.read(chatMessagesProvider.notifier).clear();
          setState(() => _chatStarted = false);
        }
      });
    } else if (state == AppLifecycleState.resumed) {
      // Kullanıcı geri döndü — timer'ı iptal et
      _backgroundTimer?.cancel();
      _backgroundTimer = null;
    }
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

  /// Start the chat session (transition from welcome → chat mode).
  void _startChat() {
    setState(() => _chatStarted = true);
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    final sentCount = ref.read(dailyMessageCountProvider);
    if (sentCount >= 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Bugünlük 20 mesaj hakkın doldu! Detaylı tarifler için yarın tekrar gel.'),
          backgroundColor: AppColors.brandOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    _controller.clear();

    final notifier = ref.read(chatMessagesProvider.notifier);
    notifier.add(ChatMessageEntry(text: text, isUser: true));
    ref.read(dailyMessageCountProvider.notifier).state++;
    
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
  /// Starts chat and sends the suggestion as the first message.
  void _sendSuggestion(String text) {
    setState(() => _chatStarted = true);
    _controller.text = text;
    _sendMessage();
  }

  /// End the current chat session and go back to welcome.
  void _endChat() {
    ref.read(chatMessagesProvider.notifier).clear();
    setState(() => _chatStarted = false);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin

    final messages = ref.watch(chatMessagesProvider);

    // If messages exist (e.g. returning from another tab), auto-enter chat mode
    if (!_chatStarted && messages.isNotEmpty) {
      _chatStarted = true;
    }

    // ── Welcome Screen (chat not started) ──
    if (!_chatStarted) {
      final welcomeUI = EcoChefWelcome(
        onStartChat: _startChat,
        onSuggestionTap: _sendSuggestion,
      );

      if (widget.inTabs) return welcomeUI;
      return Scaffold(backgroundColor: AppColors.paper, body: welcomeUI);
    }

    // ── Active Chat UI ──
    final bool showBackButton = messages.isEmpty && !_isSending;

    final inputBar = Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Row(
        children: [
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
                      padding: const EdgeInsets.only(
                        right: 6,
                        top: 4,
                        bottom: 4,
                      ),
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
        // Arka planda: mesaj yoksa minimal empty state, varsa mesaj listesi
        Positioned.fill(
          child: messages.isEmpty && !_isSending
              ? const EcoChefChatEmpty()
              : ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: EdgeInsets.fromLTRB(
                    16,
                    72,
                    16,
                    widget.inTabs ? 200 : 120,
                  ),
                  itemCount: messages.length + (_isSending ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isSending && index == 0) {
                      return const EcoChefTypingIndicator();
                    }
                    final actualIndex = _isSending ? index - 1 : index;
                    final message = messages.reversed.toList()[actualIndex];

                    // Typewriter effect only for the newest EcoChef message
                    final isNewestEcoChef = actualIndex == 0 && !message.isUser;

                    return ChatBubble(
                      entry: message,
                      typewriter: isNewestEcoChef,
                      onTypewriterComplete: isNewestEcoChef ? _scrollToBottom : null,
                    );
                  },
                ),
        ),
        // Üst başlık: EcoChef — sadece mesaj varken göster
        if (messages.isNotEmpty || _isSending)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Container(
                margin: const EdgeInsets.only(top: 8, left: 40, right: 40),
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 8,
                  top: 4,
                  bottom: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 24),
                          Icon(
                            Icons.eco_rounded,
                            color: AppColors.brandOrange,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'EcoChef',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 32,
                      width: 32,
                      child: PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          color: AppColors.inkLight,
                          size: 18,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        color: Colors.white,
                        surfaceTintColor: Colors.transparent,
                        elevation: 4,
                        position: PopupMenuPosition.under,
                        offset: const Offset(0, 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        onSelected: (value) {
                          if (value == 'clear') {
                            ref.read(chatMessagesProvider.notifier).clear();
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'clear',
                            height: 36,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.delete_sweep_rounded,
                                  size: 16,
                                  color: AppColors.inkLight,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Sohbeti Temizle',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        // Sol üst geri butonu — sadece mesaj gönderilmeden önce görünür
        if (showBackButton)
          Positioned(
            top: 0,
            left: 8,
            child: SafeArea(
              bottom: false,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _endChat,
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.ink,
                    size: 22,
                  ),
                  tooltip: 'Geri',
                ),
              ),
            ),
          ),
        // Yüzen input bar
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            top: false,
            child: Padding(
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
