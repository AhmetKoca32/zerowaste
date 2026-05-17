import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Splash screen with a narrative sequence:
/// 1. AB logo appears big at center → holds → shrinks & moves to bottom-left
/// 2. UA logo appears big at center → holds → shrinks & moves to bottom-right
/// 3. EU funded logo slides down from above
/// 4. Atıksız Mutfak logo appears higher up at center and stays
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const _totalMs = 5000;
  static double _t(double ms) => ms / _totalMs;

  late final Animation<double> _abProgress;
  late final Animation<double> _uaProgress;
  late final Animation<double> _euProgress;
  late final Animation<double> _atiksizFade;
  late final Animation<Offset> _atiksizSlide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _totalMs),
    );

    // Act 1: AB (0–1600ms)
    _abProgress = CurvedAnimation(
      parent: _controller,
      curve: Interval(_t(0), _t(1600), curve: Curves.easeInOutCubic),
    );

    // Act 2: UA (1400–3000ms)
    _uaProgress = CurvedAnimation(
      parent: _controller,
      curve: Interval(_t(1400), _t(3000), curve: Curves.easeInOutCubic),
    );

    // Act 3: EU slides down (3100–3900ms)
    _euProgress = CurvedAnimation(
      parent: _controller,
      curve: Interval(_t(3100), _t(3900), curve: Curves.easeOutCubic),
    );

    // Act 4: Atıksız appears (3600–4800ms)
    _atiksizFade = CurvedAnimation(
      parent: _controller,
      curve: Interval(_t(3600), _t(4800), curve: Curves.easeOutCubic),
    );
    _atiksizSlide =
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(_t(3600), _t(4800), curve: Curves.easeOutCubic),
          ),
        );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        context.go('/');
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ─────────────────────────────────────────
          // Layer 1: Atıksız Mutfak (higher center)
          // ─────────────────────────────────────────
          Align(
            alignment: const Alignment(0, -0.3),
            child: FadeTransition(
              opacity: _atiksizFade,
              child: SlideTransition(
                position: _atiksizSlide,
                child: Image.asset(
                  'assets/images/icons/atıksız_mutfak_logo_1tr.png',
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // ─────────────────────────────────────────
          // Layer 2: EU funded icon — slides down from above
          // ─────────────────────────────────────────
          _AnimatedEuLogo(listenable: _euProgress),

          // ─────────────────────────────────────────
          // Layer 3: AB logo — hero → final
          // ─────────────────────────────────────────
          AnimatedBuilder(
            animation: _abProgress,
            builder: (context, child) {
              final t = _abProgress.value;
              if (t <= 0) return const SizedBox.shrink();

              // Fade in during first 300ms (300/1600 ≈ 0.19)
              const fadeEnd = 0.19;
              final opacity = t < fadeEnd ? t / fadeEnd : 1.0;

              // Hold big at center for 1100ms, then shrink over 500ms
              // 1100/1600 ≈ 0.69
              const holdEnd = 0.69;
              double scale;
              Alignment align;
              if (t < holdEnd) {
                scale = 3.3;
                align = Alignment.center;
              } else {
                final shrinkT = (t - holdEnd) / (1.0 - holdEnd);
                scale = 1.0 + 2.3 * (1.0 - shrinkT);
                align = Alignment.lerp(
                  Alignment.center,
                  const Alignment(-0.25, 0.8),
                  shrinkT,
                )!;
              }

              return Opacity(
                opacity: opacity,
                child: Align(
                  alignment: align,
                  child: Transform.scale(scale: scale, child: child),
                ),
              );
            },
            child: Image.asset(
              'assets/images/icons/ab-baskanligi-logo.png',
              height: 40,
            ),
          ),

          // ─────────────────────────────────────────
          // Layer 4: UA logo — hero → final
          // ─────────────────────────────────────────
          AnimatedBuilder(
            animation: _uaProgress,
            builder: (context, child) {
              final t = _uaProgress.value;
              if (t <= 0) return const SizedBox.shrink();

              // Fade in during first 300ms (300/1600 ≈ 0.19)
              const fadeEnd = 0.19;
              final opacity = t < fadeEnd ? t / fadeEnd : 1.0;

              // Hold big at center for 800ms, then shrink over 500ms
              // (300ms fade + 800ms hold = 1100ms) → 1100/1600 ≈ 0.69
              const holdEnd = 0.69;
              double scale;
              Alignment align;
              if (t < holdEnd) {
                scale = 3.3;
                align = Alignment.center;
              } else {
                final shrinkT = (t - holdEnd) / (1.0 - holdEnd);
                scale = 1.0 + 2.3 * (1.0 - shrinkT);
                align = Alignment.lerp(
                  Alignment.center,
                  const Alignment(0.25, 0.8),
                  shrinkT,
                )!;
              }

              return Opacity(
                opacity: opacity,
                child: Align(
                  alignment: align,
                  child: Transform.scale(scale: scale, child: child),
                ),
              );
            },
            child: Image.asset(
              'assets/images/icons/ulusal-ajans-logo.png',
              height: 40,
            ),
          ),
          // ── Admin giris butonu (sag alt kose) ──
          Positioned(
            right: 16,
            bottom: 60,
            child: GestureDetector(
              onTap: () => context.go('/admin/login'),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.admin_panel_settings_outlined,
                  size: 20,
                  color: Colors.black38,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// EU funded icon that slides down from above to its final position.
class _AnimatedEuLogo extends AnimatedWidget {
  const _AnimatedEuLogo({required super.listenable});

  Animation<double> get progress => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    final t = progress.value;
    if (t <= 0) return const SizedBox.shrink();

    final dy = (1.0 - t) * -2.0;
    final opacity = t < 0.3 ? t / 0.3 : 1.0;

    return FractionalTranslation(
      translation: Offset(0, dy),
      child: Opacity(
        opacity: opacity,
        child: Align(
          alignment: const Alignment(0, 0.67),
          child: Image.asset(
            'assets/images/icons/co-funded-by-eu-logo-tr.png',
            height: 48,
          ),
        ),
      ),
    );
  }
}
