import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Welcome screen shown when chat is empty.
/// Displays EcoChef avatar, greeting text, and tappable suggestion chips.
class EcoChefWelcome extends StatelessWidget {
  const EcoChefWelcome({super.key, required this.onSuggestionTap});

  final ValueChanged<String> onSuggestionTap;

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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
          const SizedBox(height: 24),

          // ── Avatar ──
          Container(
            width: 88,
            height: 88,
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
              size: 42,
            ),
          ),

          const SizedBox(height: 20),

          // ── Title ──
          const Text(
            'EcoChef',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 26,
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

          const SizedBox(height: 12),

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
            child: const Text(
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
          ),

          const SizedBox(height: 32),

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
                'Şunları sorabilirsiniz',
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
                onTap: () => onSuggestionTap(suggestion.text),
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
