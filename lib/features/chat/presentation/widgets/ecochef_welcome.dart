import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Welcome screen shown before the chat starts.
/// Displays EcoChef avatar, greeting, "Sohbete Başla" button,
/// and suggestion chips below the button.
class EcoChefWelcome extends StatelessWidget {
  const EcoChefWelcome({
    super.key,
    required this.onStartChat,
    this.onSuggestionTap,
  });

  /// Called when the user taps the "Sohbete Başla" button.
  final VoidCallback onStartChat;

  /// Called when a suggestion chip is tapped — starts chat with that message.
  final ValueChanged<String>? onSuggestionTap;

  static const List<_Suggestion> _suggestions = [
    _Suggestion(
      icon: Icons.bakery_dining_rounded,
      text: 'Bayat ekmeklerle ne yapabilirim?',
    ),
    _Suggestion(
      icon: Icons.eco_rounded,
      text: 'Sıfır atık mutfak ipuçları ver',
    ),
    _Suggestion(
      icon: Icons.restaurant_rounded,
      text: 'Meyve kabuklarını nasıl değerlendiririm?',
    ),
    _Suggestion(
      icon: Icons.soup_kitchen_rounded,
      text: 'Sebze artıklarından çorba tarifi',
    ),
    _Suggestion(
      icon: Icons.lightbulb_outline_rounded,
      text: 'Gıda israfını azaltmanın 5 yolu',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 170),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 64),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 36),

                // ── Avatar ──
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.brandOrange.withOpacity(0.15),
                        AppColors.brandCream,
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.brandOrange.withOpacity(0.25),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brandOrange.withOpacity(0.12),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.eco_rounded,
                    color: AppColors.brandOrange,
                    size: 48,
                  ),
                ),

                const SizedBox(height: 24),

                // ── Title ──
                const Text(
                  'EcoChef',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 8),

                // ── Subtitle ──
                Text(
                  'Sıfır atık mutfak yardımcınız',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.inkLight.withOpacity(0.8),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Description ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.brandCream.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.brandCream.withOpacity(0.6),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Tarif önerileri, gıda israfını azaltma ipuçları ve sürdürülebilir mutfak pratikleri hakkında benimle sohbet edebilirsiniz! 🌿',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                          color: AppColors.inkLight,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.brandOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.brandOrange),
                            const SizedBox(width: 4),
                            Text(
                              'Günlük 20 mesaj hakkınız bulunmaktadır',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.brandOrange.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── "Sohbete Başla" Button ──
                _StartChatButton(onTap: onStartChat),

                const SizedBox(height: 36),

                // ── Suggestion Section Title ──
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.brandOrange,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Ya da direkt sorun',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ── Suggestion Chips ──
                ...List.generate(_suggestions.length, (index) {
                  final suggestion = _suggestions[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _SuggestionCard(
                      icon: suggestion.icon,
                      text: suggestion.text,
                      onTap: () => onSuggestionTap?.call(suggestion.text),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Suggestion {
  const _Suggestion({required this.icon, required this.text});
  final IconData icon;
  final String text;
}

// ── Start Chat Button ──────────────────────────────────────────────

class _StartChatButton extends StatefulWidget {
  const _StartChatButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_StartChatButton> createState() => _StartChatButtonState();
}

class _StartChatButtonState extends State<_StartChatButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _pressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.brandOrange,
                    Color(0xFFF4845F),
                  ],
                ),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandOrange.withOpacity(0.35),
                    blurRadius: 12 + _pulseAnimation.value,
                    spreadRadius: _pulseAnimation.value / 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chat_bubble_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Sohbete Başla',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Suggestion Card ──────────────────────────────────────────────

class _SuggestionCard extends StatefulWidget {
  const _SuggestionCard({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  State<_SuggestionCard> createState() => _SuggestionCardState();
}

class _SuggestionCardState extends State<_SuggestionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.brandOrange.withOpacity(0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandOrange.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.brandOrange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.icon,
                  color: AppColors.brandOrange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.text,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink,
                    height: 1.3,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.brandOrange.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
