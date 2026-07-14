import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography system for Pyago.
///
/// Two type families are used intentionally: [display] (a warm serif)
/// for long-form reading surfaces — journals, articles, poetry — and
/// [ui] (a neutral grotesque) for interface chrome. This split gives
/// written content a distinct, literary identity separate from the app
/// shell around it.
class AppTypography {
  const AppTypography._();

  static TextTheme uiTextTheme(Color color) {
    final base = GoogleFonts.interTextTheme();
    return base
        .copyWith(
          displayLarge: base.displayLarge?.copyWith(
              fontSize: 40, fontWeight: FontWeight.w700, height: 1.15),
          displayMedium: base.displayMedium?.copyWith(
              fontSize: 32, fontWeight: FontWeight.w700, height: 1.18),
          displaySmall: base.displaySmall?.copyWith(
              fontSize: 26, fontWeight: FontWeight.w700, height: 1.2),
          headlineLarge: base.headlineLarge?.copyWith(
              fontSize: 24, fontWeight: FontWeight.w700, height: 1.25),
          headlineMedium: base.headlineMedium?.copyWith(
              fontSize: 20, fontWeight: FontWeight.w600, height: 1.3),
          headlineSmall: base.headlineSmall?.copyWith(
              fontSize: 18, fontWeight: FontWeight.w600, height: 1.3),
          titleLarge: base.titleLarge?.copyWith(
              fontSize: 17, fontWeight: FontWeight.w600, height: 1.3),
          titleMedium: base.titleMedium?.copyWith(
              fontSize: 15, fontWeight: FontWeight.w600, height: 1.35),
          titleSmall: base.titleSmall?.copyWith(
              fontSize: 13, fontWeight: FontWeight.w600, height: 1.35),
          bodyLarge: base.bodyLarge?.copyWith(
              fontSize: 16, fontWeight: FontWeight.w400, height: 1.5),
          bodyMedium: base.bodyMedium?.copyWith(
              fontSize: 14, fontWeight: FontWeight.w400, height: 1.5),
          bodySmall: base.bodySmall?.copyWith(
              fontSize: 12, fontWeight: FontWeight.w400, height: 1.45),
          labelLarge: base.labelLarge?.copyWith(
              fontSize: 14, fontWeight: FontWeight.w600, height: 1.3),
          labelMedium: base.labelMedium?.copyWith(
              fontSize: 12, fontWeight: FontWeight.w600, height: 1.3),
          labelSmall: base.labelSmall?.copyWith(
              fontSize: 11, fontWeight: FontWeight.w600, height: 1.3),
        )
        .apply(bodyColor: color, displayColor: color);
  }

  static TextStyle displaySerif({
    required Color color,
    double fontSize = 22,
    FontWeight fontWeight = FontWeight.w500,
    double height = 1.4,
  }) {
    return GoogleFonts.merriweather(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
    );
  }
}
