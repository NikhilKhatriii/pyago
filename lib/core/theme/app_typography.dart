import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography system for Pyago.
///
/// Three type families are used intentionally:
///
/// 1. [Playfair Display] — an elegant, high-contrast serif for display
///    headlines, article titles, and hero text. This gives Pyago its
///    premium editorial identity.
///
/// 2. [Inter] — a neutral grotesque for interface chrome, body text,
///    labels, and navigation.
///
/// 3. [Merriweather] — a warm, readable serif reserved for long-form
///    reading surfaces (journals, articles, poetry body text).
///
/// This split gives written content a distinct, literary identity
/// separate from the app shell around it.
class AppTypography {
  const AppTypography._();

  /// The primary UI text theme based on Inter — used for all interface
  /// elements, body copy, labels, and navigation.
  static TextTheme uiTextTheme(Color color) {
    final base = GoogleFonts.interTextTheme();
    return base
        .copyWith(
          displayLarge: GoogleFonts.playfairDisplay(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            height: 1.1,
            letterSpacing: -1.5,
          ),
          displayMedium: GoogleFonts.playfairDisplay(
            fontSize: 38,
            fontWeight: FontWeight.w700,
            height: 1.12,
            letterSpacing: -1.0,
          ),
          displaySmall: GoogleFonts.playfairDisplay(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            height: 1.15,
            letterSpacing: -0.5,
          ),
          headlineLarge: GoogleFonts.playfairDisplay(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            height: 1.2,
            letterSpacing: -0.3,
          ),
          headlineMedium: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            height: 1.25,
          ),
          headlineSmall: base.headlineSmall?.copyWith(
              fontSize: 18, fontWeight: FontWeight.w600, height: 1.3),
          titleLarge: base.titleLarge?.copyWith(
              fontSize: 17, fontWeight: FontWeight.w600, height: 1.3),
          titleMedium: base.titleMedium?.copyWith(
              fontSize: 15, fontWeight: FontWeight.w600, height: 1.35),
          titleSmall: base.titleSmall?.copyWith(
              fontSize: 13, fontWeight: FontWeight.w600, height: 1.35),
          bodyLarge: base.bodyLarge?.copyWith(
              fontSize: 16, fontWeight: FontWeight.w400, height: 1.6),
          bodyMedium: base.bodyMedium?.copyWith(
              fontSize: 14, fontWeight: FontWeight.w400, height: 1.55),
          bodySmall: base.bodySmall?.copyWith(
              fontSize: 12, fontWeight: FontWeight.w400, height: 1.5),
          labelLarge: base.labelLarge?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.3,
              letterSpacing: 0.5),
          labelMedium: base.labelMedium?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.3,
              letterSpacing: 0.8),
          labelSmall: base.labelSmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              height: 1.3,
              letterSpacing: 1.0),
        )
        .apply(bodyColor: color, displayColor: color);
  }

  /// Serif display style for article titles, hero text, and literary
  /// content surfaces. Uses Playfair Display.
  static TextStyle serifDisplay({
    required Color color,
    double fontSize = 28,
    FontWeight fontWeight = FontWeight.w700,
    double height = 1.2,
    double letterSpacing = -0.5,
  }) {
    return GoogleFonts.playfairDisplay(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Serif reading style for long-form content body text.
  /// Uses Merriweather for optimal reading comfort.
  static TextStyle displaySerif({
    required Color color,
    double fontSize = 17,
    FontWeight fontWeight = FontWeight.w400,
    double height = 1.7,
  }) {
    return GoogleFonts.merriweather(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
    );
  }

  /// Small uppercase label style — used for section headers like
  /// "CHAPTER 01 — PERCEPTION" and "THE FEATURED MASTERPIECE".
  static TextStyle sectionLabel({
    required Color color,
    double fontSize = 11,
  }) {
    return GoogleFonts.inter(
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      height: 1.3,
      letterSpacing: 2.0,
    );
  }
}
