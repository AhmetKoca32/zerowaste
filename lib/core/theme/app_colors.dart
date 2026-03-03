import 'package:flutter/material.dart';

/// Nature-friendly palette: pastel greens and earth tones.
/// Brand palette (main app colors) is defined below; apply in theme when needed.
abstract final class AppColors {
  AppColors._();

  // ----- Brand / Primary palette (ana renk paleti) -----
  /// Turuncu - #ed6826
  static const Color brandOrange = Color(0xFFED6826);
  /// Krem / sarımsı beyaz - #ffffcc
  static const Color brandCream = Color(0xFFFFFFCC);
  /// Siyah (PANTONE BLACK) - #000000
  static const Color brandBlack = Color(0xFF000000);
  /// Beyaz - #ffffff
  static const Color brandWhite = Color(0xFFFFFFFF);

  // ----- Brand secondary / helper (ana yardımcı renkler, opaklıklı) -----
  /// #ed6826 @ 84%
  static const Color brandOrange84 = Color(0xD6ED6826);
  /// #ed6826 @ 70%
  static const Color brandOrange70 = Color(0xB3ED6826);
  /// #ffffcc @ 84%
  static const Color brandCream84 = Color(0xD6FFFFCC);
  /// #ffffcc @ 70%
  static const Color brandCream70 = Color(0xB3FFFFCC);
  /// #000000 @ 84%
  static const Color brandBlack84 = Color(0xD6000000);
  /// #000000 @ 70%
  static const Color brandBlack70 = Color(0xB3000000);

  // ----- Extended palette (21 renk, kullanıma hazır) -----
  static const Color paletteLightGreen = Color(0xFFC9DA2B);
  static const Color paletteBrightYellow = Color(0xFFFFCC00);
  static const Color paletteDarkBrown = Color(0xFF240201);
  static const Color paletteSkyBlue = Color(0xFF46A9DD);
  static const Color paletteOrangeRed = Color(0xFFEF4E23);
  static const Color paletteDarkPurple = Color(0xFF663399);
  static const Color paletteMediumGray = Color(0xFF7C7C7C);
  static const Color paletteForestGreen = Color(0xFF4C8C41);
  static const Color paletteGoldenYellow = Color(0xFFFFD146);
  static const Color paletteReddishBrown = Color(0xFF924D38);
  static const Color paletteTealMint = Color(0xFF60C3B0);
  static const Color paletteBurntOrange = Color(0xFFC94A30);
  static const Color paletteMediumPurple = Color(0xFF8F5391);
  static const Color paletteLightGray = Color(0xFFC1C1C1);
  static const Color paletteOliveGreen = Color(0xFF7F8033);
  static const Color palettePaleYellow = Color(0xFFFFCB67);
  static const Color paletteLightBrown = Color(0xFFDDA97A);
  static const Color paletteSlateGreen = Color(0xFF629085);
  static const Color paletteMutedRed = Color(0xFFCC6666);
  static const Color paletteGrayishPurple = Color(0xFF7C637C);
  static const Color paletteOffWhite = Color(0xFFEDEAE6);

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
