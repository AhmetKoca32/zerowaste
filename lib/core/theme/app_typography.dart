import 'package:flutter/material.dart';

/// Manrope tipografi: Book (300), Regular (400), Medium (500), Bold (700).
/// Clean architecture: core/theme; sadece stil tanımları, kullanım feature/presentation katmanında.
abstract final class AppTextStyle {
  AppTextStyle._();

  static const String fontFamily = 'Manrope';

  // ----- Ağırlık sabitleri -----
  static const FontWeight book = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight bold = FontWeight.w700;

  // ----- Display -----
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontWeight: bold,
    fontSize: 32,
    height: 1.25,
    letterSpacing: -0.5,
  );
  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontWeight: bold,
    fontSize: 28,
    height: 1.3,
    letterSpacing: -0.25,
  );
  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontWeight: bold,
    fontSize: 24,
    height: 1.35,
  );

  // ----- Headline -----
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontWeight: medium,
    fontSize: 22,
    height: 1.3,
  );
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontWeight: medium,
    fontSize: 20,
    height: 1.35,
  );
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontWeight: medium,
    fontSize: 18,
    height: 1.4,
  );

  // ----- Title -----
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontWeight: medium,
    fontSize: 18,
    height: 1.4,
  );
  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontWeight: medium,
    fontSize: 16,
    height: 1.4,
    letterSpacing: 0.15,
  );
  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontWeight: medium,
    fontSize: 14,
    height: 1.45,
    letterSpacing: 0.1,
  );

  // ----- Body -----
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontWeight: regular,
    fontSize: 16,
    height: 1.5,
    letterSpacing: 0.5,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontWeight: regular,
    fontSize: 14,
    height: 1.45,
    letterSpacing: 0.25,
  );
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontWeight: regular,
    fontSize: 12,
    height: 1.5,
    letterSpacing: 0.4,
  );

  // ----- Label -----
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontWeight: medium,
    fontSize: 14,
    height: 1.45,
    letterSpacing: 0.1,
  );
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontWeight: medium,
    fontSize: 12,
    height: 1.4,
    letterSpacing: 0.5,
  );
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontWeight: book,
    fontSize: 11,
    height: 1.45,
    letterSpacing: 0.5,
  );
}
