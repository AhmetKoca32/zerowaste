import 'package:flutter/material.dart';

import 'package:zerowaste/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';

/// Gamification level definition.
class PointsLevel {
  const PointsLevel({
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

/// Gaps grow each step: +50 → +100 → +150 → +200 → +300 → +400
const pointsLevels = [
  PointsLevel(name: 'Çaylak',   emoji: '🌱', minPoints: 0,    maxPoints: 50,     color: Color(0xFFA5D6A7)),
  PointsLevel(name: 'Meraklı',  emoji: '🌿', minPoints: 50,   maxPoints: 150,    color: Color(0xFF66BB6A)),
  PointsLevel(name: 'Usta',     emoji: '🌳', minPoints: 150,  maxPoints: 300,    color: AppColors.brandOrange),
  PointsLevel(name: 'Uzman',    emoji: '🔥', minPoints: 300,  maxPoints: 500,    color: Color(0xFFFF8A65)),
  PointsLevel(name: 'Efsane',   emoji: '🏆', minPoints: 500,  maxPoints: 800,    color: Color(0xFFFF6F00)),
  PointsLevel(name: 'Şampiyon', emoji: '⭐', minPoints: 800,  maxPoints: 1200,   color: Color(0xFFFFB300)),
  PointsLevel(name: 'İkon',     emoji: '🌍', minPoints: 1200, maxPoints: 999999, color: Color(0xFF26A69A)),
];

String localizedPointsLevelName(BuildContext context, String name) {
  final l10n = AppLocalizations.of(context)!;
  switch (name) {
    case 'Çaylak':
      return l10n.pointsLevelCaylak;
    case 'Meraklı':
      return l10n.pointsLevelMerakli;
    case 'Usta':
      return l10n.pointsLevelUsta;
    case 'Uzman':
      return l10n.pointsLevelUzman;
    case 'Efsane':
      return l10n.pointsLevelEfsane;
    case 'Şampiyon':
      return l10n.pointsLevelSampiyon;
    case 'İkon':
      return l10n.pointsLevelIkon;
    default:
      return name;
  }
}

String pointsLevelRangeLabel(PointsLevel level) {
  if (level.maxPoints >= 999999) {
    return '${level.minPoints}+';
  }
  return '${level.minPoints} – ${level.maxPoints - 1}';
}

PointsLevel pointsLevelForPoints(int points) {
  for (final level in pointsLevels.reversed) {
    if (points >= level.minPoints) return level;
  }
  return pointsLevels.first;
}

int pointsLevelIndex(int points) {
  for (int i = pointsLevels.length - 1; i >= 0; i--) {
    if (points >= pointsLevels[i].minPoints) return i;
  }
  return 0;
}
