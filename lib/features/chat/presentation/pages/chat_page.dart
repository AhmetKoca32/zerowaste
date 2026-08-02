import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zerowaste/l10n/app_localizations.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/services/deep_seek_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../data/chat_suggestion_pool.dart';
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
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();
  bool _isSending = false;
  bool _chatStarted = false;

  /// Set to `messages.length` when a fresh EcoChef reply arrives; cleared when done.
  /// Null means no typewriter (e.g. hydrated history / already finished).
  int? _typewriterForLength;

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
    _focusNode.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Drop session if 24h TTL elapsed while app was backgrounded.
      ref.read(chatMessagesProvider.notifier).purgeIfExpired().then((_) {
        if (!mounted) return;
        if (ref.read(chatMessagesProvider).isEmpty && _chatStarted) {
          setState(() {
            _chatStarted = false;
            _typewriterForLength = null;
          });
        }
      });
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

  Future<void> _sendMessage({String? aiTextOverride}) async {
    final l10n = AppLocalizations.of(context)!;
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    final sentCount = ref.read(dailyMessageCountProvider).valueOrNull ?? 0;
    if (sentCount >= DailyMessageCount.maxMessages) {
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.chatDailyLimit),
          backgroundColor: AppColors.brandOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    _controller.clear();

    final notifier = ref.read(chatMessagesProvider.notifier);
    // Snapshot before adding the new user bubble — sent as model memory.
    final priorTurns = ref
        .read(chatMessagesProvider)
        .map((e) => (text: e.text, isUser: e.isUser))
        .toList(growable: false);

    await notifier.add(ChatMessageEntry(text: text, isUser: true));
    await ref.read(dailyMessageCountProvider.notifier).increment();

    _scrollToBottom();

    setState(() => _isSending = true);

    String? reply;
    String? userFacingError;
    try {
      final deepSeek = ref.read(deepSeekServiceProvider);
      reply = await deepSeek.chatWithMascot(
        aiTextOverride ?? text,
        priorTurns: priorTurns,
      );
    } on DeepSeekConnectionException {
      userFacingError = l10n.chatConnectionError;
    } on DeepSeekTimeoutException {
      userFacingError = l10n.chatTimeoutError;
    } on DeepSeekAuthException {
      userFacingError = l10n.chatAuthError;
    } on DeepSeekApiException catch (e) {
      userFacingError = l10n.chatApiError('${e.statusCode}');
    } catch (_) {
      userFacingError = l10n.chatGenericError;
    }

    if (!mounted) return;

    if (reply != null) {
      await notifier.add(ChatMessageEntry(text: reply, isUser: false));
      if (!mounted) return;
      setState(() {
        _isSending = false;
        _typewriterForLength = ref.read(chatMessagesProvider).length;
      });
    } else {
      // The send already cost the user a daily-quota slot; refund it so the
      // failed attempt doesn't burn one of their 20 messages.
      await ref.read(dailyMessageCountProvider.notifier).refund();
      if (!mounted) return;
      setState(() => _isSending = false);
      _showErrorSnack(userFacingError!);
    }

    _scrollToBottom();
  }

  void _showErrorSnack(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.brandOrange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Called when a suggestion chip is tapped from the welcome screen.
  /// Starts chat and sends the suggestion as the first message.
  Future<void> _sendSuggestion(ChatSuggestion suggestion) async {
    final localeCode = ref.read(localeProvider).languageCode;
    setState(() => _chatStarted = true);
    _controller.text = suggestion.localized(localeCode);
    await _sendMessage(aiTextOverride: suggestion.localized(localeCode));
  }

  /// End the current chat session and go back to welcome.
  void _endChat() {
    ref.read(chatMessagesProvider.notifier).clear();
    setState(() {
      _chatStarted = false;
      _typewriterForLength = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin

    final messages = ref.watch(chatMessagesProvider);
    final l10n = AppLocalizations.of(context)!;

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
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: l10n.chatInputHint,
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

    final mq = MediaQuery.of(context);
    // Explicit padding replaces MediaQuery auto-padding; include safe area +
    // floating EcoChef pill (margin 8 + ~40 height + gap).
    final topInset = mq.padding.top + 64;
    // extendBody: padding.bottom already clears the floating navbar.
    final aboveNav = widget.inTabs ? mq.padding.bottom : mq.viewPadding.bottom;
    final keyboard = mq.viewInsets.bottom;
    final inputBottom = keyboard > 0 ? keyboard : aboveNav;
    const inputBarHeight = 72.0;
    final listBottomInset = inputBottom + inputBarHeight;

    // Message list (full-bleed so chat shows through under input / navbar)
    final messagesList = messages.isEmpty && !_isSending
        ? const EcoChefChatEmpty()
        : ListView.builder(
            controller: _scrollController,
            reverse: true,
            padding: EdgeInsets.fromLTRB(16, topInset, 16, listBottomInset),
            itemCount: messages.length + (_isSending ? 1 : 0),
            itemBuilder: (context, index) {
              if (_isSending && index == 0) {
                return const EcoChefTypingIndicator();
              }
              final actualIndex = _isSending ? index - 1 : index;
              final message = messages.reversed.toList()[actualIndex];

              // Typewriter only for a freshly arrived EcoChef reply (once).
              final isNewestEcoChef = actualIndex == 0 && !message.isUser;
              final runTypewriter = isNewestEcoChef &&
                  _typewriterForLength == messages.length;
              final messageIndex = messages.length - 1 - actualIndex;

              return ChatBubble(
                key: ValueKey('msg-$messageIndex'),
                entry: message,
                typewriter: runTypewriter,
                onTypewriterComplete: runTypewriter
                    ? () {
                        setState(() => _typewriterForLength = null);
                        _scrollToBottom();
                      }
                    : null,
              );
            },
          );

    final chatUI = Stack(
      children: [
        Positioned.fill(child: messagesList),
        Positioned(
          left: 0,
          right: 0,
          bottom: inputBottom,
          child: inputBar,
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
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 24),
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Image.asset(
                              'assets/images/icons/denizati.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
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
                            setState(() => _typewriterForLength = null);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'clear',
                            height: 36,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.delete_sweep_rounded,
                                  size: 16,
                                  color: AppColors.inkLight,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  l10n.chatClear,
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
                  tooltip: l10n.chatBack,
                ),
              ),
            ),
          ),
      ],
    );

    if (widget.inTabs) return chatUI;

    return Scaffold(backgroundColor: AppColors.paper, body: chatUI);
  }
}
