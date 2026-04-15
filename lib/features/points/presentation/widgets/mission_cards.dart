import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// A single mission definition.
class Mission {
  const Mission({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.points,
    this.completed = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final int points;
  final bool completed;
}

/// Daily missions list with staggered entrance animation.
/// Each card shows a point badge, mission info, and a tappable action.
class MissionCardsSection extends StatefulWidget {
  const MissionCardsSection({
    super.key,
    required this.missions,
    required this.onMissionTap,
  });

  final List<Mission> missions;
  final ValueChanged<int> onMissionTap;

  @override
  State<MissionCardsSection> createState() => _MissionCardsSectionState();
}

class _MissionCardsSectionState extends State<MissionCardsSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();

    // Total duration covers all cards with stagger
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + widget.missions.length * 150),
    );

    _fadeAnimations = List.generate(widget.missions.length, (i) {
      final start = (i * 0.15).clamp(0.0, 0.7);
      final end = (start + 0.4).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOut),
      );
    });

    _slideAnimations = List.generate(widget.missions.length, (i) {
      final start = (i * 0.15).clamp(0.0, 0.7);
      final end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ));
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Row(
          children: [
            const Icon(Icons.flag_rounded, color: AppColors.brandOrange, size: 20),
            const SizedBox(width: 8),
            Text(
              'Günlük Görevler',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFamily: 'Manrope',
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Mission cards
        ...List.generate(widget.missions.length, (index) {
          final mission = widget.missions[index];
          return Padding(
            padding: EdgeInsets.only(bottom: index < widget.missions.length - 1 ? 12 : 0),
            child: FadeTransition(
              opacity: _fadeAnimations[index],
              child: SlideTransition(
                position: _slideAnimations[index],
                child: _MissionCard(
                  mission: mission,
                  onTap: () => widget.onMissionTap(index),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({
    required this.mission,
    required this.onTap,
  });

  final Mission mission;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: mission.completed ? null : onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: mission.completed
                ? AppColors.cream.withOpacity(0.6)
                : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: mission.completed
                  ? const Color(0xFF4CAF50).withOpacity(0.3)
                  : AppColors.brandOrange.withOpacity(0.15),
              width: 1,
            ),
            boxShadow: mission.completed
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // ── Point badge ──
              _PointBadge(
                points: mission.points,
                completed: mission.completed,
              ),
              const SizedBox(width: 14),

              // ── Mission info ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          mission.icon,
                          size: 18,
                          color: mission.completed
                              ? const Color(0xFF4CAF50)
                              : AppColors.brandOrange,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            mission.title,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: mission.completed
                                  ? AppColors.inkLight
                                  : AppColors.ink,
                              decoration: mission.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: AppColors.inkLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mission.subtitle,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.inkLight.withOpacity(
                          mission.completed ? 0.5 : 0.8,
                        ),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // ── Action / Check ──
              if (mission.completed)
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                )
              else
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.brandOrange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.brandOrange,
                    size: 18,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small badge showing the points reward for a mission.
class _PointBadge extends StatelessWidget {
  const _PointBadge({
    required this.points,
    required this.completed,
  });

  final int points;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: completed
            ? const LinearGradient(
                colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF9A56), AppColors.brandOrange],
              ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: (completed
                    ? const Color(0xFF4CAF50)
                    : AppColors.brandOrange)
                .withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (completed)
            const Icon(Icons.check_rounded, color: Colors.white, size: 22)
          else ...[
            Text(
              '+$points',
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1,
              ),
            ),
            const Text(
              '🌟',
              style: TextStyle(fontSize: 10, height: 1.3),
            ),
          ],
        ],
      ),
    );
  }
}
