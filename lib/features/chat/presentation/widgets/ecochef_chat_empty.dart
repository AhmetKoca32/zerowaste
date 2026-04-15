import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Minimal empty-state shown inside the active chat when there are no messages yet.
/// A small floating EcoChef avatar with a subtle prompt — feels like the chat is
/// alive and waiting, rather than repeating the full welcome screen.
class EcoChefChatEmpty extends StatefulWidget {
  const EcoChefChatEmpty({super.key});

  @override
  State<EcoChefChatEmpty> createState() => _EcoChefChatEmptyState();
}

class _EcoChefChatEmptyState extends State<EcoChefChatEmpty>
    with TickerProviderStateMixin {
  // ── Float animation ──
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  // ── Fade-in for the whole content ──
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // ── Typewriter for prompt text ──
  static const _promptText = 'Size nasıl yardımcı olabilirim?';
  Timer? _typewriterTimer;
  int _visibleChars = 0;
  bool _typewriterDone = false;

  // ── Hint fade-in (appears after typewriter) ──
  late AnimationController _hintController;
  late Animation<double> _hintFade;

  @override
  void initState() {
    super.initState();

    // Float (continuous bob)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Fade in the avatar + content area
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    // Hint text fade (triggered after typewriter)
    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _hintFade = CurvedAnimation(
      parent: _hintController,
      curve: Curves.easeOut,
    );

    // Start typewriter after a short delay (let avatar fade in first)
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _startTypewriter();
    });
  }

  void _startTypewriter() {
    _visibleChars = 0;
    _typewriterDone = false;

    _typewriterTimer = Timer.periodic(
      const Duration(milliseconds: 45),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          _visibleChars++;
          if (_visibleChars >= _promptText.length) {
            _visibleChars = _promptText.length;
            _typewriterDone = true;
            timer.cancel();
            // Show hint, then schedule reverse
            _hintController.forward().then((_) {
              Future.delayed(const Duration(milliseconds: 1500), () {
                if (!mounted) return;
                // Fade out hint while erasing text in reverse
                _hintController.reverse();
                _startReverseTypewriter();
              });
            });
          }
        });
      },
    );
  }

  /// Erases text character-by-character (reverse typewriter).
  void _startReverseTypewriter() {
    _typewriterTimer?.cancel();
    _typewriterTimer = Timer.periodic(
      const Duration(milliseconds: 30),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          _visibleChars--;
          if (_visibleChars <= 0) {
            _visibleChars = 0;
            _typewriterDone = false;
            timer.cancel();
            // Short pause, then restart the cycle
            Future.delayed(const Duration(milliseconds: 600), () {
              if (mounted) _startTypewriter();
            });
          }
        });
      },
    );
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    _floatController.dispose();
    _fadeController.dispose();
    _hintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayText = _promptText.substring(
      0,
      _visibleChars.clamp(0, _promptText.length),
    );

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Floating Avatar ──
              AnimatedBuilder(
                animation: _floatAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatAnimation.value),
                    child: child,
                  );
                },
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.brandOrange.withOpacity(0.12),
                        AppColors.brandCream,
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.brandOrange.withOpacity(0.2),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brandOrange.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.eco_rounded,
                    color: AppColors.brandOrange,
                    size: 34,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Typewriter prompt text ──
              SizedBox(
                height: 24,
                child: Text(
                  _visibleChars > 0 ? displayText : '',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink.withOpacity(0.7),
                    letterSpacing: -0.3,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // ── Subtle hint (fades in after typewriter) ──
              FadeTransition(
                opacity: _hintFade,
                child: Text(
                  'Aşağıdan mesajınızı yazabilirsiniz',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.inkLight.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
