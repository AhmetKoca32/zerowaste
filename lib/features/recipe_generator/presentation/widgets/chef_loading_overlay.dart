import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// "Chef is cooking..." loader with animated dots.
class ChefLoadingOverlay extends StatefulWidget {
  const ChefLoadingOverlay({super.key});

  @override
  State<ChefLoadingOverlay> createState() => _ChefLoadingOverlayState();
}

class _ChefLoadingOverlayState extends State<ChefLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int _dotCount = 0;
  Timer? _dotTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _dotTimer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      if (mounted) setState(() => _dotCount = (_dotCount + 1) % 4);
    });
  }

  @override
  void dispose() {
    _dotTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.paper.withOpacity(0.95),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.mint.withOpacity(0.5),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.fern.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.restaurant_menu,
                      size: 56,
                      color: AppColors.forest,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),
            Text(
              'Şef pişiriyor',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.forest,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '${'.' * _dotCount}   ',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.fern,
                    letterSpacing: 2,
                  ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 160,
              child: LinearProgressIndicator(
                backgroundColor: AppColors.cream,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.fern),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
