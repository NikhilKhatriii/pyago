import 'package:flutter/material.dart';

/// Central color system for Pyago.
///
/// Pyago's palette is deliberately quiet: a single accent ("ink violet")
/// carries all emphasis, while the rest of the interface stays neutral
/// so that user-generated content — words, images, voice — remains the
/// visual focus.
class AppColors {
  const AppColors._();

  // Brand
  static const Color brandPrimary = Color(0xFF5B4EF2);
  static const Color brandPrimaryLight = Color(0xFF8B82FF);
  static const Color brandPrimaryDark = Color(0xFF3A2FC4);
  static const Color brandAccent = Color(0xFFF2734E);

  // Light theme neutrals
  static const Color lightBackground = Color(0xFFFBFAF9);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF2F1EF);
  static const Color lightBorder = Color(0xFFE6E4E1);
  static const Color lightTextPrimary = Color(0xFF1B1A1F);
  static const Color lightTextSecondary = Color(0xFF63616B);
  static const Color lightTextTertiary = Color(0xFF9C9AA3);

  // Dark theme neutrals
  static const Color darkBackground = Color(0xFF0E0D12);
  static const Color darkSurface = Color(0xFF17161C);
  static const Color darkSurfaceVariant = Color(0xFF201F26);
  static const Color darkBorder = Color(0xFF302E38);
  static const Color darkTextPrimary = Color(0xFFF5F4F7);
  static const Color darkTextSecondary = Color(0xFFB3B1BB);
  static const Color darkTextTertiary = Color(0xFF7B7983);

  // Semantic
  static const Color success = Color(0xFF2FA76A);
  static const Color warning = Color(0xFFE0A22B);
  static const Color error = Color(0xFFE0503C);
  static const Color info = Color(0xFF3E8DE0);

  // High-contrast overrides
  static const Color highContrastLightText = Color(0xFF000000);
  static const Color highContrastDarkText = Color(0xFFFFFFFF);
  static const Color highContrastLightBg = Color(0xFFFFFFFF);
  static const Color highContrastDarkBg = Color(0xFF000000);

  /// Color-blind friendly categorical palette (Okabe–Ito derived),
  /// used for tags, charts, and content-type indicators.
  static const List<Color> categorical = [
    Color(0xFF5B4EF2),
    Color(0xFFE0503C),
    Color(0xFF2FA76A),
    Color(0xFFE0A22B),
    Color(0xFF3E8DE0),
    Color(0xFF9C6EDC),
  ];
}
