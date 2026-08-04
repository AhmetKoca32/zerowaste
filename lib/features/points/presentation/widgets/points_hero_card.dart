import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:zerowaste/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../utils/points_levels.dart';
import 'level_up_stepper.dart';

/// Hero card with three animation modes:
///
/// **Normal mode**: progress + counter within the current level (up or down).
/// **Level-up**: horizontal stepper previous → new role, points count up.
/// **Level-down**: reverse stepper + points count down, then settle.
class PointsHeroCard extends StatefulWidget {
  const PointsHeroCard({
    super.key,
    this.totalPoints = 0,
    this.previousPoints,
    this.onJourneyComplete,
    this.onAnimationComplete,
    this.startAnimation = true,
    this.nickname,
    this.onOptOut,
  });

  final int totalPoints;

  /// Set this only when admin approved a post and points changed.
  /// If the level boundary was crossed, the stepper journey plays.
  final int? previousPoints;
  final VoidCallback? onJourneyComplete;
  final VoidCallback? onAnimationComplete;

  /// Controls when the progress animations begin.
  final bool startAnimation;

  /// User's display name shown at the top of the card.
  final String? nickname;

  /// Called when the user taps the opt-out (leave contest) button.
  final VoidCallback? onOptOut;

  @override
  State<PointsHeroCard> createState() => _PointsHeroCardState();
}

class _PointsHeroCardState extends State<PointsHeroCard>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  AnimationController? _activeProgressController;

  late PointsLevel _currentLevel;
  late int _currentLevelIdx;
  int _prevLevelIdx = 0;

  int _displayLevelIdx = 0;
  double _displayProgress = 0.0;
  double _displayPoints = 0.0;

  bool _hasLevelUp = false;
  bool _hasLevelDown = false;
  bool _showStepper = false;
  bool _stepperReverse = false;
  bool _isAnimating = false;
  bool _isDisposed = false;

  Completer<void>? _stepperCompleter;

  @override
  void initState() {
    super.initState();

    _currentLevel = pointsLevelForPoints(widget.totalPoints);
    _currentLevelIdx = pointsLevelIndex(widget.totalPoints);

    final prevPts = widget.previousPoints;
    _prevLevelIdx =
        prevPts != null ? pointsLevelIndex(prevPts) : _currentLevelIdx;
    _hasLevelUp = prevPts != null && _prevLevelIdx < _currentLevelIdx;
    _hasLevelDown = prevPts != null && _prevLevelIdx > _currentLevelIdx;

    if (widget.startAnimation) {
      _displayPoints = (prevPts ?? _currentLevel.minPoints).toDouble();
      _displayLevelIdx = _prevLevelIdx;
    } else {
      _displayPoints = widget.totalPoints.toDouble();
      _displayLevelIdx = _currentLevelIdx;
      final range =
          (_currentLevel.maxPoints - _currentLevel.minPoints).clamp(1, 999999);
      _displayProgress =
          ((widget.totalPoints - _currentLevel.minPoints) / range)
              .clamp(0.0, 1.0);
    }

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();

    if (widget.startAnimation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isAnimating) _triggerAnimations();
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _fadeController.dispose();
    _activeProgressController?.dispose();
    if (_stepperCompleter != null && !_stepperCompleter!.isCompleted) {
      _stepperCompleter!.complete();
    }
    super.dispose();
  }

  void _disposeActiveController() {
    _activeProgressController?.dispose();
    _activeProgressController = null;
  }

  @override
  void didUpdateWidget(PointsHeroCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.startAnimation && widget.startAnimation) {
      _currentLevel = pointsLevelForPoints(widget.totalPoints);
      _currentLevelIdx = pointsLevelIndex(widget.totalPoints);
      final prevPts = widget.previousPoints;
      _prevLevelIdx =
          prevPts != null ? pointsLevelIndex(prevPts) : _currentLevelIdx;
      _hasLevelUp = prevPts != null && _prevLevelIdx < _currentLevelIdx;
      _hasLevelDown = prevPts != null && _prevLevelIdx > _currentLevelIdx;
      _triggerAnimations();
    }
  }

  void _triggerAnimations() {
    if (_isAnimating || _isDisposed) return;

    if (_hasLevelUp) {
      _startLevelChangeStepper(reverse: false);
    } else if (_hasLevelDown) {
      _startLevelChangeStepper(reverse: true);
    } else {
      _startNormalAnimation();
    }
  }

  Future<void> _startNormalAnimation() async {
    if (_isAnimating || _isDisposed) return;
    _isAnimating = true;

    _currentLevel = pointsLevelForPoints(widget.totalPoints);
    _currentLevelIdx = pointsLevelIndex(widget.totalPoints);
    final prevPts = widget.previousPoints ?? _currentLevel.minPoints;

    // Same-level change may cross minPoints of current level for display;
    // clamp progress into the destination level's range.
    final range =
        (_currentLevel.maxPoints - _currentLevel.minPoints).clamp(1, 999999);
    final fromProgress =
        ((prevPts - _currentLevel.minPoints) / range).clamp(0.0, 1.0);
    final targetProgress =
        ((widget.totalPoints - _currentLevel.minPoints) / range)
            .clamp(0.0, 1.0);

    setState(() {
      _showStepper = false;
      _displayPoints = prevPts.toDouble();
      _displayProgress = fromProgress;
      _displayLevelIdx = _currentLevelIdx;
    });

    await _animateProgress(
      fromProgress: fromProgress,
      toProgress: targetProgress,
      fromPoints: prevPts.toDouble(),
      toPoints: widget.totalPoints.toDouble(),
      durationMs: 1200,
    );

    _isAnimating = false;
    if (mounted && !_isDisposed) {
      widget.onAnimationComplete?.call();
    }
  }

  /// Level-up or level-down: stepper + points tween, then settle to ring.
  Future<void> _startLevelChangeStepper({required bool reverse}) async {
    if (_isAnimating || _isDisposed || !mounted) return;
    _isAnimating = true;

    final prevPts =
        widget.previousPoints ?? pointsLevels[_prevLevelIdx].minPoints;
    _stepperCompleter = Completer<void>();

    setState(() {
      _showStepper = true;
      _stepperReverse = reverse;
      _displayLevelIdx = _prevLevelIdx;
      _displayPoints = prevPts.toDouble();
      _displayProgress = 0.0;
    });

    await Future.wait<void>([
      _animateProgress(
        fromProgress: 0,
        toProgress: 0,
        fromPoints: prevPts.toDouble(),
        toPoints: widget.totalPoints.toDouble(),
        durationMs: 1100,
      ),
      _stepperCompleter!.future,
    ]);

    if (!mounted || _isDisposed) return;

    final range =
        (_currentLevel.maxPoints - _currentLevel.minPoints).clamp(1, 999999);
    final finalProgress =
        ((widget.totalPoints - _currentLevel.minPoints) / range)
            .clamp(0.0, 1.0);

    setState(() {
      _showStepper = false;
      _displayLevelIdx = _currentLevelIdx;
      _displayPoints = widget.totalPoints.toDouble();
      _displayProgress = reverse ? 1.0 : 0.0;
    });

    await _animateProgress(
      fromProgress: reverse ? 1.0 : 0.0,
      toProgress: finalProgress,
      fromPoints: widget.totalPoints.toDouble(),
      toPoints: widget.totalPoints.toDouble(),
      durationMs: 700,
    );

    _isAnimating = false;
    if (mounted && !_isDisposed) {
      widget.onJourneyComplete?.call();
    }
  }

  void _onStepperComplete() {
    final completer = _stepperCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
  }

  Future<void> _animateProgress({
    required double fromProgress,
    required double toProgress,
    required double fromPoints,
    required double toPoints,
    required int durationMs,
  }) async {
    _disposeActiveController();
    if (!mounted || _isDisposed) return;

    _activeProgressController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    );

    final progressTween = Tween<double>(begin: fromProgress, end: toProgress);
    final pointsTween = Tween<double>(begin: fromPoints, end: toPoints);
    final curved = CurvedAnimation(
      parent: _activeProgressController!,
      curve: Curves.easeInOut,
    );

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
      // Cancelled on dispose.
    } finally {
      if (mounted) {
        _activeProgressController?.removeListener(listener);
        _activeProgressController?.dispose();
        _activeProgressController = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayLevel = pointsLevels[_displayLevelIdx];
    final nextLevelIdx = _currentLevelIdx + 1;
    final nextLevel =
        nextLevelIdx < pointsLevels.length ? pointsLevels[nextLevelIdx] : null;

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
                if (widget.nickname != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_rounded,
                          size: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.nickname!,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (!_showStepper) ...[
                  _buildTopRow(displayLevel),
                  const SizedBox(height: 20),
                  _buildCircularProgress(),
                  const SizedBox(height: 16),
                  _buildBottomInfo(nextLevel),
                ] else ...[
                  Text(
                    _stepperReverse
                        ? localizedPointsLevelName(
                            context,
                            pointsLevels[_currentLevelIdx].name,
                          )
                        : AppLocalizations.of(context)!.pointsLevelUpTitle,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.95),
                    ),
                  ),
                  const SizedBox(height: 16),
                  LevelUpStepper(
                    key: ValueKey(
                      'stepper-$_prevLevelIdx-$_currentLevelIdx-$_stepperReverse',
                    ),
                    fromLevelIdx: _prevLevelIdx,
                    toLevelIdx: _currentLevelIdx,
                    reverse: _stepperReverse,
                    onComplete: _onStepperComplete,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _displayPoints.toInt().toString(),
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -1,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.pointsUnit,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
            Positioned(
              top: 0,
              left: 0,
              child: GestureDetector(
                onTap: _showLevelsSheet,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ),
            if (widget.onOptOut != null)
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: widget.onOptOut,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Icon(
                      Icons.logout_rounded,
                      size: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showLevelsSheet() {
    final l10n = AppLocalizations.of(context)!;
    final currentIdx = pointsLevelIndex(widget.totalPoints);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.stone.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.pointsLevelsGuideTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.pointsLevelsGuideSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    color: AppColors.inkLight.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(ctx).height * 0.55,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: pointsLevels.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final level = pointsLevels[index];
                      final isCurrent = index == currentIdx;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? level.color.withOpacity(0.12)
                              : AppColors.paper.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isCurrent
                                ? level.color.withOpacity(0.55)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(level.emoji,
                                style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    localizedPointsLevelName(
                                        context, level.name),
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: isCurrent
                                          ? level.color
                                          : AppColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${pointsLevelRangeLabel(level)} ${l10n.pointsUnit}',
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 12,
                                      color:
                                          AppColors.inkLight.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isCurrent)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: level.color,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  l10n.pointsLevelsCurrentBadge,
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopRow(PointsLevel level) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
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
                  localizedPointsLevelName(context, level.name),
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
            child: CustomPaint(
              painter: _BackgroundRingPainter(strokeWidth: 10),
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
                AppLocalizations.of(context)!.pointsUnit,
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

  Widget _buildBottomInfo(PointsLevel? nextLevel) {
    if (nextLevel != null) {
      return Text(
        AppLocalizations.of(context)!.pointsNextLevel(
          nextLevel.emoji,
          localizedPointsLevelName(context, nextLevel.name),
          nextLevel.minPoints - widget.totalPoints,
        ),
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
      AppLocalizations.of(context)!.pointsMaxLevel,
      style: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.white.withOpacity(0.9),
      ),
    );
  }
}

class _BackgroundRingPainter extends CustomPainter {
  _BackgroundRingPainter({required this.strokeWidth});

  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(
      size.center(Offset.zero),
      size.width / 2 - strokeWidth / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(_BackgroundRingPainter oldDelegate) => false;
}

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
