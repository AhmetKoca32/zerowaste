import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/points_levels.dart';

/// Compact horizontal level stepper shown inside the hero card.
///
/// Nodes are always low→high left-to-right.
/// - Level-up ([reverse] false): connectors fill left→right, pulse new (right) role.
/// - Level-down ([reverse] true): connectors start full and drain right→left,
///   pulse new (left) role.
class LevelUpStepper extends StatefulWidget {
  const LevelUpStepper({
    super.key,
    required this.fromLevelIdx,
    required this.toLevelIdx,
    this.reverse = false,
    this.onComplete,
  });

  final int fromLevelIdx;
  final int toLevelIdx;

  /// When true, drain from the higher role down to the lower role.
  final bool reverse;
  final VoidCallback? onComplete;

  @override
  State<LevelUpStepper> createState() => _LevelUpStepperState();
}

class _LevelUpStepperState extends State<LevelUpStepper>
    with TickerProviderStateMixin {
  late AnimationController _fillController;
  late AnimationController _pulseController;
  late Animation<double> _fillAnimation;
  late Animation<double> _pulseAnimation;

  late final List<int> _indices;
  late final int _targetLocalIdx;

  @override
  void initState() {
    super.initState();
    final from = widget.fromLevelIdx.clamp(0, pointsLevels.length - 1);
    final to = widget.toLevelIdx.clamp(0, pointsLevels.length - 1);
    final lo = math.min(from, to);
    final hi = math.max(from, to);

    // Always ascending on screen: Çaylak … İkon
    _indices = [
      for (var i = lo; i <= hi; i++) i,
    ];
    if (_indices.isEmpty) {
      _indices.add(to);
    }

    // Destination role after the change.
    _targetLocalIdx = widget.reverse ? 0 : _indices.length - 1;

    _fillController = AnimationController(
      vsync: this,
      duration:
          Duration(milliseconds: 700 + (_indices.length - 1).clamp(0, 4) * 180),
    );
    _fillAnimation = CurvedAnimation(
      parent: _fillController,
      curve: Curves.easeInOutCubic,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.22), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.22, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOutCubic,
    ));

    _run();
  }

  Future<void> _run() async {
    await _fillController.forward();
    if (!mounted) return;
    await _pulseController.forward();
    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 280));
    if (!mounted) return;
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _fillController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = _indices.length > 4;
    final reverse = widget.reverse;
    final n = _indices.length;
    final segmentCount = (n - 1).clamp(1, 99);

    return AnimatedBuilder(
      animation: Listenable.merge([_fillAnimation, _pulseAnimation]),
      builder: (context, _) {
        final moved = _fillAnimation.value * segmentCount;

        return SizedBox(
          height: compact ? 78 : 88,
          child: Row(
            children: [
              for (var i = 0; i < n; i++) ...[
                if (i > 0)
                  Expanded(
                    child: _Connector(
                      // Level-up: fill L→R. Level-down: drain R→L.
                      progress: reverse
                          ? (1.0 -
                                  (moved - (segmentCount - i)).clamp(0.0, 1.0))
                              .clamp(0.0, 1.0)
                          : (moved - (i - 1)).clamp(0.0, 1.0),
                      muted: reverse,
                    ),
                  ),
                _StepNode(
                  level: pointsLevels[_indices[i]],
                  isTarget: i == _targetLocalIdx,
                  // Higher roles drop first when draining right→left.
                  lost: reverse && i > _targetLocalIdx && moved >= (n - i),
                  reached: reverse
                      ? !(i > _targetLocalIdx && moved >= (n - i))
                      : moved >= i || i == 0,
                  compact: compact && i != 0 && i != n - 1,
                  pulseScale: i == _targetLocalIdx &&
                          (_pulseController.isAnimating ||
                              _pulseController.isCompleted)
                      ? _pulseAnimation.value
                      : 1.0,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector({
    required this.progress,
    this.muted = false,
  });

  final double progress;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final fillColor = muted ? Colors.white.withOpacity(0.55) : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: SizedBox(
        height: 3,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: fillColor.withOpacity(0.45),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepNode extends StatelessWidget {
  const _StepNode({
    required this.level,
    required this.isTarget,
    required this.reached,
    required this.compact,
    required this.pulseScale,
    this.lost = false,
  });

  final PointsLevel level;
  final bool isTarget;
  final bool reached;
  final bool compact;
  final bool lost;
  final double pulseScale;

  @override
  Widget build(BuildContext context) {
    final name = localizedPointsLevelName(context, level.name);
    final size = compact ? 34.0 : 44.0;
    final active = reached && !lost;

    return Transform.scale(
      scale: pulseScale,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: active
                  ? Colors.white.withOpacity(isTarget ? 0.28 : 0.18)
                  : Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: active
                    ? Colors.white.withOpacity(isTarget ? 1.0 : 0.7)
                    : Colors.white.withOpacity(0.25),
                width: isTarget ? 2.2 : 1.4,
              ),
              boxShadow: isTarget && active
                  ? [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.35),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: lost
                  ? Icon(
                      Icons.close_rounded,
                      size: compact ? 16 : 20,
                      color: Colors.white.withOpacity(0.55),
                    )
                  : Text(
                      level.emoji,
                      style: TextStyle(
                        fontSize: compact ? 14 : 18,
                        color: active ? null : Colors.white.withOpacity(0.45),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          if (!compact)
            SizedBox(
              width: 64,
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: isTarget ? 11.5 : 10.5,
                  fontWeight: isTarget ? FontWeight.w800 : FontWeight.w600,
                  color: Colors.white.withOpacity(active ? 0.95 : 0.45),
                  height: 1.1,
                  decoration: lost ? TextDecoration.lineThrough : null,
                  decorationColor: Colors.white.withOpacity(0.45),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
