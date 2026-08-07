import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/notification_service.dart';

/// Splash screen with a narrative sequence:
/// 1. AB logo appears big at center → holds → shrinks & moves to bottom-left
/// 2. UA logo appears big at center → holds → shrinks & moves to bottom-right
/// 3. EU funded + partner logos fade/slide in
/// 4. Developer credit + Atıksız Mutfak logo appear and stay
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
  late final Animation<double> _partnersProgress;
  late final Animation<double> _developerFade;
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

    // Act 3b: Partner row fades in with EU (3200–4000ms)
    _partnersProgress = CurvedAnimation(
      parent: _controller,
      curve: Interval(_t(3200), _t(4000), curve: Curves.easeOutCubic),
    );

    // Act 4a: Developer credit (slightly before brand)
    _developerFade = CurvedAnimation(
      parent: _controller,
      curve: Interval(_t(3400), _t(4200), curve: Curves.easeOutCubic),
    );

    // Act 4b: Atıksız appears (3600–4800ms)
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
        _finishSplash();
      }
    });

    _controller.forward();
  }

  Future<void> _finishSplash() async {
    await NotificationService.instance.ensureScheduled();
    if (!mounted) return;
    context.go('/');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final brandLogo = isEn
        ? 'assets/images/icons/atıksız_mutfak_logo_1en.png'
        : 'assets/images/icons/atıksız_mutfak_logo_1tr.png';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ─────────────────────────────────────────
          // Layer 0: Developer credit (top)
          // ─────────────────────────────────────────
          Align(
            alignment: Alignment.topCenter,
            child: FadeTransition(
              opacity: _developerFade,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Image.asset(
                    'assets/images/icons/og yatay.png',
                    height: 54,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          // ─────────────────────────────────────────
          // Layer 1: Brand logo (TR / EN asset)
          // ─────────────────────────────────────────
          Align(
            alignment: const Alignment(0, -0.30),
            child: FadeTransition(
              opacity: _atiksizFade,
              child: SlideTransition(
                position: _atiksizSlide,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Image.asset(
                    brandLogo,
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          // ─────────────────────────────────────────
          // Layer 2: Partner logos (between brand & EU)
          // ─────────────────────────────────────────
          _AnimatedPartnerRow(listenable: _partnersProgress),

          // ─────────────────────────────────────────
          // Layer 3: EU funded icon — slides down
          // ─────────────────────────────────────────
          _AnimatedEuLogo(listenable: _euProgress, isEnglish: isEn),

          // ─────────────────────────────────────────
          // Layer 4: AB logo — hero → final
          // ─────────────────────────────────────────
          AnimatedBuilder(
            animation: _abProgress,
            builder: (context, child) {
              final t = _abProgress.value;
              if (t <= 0) return const SizedBox.shrink();

              const fadeEnd = 0.19;
              final opacity = t < fadeEnd ? t / fadeEnd : 1.0;

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
                  const Alignment(-0.25, 0.85),
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
          // Layer 5: UA logo — hero → final
          // ─────────────────────────────────────────
          AnimatedBuilder(
            animation: _uaProgress,
            builder: (context, child) {
              final t = _uaProgress.value;
              if (t <= 0) return const SizedBox.shrink();

              const fadeEnd = 0.19;
              final opacity = t < fadeEnd ? t / fadeEnd : 1.0;

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
                  const Alignment(0.25, 0.85),
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
        ],
      ),
    );
  }
}

/// Partner logos fade + slight scale in as a single row (no extra hero acts).
class _AnimatedPartnerRow extends AnimatedWidget {
  const _AnimatedPartnerRow({required super.listenable});

  Animation<double> get progress => listenable as Animation<double>;

  static const _logos = [
    'assets/images/icons/hryo.png',
    'assets/images/icons/our-common-future-logo-dark-bg__1_-removebg-preview.png',
    'assets/images/icons/academy_culture.png',
  ];

  @override
  Widget build(BuildContext context) {
    final t = progress.value;
    if (t <= 0) return const SizedBox.shrink();

    final opacity = t < 0.35 ? t / 0.35 : 1.0;
    final scale = 0.92 + (0.08 * t);

    return Align(
      alignment: const Alignment(0, 0.45),
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var i = 0; i < _logos.length; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: _StaggeredPartnerLogo(
                        assetPath: _logos[i],
                        progress: t,
                        // ~80ms stagger feel without extending total duration
                        delay: i * 0.12,
                        // Left + middle larger than Academy Culture
                        height: i == 0 ? 64 : (i == 1 ? 64 : 44),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StaggeredPartnerLogo extends StatelessWidget {
  const _StaggeredPartnerLogo({
    required this.assetPath,
    required this.progress,
    required this.delay,
    required this.height,
  });

  final String assetPath;
  final double progress;
  final double delay;
  final double height;

  @override
  Widget build(BuildContext context) {
    final localT = ((progress - delay) / (1.0 - delay)).clamp(0.0, 1.0);
    final opacity = localT < 0.4 ? localT / 0.4 : 1.0;

    return Opacity(
      opacity: opacity,
      child: Image.asset(assetPath, height: height, fit: BoxFit.contain),
    );
  }
}

/// EU funded icon that slides down from above to its final position.
class _AnimatedEuLogo extends AnimatedWidget {
  const _AnimatedEuLogo({
    required super.listenable,
    required this.isEnglish,
  });

  final bool isEnglish;

  Animation<double> get progress => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    final t = progress.value;
    if (t <= 0) return const SizedBox.shrink();

    final dy = (1.0 - t) * -2.0;
    final opacity = t < 0.3 ? t / 0.3 : 1.0;
    final asset = isEnglish
        ? 'assets/images/icons/co-funded-by-eu-logo-en.png'
        : 'assets/images/icons/co-funded-by-eu-logo-tr.png';

    return FractionalTranslation(
      translation: Offset(0, dy),
      child: Opacity(
        opacity: opacity,
        child: Align(
          alignment: const Alignment(0, 0.72),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Image.asset(
              asset,
              height: 48,
              width: double.infinity,
              fit: BoxFit.contain,
              alignment: Alignment.center,
            ),
          ),
        ),
      ),
    );
  }
}
