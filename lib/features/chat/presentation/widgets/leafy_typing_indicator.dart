import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// "Leafy is typing..." bubble with animated dots.
class LeafyTypingIndicator extends StatefulWidget {
  const LeafyTypingIndicator({super.key});

  @override
  State<LeafyTypingIndicator> createState() => _LeafyTypingIndicatorState();
}

class _LeafyTypingIndicatorState extends State<LeafyTypingIndicator> {
  int _dotCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      if (mounted) setState(() => _dotCount = (_dotCount + 1) % 4);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.brandCream,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.brandCream),
            ),
            child: const Icon(Icons.eco, color: AppColors.brandOrange, size: 22),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(color: AppColors.brandCream),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Leafy yazıyor',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.inkLight,
                        fontStyle: FontStyle.italic,
                      ),
                ),
                Text(
                  '.'.padRight(_dotCount + 1),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.inkLight,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
