import 'package:flutter/material.dart';

/// Nature-friendly palette: pastel greens and earth tones.
abstract final class AppColors {
  AppColors._();

  // ----- Pastel Greens -----
  static const Color sage = Color(0xFF9CAF88);
  static const Color mint = Color(0xFFB5D4B8);
  static const Color fern = Color(0xFF7D9B69);
  static const Color moss = Color(0xFF5C7A5C);
  static const Color forest = Color(0xFF3D5A3D);

  // ----- Earth Tones -----
  static const Color sand = Color(0xFFE8DCC4);
  static const Color stone = Color(0xFFC4B896);
  static const Color terracotta = Color(0xFFC17F59);
  static const Color clay = Color(0xFFA67B5B);
  static const Color bark = Color(0xFF6B5344);

  // ----- Neutrals -----
  static const Color cream = Color(0xFFF5F2EB);
  static const Color paper = Color(0xFFFDFBF7);
  static const Color ink = Color(0xFF2C2C2C);
  static const Color inkLight = Color(0xFF5A5A5A);
}
