import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Gamification level definition.
class _Level {
  const _Level({
    required this.name,
    required this.emoji,
    required this.minPoints,
    required this.maxPoints,
    required this.color,
  });

  final String name;
  final String emoji;
  final int minPoints;
  final int maxPoints; // exclusive — next level starts here
  final Color color;
}

const _levels = [
  _Level(name: 'Çaylak',    emoji: '🌱', minPoints: 0,    maxPoints: 50,   color: Color(0xFFA5D6A7)),
  _Level(name: 'Meraklı',   emoji: '🌿', minPoints: 50,   maxPoints: 150,  color: Color(0xFF66BB6A)),
  _Level(name: 'Usta',      emoji: '🌳', minPoints: 150,  maxPoints: 300,  color: AppColors.brandOrange),
  _Level(name: 'Efsane',    emoji: '🏆', minPoints: 300,  maxPoints: 600,  color: Color(0xFFFF6F00)),
  _Level(name: 'Efsane+',   emoji: '💎', minPoints: 600,  maxPoints: 999999, color: Color(0xFFFFD700)),
];

_Level _levelForPoints(int points) {
  for (final level in _levels.reversed) {
    if (points >= level.minPoints) return level;
  }
  return _levels.first;
}

int _levelIndex(int points) {
  for (int i = _levels.length - 1; i >= 0; i--) {
    if (points >= _levels[i].minPoints) return i;
  }
  return 0;
}

/// Hero card with two animation modes:
///
/// **Normal mode** (every page open):
///   Progress fills from 0 to current within the level.
///   Counter counts from level.minPoints to totalPoints.
///   Badge shows current level immediately.
///
/// **Level-up mode** (when [previousPoints] is set AND level changed):
///   Full multi-level journey from previous level through each completed
///   level with celebration overlays, ending at current progress.
class PointsHeroCard extends StatefulWidget {
  const PointsHeroCard({
    super.key,
    this.totalPoints = 0,
    this.streakDays = 0,
    this.previousPoints,
    this.onJourneyComplete,
    this.startAnimation = true,
  });

  final int totalPoints;
  final int streakDays;

  /// Set this only when admin approved a post and points changed.
  /// If the level boundary was crossed, the full journey animation plays.
  final int? previousPoints;
  final VoidCallback? onJourneyComplete;

  /// Controls when the progress animations begin.
  final bool startAnimation;

  @override
  State<PointsHeroCard> createState() => _PointsHeroCardState();
}

class _PointsHeroCardState extends State<PointsHeroCard>
    with TickerProviderStateMixin {
  // Fade-in
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Track active progress controllers to prevent ticker leaks
  AnimationController? _activeProgressController;

  late _Level _currentLevel;
  late int _currentLevelIdx;

  // Display state
  int _displayLevelIdx = 0;
  double _displayProgress = 0.0;
  double _displayPoints = 0.0;
  bool _showCelebration = false;
  String _celebrationText = '';
  double _celebrationOpacity = 0.0;
  double _celebrationScale = 0.0;

  bool _hasLevelUp = false;
  bool _isAnimating = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();

    _currentLevel = _levelForPoints(widget.totalPoints);
    _currentLevelIdx = _levelIndex(widget.totalPoints);

    final prevPts = widget.previousPoints;
    final prevIdx = prevPts != null ? _levelIndex(prevPts) : _currentLevelIdx;
    _hasLevelUp = prevPts != null && prevIdx < _currentLevelIdx;

    // Level-up: start from 0 (Çaylak). Normal: start at current level.
    _displayLevelIdx = _hasLevelUp ? 0 : _currentLevelIdx;
    _displayPoints = _hasLevelUp ? 0.0 : _currentLevel.minPoints.toDouble();

    // Fade-in happens immediately
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();

    // Small delay to let fade-in finish, then check startAnimation
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted && widget.startAnimation) {
        _triggerAnimations();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _fadeController.dispose();
    _activeProgressController?.dispose();
    super.dispose();
  }

  /// Safely disposes and clears the active progress controller.
  void _disposeActiveController() {
    _activeProgressController?.dispose();
    _activeProgressController = null;
  }

  @override
  void didUpdateWidget(PointsHeroCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If startAnimation flipped from false to true, trigger immediately.
    if (!oldWidget.startAnimation && widget.startAnimation) {
      _triggerAnimations();
    }
  }

  void _triggerAnimations() {
    if (_isAnimating || _isDisposed) return;

    if (_hasLevelUp) {
      _startLevelUpJourney(0);
    } else {
      _startNormalAnimation();
    }
  }

  /// Normal mode: simple progress fill within current level.
  Future<void> _startNormalAnimation() async {
    if (_isAnimating || _isDisposed) return;
    _isAnimating = true;

    final range = (_currentLevel.maxPoints - _currentLevel.minPoints).clamp(1, 999999);
    final targetProgress = ((widget.totalPoints - _currentLevel.minPoints) / range).clamp(0.0, 1.0);

    await _animateProgress(
      fromProgress: 0.0,
      toProgress: targetProgress,
      fromPoints: _currentLevel.minPoints.toDouble(),
      toPoints: widget.totalPoints.toDouble(),
      durationMs: 1200,
    );
    
    _isAnimating = false;
  }

  /// Level-up mode: full journey from previous level to current.
  Future<void> _startLevelUpJourney(int startIdx) async {
    if (_isAnimating || _isDisposed || !mounted) return;
    _isAnimating = true;

    for (int i = startIdx; i <= _currentLevelIdx; i++) {
      if (!mounted || _isDisposed) break;

      final level = _levels[i];
      final isCompleted = i < _currentLevelIdx;

      setState(() {
        _displayLevelIdx = i;
        _displayProgress = 0.0;
        _showCelebration = false;
      });

      double targetProgress;
      double fromPts;
      double toPts;

      if (isCompleted) {
        targetProgress = 1.0;
        fromPts = level.minPoints.toDouble();
        toPts = level.maxPoints.toDouble();
      } else {
        final range = (level.maxPoints - level.minPoints).clamp(1, 999999);
        targetProgress = ((widget.totalPoints - level.minPoints) / range).clamp(0.0, 1.0);
        fromPts = level.minPoints.toDouble();
        toPts = widget.totalPoints.toDouble();
      }

      await _animateProgress(
        fromProgress: 0.0,
        toProgress: targetProgress,
        fromPoints: fromPts,
        toPoints: toPts,
        durationMs: isCompleted ? 1200 : 1400,
      );

      if (isCompleted) {
        await _showLevelCelebration(level);
        if (!mounted || _isDisposed) break;
        await Future.delayed(const Duration(milliseconds: 400));
      }
    }

    _isAnimating = false;
    if (mounted && !_isDisposed) {
      widget.onJourneyComplete?.call();
    }
  }

  /// Smoothly animates progress bar and counter.
  Future<void> _animateProgress({
    required double fromProgress,
    required double toProgress,
    required double fromPoints,
    required double toPoints,
    required int durationMs,
  }) async {
    // Clean up any previous active controller before starting a new one
    _disposeActiveController();

    if (!mounted || _isDisposed) return;

    _activeProgressController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    );

    final progressTween = Tween<double>(begin: fromProgress, end: toProgress);
    final pointsTween = Tween<double>(begin: fromPoints, end: toPoints);
    final curved = CurvedAnimation(parent: _activeProgressController!, curve: Curves.easeInOut);

    void listener() {
      if (!mounted) return;
      setState(() {
        _displayProgress = progressTween.evaluate(curved);
        _displayPoints = pointsTween.evaluate(curved);
      });
    }

    _activeProgressController!.addListener(listener);
    
    try {
      await _activeProgressController!.forward().orCancel;
    } catch (_) {
      // Animation was cancelled (e.g. disposed)
    } finally {
      if (mounted) {
        _activeProgressController?.removeListener(listener);
        _activeProgressController?.dispose();
        _activeProgressController = null;
      }
    }
  }

  /// Shows a level-completed celebration overlay.
  Future<void> _showLevelCelebration(_Level level) async {
    if (!mounted) return;

    setState(() {
      _showCelebration = true;
      _celebrationText = '${level.name} ✓';
      _celebrationOpacity = 0.0;
      _celebrationScale = 0.0;
    });

    // Zoom in
    _activeProgressController?.dispose();
    if (!mounted) return;

    _activeProgressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    final showCurved = CurvedAnimation(parent: _activeProgressController!, curve: Curves.elasticOut);

    void showListener() {
      if (!mounted) return;
      setState(() {
        _celebrationOpacity = Curves.easeOut.transform(_activeProgressController!.value.clamp(0.0, 1.0));
        _celebrationScale = showCurved.value.clamp(0.0, 1.5);
      });
    }

    _activeProgressController!.addListener(showListener);
    
    try {
      await _activeProgressController!.forward().orCancel;
    } catch (_) {} finally {
      if (mounted) {
        _activeProgressController?.removeListener(showListener);
        _activeProgressController?.dispose();
        _activeProgressController = null;
      }
    }

    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;

    // Fade out
    _activeProgressController?.dispose();
    if (!mounted) return;
    
    _activeProgressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    void hideListener() {
      if (!mounted) return;
      setState(() {
        _celebrationOpacity = 1.0 - _activeProgressController!.value;
        _celebrationScale = 1.0 + (_activeProgressController!.value * 0.2);
      });
    }

    _activeProgressController!.addListener(hideListener);
    
    try {
      await _activeProgressController!.forward().orCancel;
    } catch (_) {}

    _disposeActiveController();

    if (!mounted || _isDisposed) return;
    setState(() => _showCelebration = false);
  }



  @override
  Widget build(BuildContext context) {
    final displayLevel = _levels[_displayLevelIdx];
    final nextLevelIdx = _currentLevelIdx + 1;
    final nextLevel = nextLevelIdx < _levels.length ? _levels[nextLevelIdx] : null;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.brandOrange,
              AppColors.brandOrange.withOpacity(0.85),
              const Color(0xFFFF8A50),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.brandOrange.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopRow(displayLevel),
                const SizedBox(height: 20),
                _buildCircularProgress(),
                const SizedBox(height: 16),
                _buildBottomInfo(nextLevel),
              ],
            ),
            if (_showCelebration)
              Positioned.fill(child: _buildCelebrationOverlay()),
          ],
        ),
      ),
    );
  }

  Widget _buildCelebrationOverlay() {
    final level = _levels[_displayLevelIdx];
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.25 * _celebrationOpacity),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Transform.scale(
            scale: _celebrationScale,
            child: Opacity(
              opacity: _celebrationOpacity.clamp(0.0, 1.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Opacity(
                    opacity: _celebrationOpacity,
                    child: Text(
                      '✨',
                      style: TextStyle(fontSize: 28 + (_celebrationScale * 8)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: level.color.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      _celebrationText,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: level.color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Opacity(
                    opacity: _celebrationOpacity,
                    child: const Text(
                      'Seviye tamamlandı!',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopRow(_Level level) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: Container(
            key: ValueKey(level.name),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(level.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  level.name,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.streakDays > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '${widget.streakDays} gün',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCircularProgress() {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 160,
            height: 160,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 10,
              strokeCap: StrokeCap.round,
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          SizedBox(
            width: 160,
            height: 160,
            child: Transform.rotate(
              angle: -math.pi / 2,
              child: CustomPaint(
                painter: _GradientArcPainter(
                  progress: _displayProgress,
                  strokeWidth: 10,
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _displayPoints.toInt().toString(),
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'puan',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInfo(_Level? nextLevel) {
    if (nextLevel != null) {
      return Text(
        '${nextLevel.emoji} ${nextLevel.name} seviyesine ${nextLevel.minPoints - widget.totalPoints} puan kaldı',
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.white.withOpacity(0.85),
        ),
        textAlign: TextAlign.center,
      );
    }
    return Text(
      '🏆 En yüksek seviyedesin!',
      style: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.white.withOpacity(0.9),
      ),
    );
  }
}

/// Custom painter for a gradient arc (white glowing progress).
class _GradientArcPainter extends CustomPainter {
  _GradientArcPainter({
    required this.progress,
    required this.strokeWidth,
  });

  final double progress;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final rect = Offset.zero & size;
    final sweepAngle = 2 * math.pi * progress;

    final gradient = SweepGradient(
      startAngle: 0,
      endAngle: sweepAngle,
      colors: [
        Colors.white.withOpacity(0.6),
        Colors.white.withOpacity(0.9),
        Colors.white,
      ],
      stops: const [0.0, 0.7, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect.deflate(strokeWidth / 2),
      0,
      sweepAngle,
      false,
      paint,
    );

    if (progress > 0.02) {
      final endAngle = sweepAngle;
      final radius = size.width / 2 - strokeWidth / 2;
      final endX = size.width / 2 + radius * math.cos(endAngle);
      final endY = size.height / 2 + radius * math.sin(endAngle);

      final glowPaint = Paint()
        ..color = Colors.white
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(endX, endY), strokeWidth / 2 + 2, glowPaint);

      final dotPaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(endX, endY), strokeWidth / 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_GradientArcPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
