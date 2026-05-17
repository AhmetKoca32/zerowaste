import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// Minimal empty-state shown inside the active chat when there are no messages yet.
class EcoChefChatEmpty extends StatefulWidget {
  const EcoChefChatEmpty({super.key});

  @override
  State<EcoChefChatEmpty> createState() => _EcoChefChatEmptyState();
}

class _EcoChefChatEmptyState extends State<EcoChefChatEmpty>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String _promptText = '';
  Timer? _typewriterTimer;
  int _visibleChars = 0;
  late AnimationController _hintController;
  late Animation<double> _hintFade;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _hintFade = CurvedAnimation(
      parent: _hintController,
      curve: Curves.easeOut,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _promptText = AppLocalizations.of(context)!.chatEmptyPrompt;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _startTypewriter();
      });
    }
  }

  void _startTypewriter() {
    _visibleChars = 0;

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
            timer.cancel();
            _hintController.forward().then((_) {
              Future.delayed(const Duration(milliseconds: 1500), () {
                if (!mounted) return;
                _hintController.reverse();
                _startReverseTypewriter();
              });
            });
          }
        });
      },
    );
  }

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
            timer.cancel();
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
    final l10n = AppLocalizations.of(context)!;
    final displayText = _promptText.substring(
      0,
      _visibleChars.clamp(0, _promptText.length),
    );

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      'assets/images/icons/denizati.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

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

              FadeTransition(
                opacity: _hintFade,
                child: Text(
                  l10n.chatEmptyInstruction,
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
