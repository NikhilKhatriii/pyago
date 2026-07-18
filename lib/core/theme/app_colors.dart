import 'package:flutter/material.dart';

/// Central color system for Pyago.
///
/// The refined palette keeps Pyago's violet energy while adding editorial
/// warmth. A deeper indigo-violet primary carries all emphasis, paired
/// with a cyan "ink glow" accent. Neutrals shift warmer — cream-toned
/// light surfaces and violet-undertone dark surfaces — so user-generated
/// content feels embedded in a literary environment.
class AppColors {
  const AppColors._();

  // ── Brand ──────────────────────────────────────────────────────────────────
  static const Color brandPrimary = Color(0xFF4A3BC7);
  static const Color brandPrimaryLight = Color(0xFF7B6FE8);
  static const Color brandPrimaryDark = Color(0xFF2E2299);
  static const Color brandAccent = Color(0xFF00D4C8);

  // ── Editorial palette ──────────────────────────────────────────────────────
  /// Soft lavender mist — used for subtle brand-tinted backgrounds.
  static const Color lavenderMist = Color(0xFFE8E4F8);

  /// Warm ivory — primary light background.
  static const Color warmIvory = Color(0xFFFAF8F5);

  /// Parchment — secondary warm surface.
  static const Color parchment = Color(0xFFF5F2ED);

  /// Deep ink — rich near-black for display text.
  static const Color deepInk = Color(0xFF1A1726);

  // ── Brand gradient stops ───────────────────────────────────────────────────
  /// The signature gradient used in headers, hero sections, and CTAs.
  static const List<Color> brandGradient = [
    Color(0xFF4A3BC7),
    Color(0xFF6B5CE7),
    Color(0xFF8B7BFF),
  ];

  /// Reversed gradient for dark surfaces.
  static const List<Color> brandGradientDark = [
    Color(0xFF2E2299),
    Color(0xFF4A3BC7),
    Color(0xFF6B5CE7),
  ];

  /// Warm sunset gradient for featured content highlights.
  static const List<Color> heroGradient = [
    Color(0xFF4A3BC7),
    Color(0xFF6B5CE7),
    Color(0xFFB8ACF6),
  ];

  // ── Light theme neutrals ──────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFFAF8F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF5F2ED);
  static const Color lightBorder = Color(0xFFE8E4E0);
  static const Color lightTextPrimary = Color(0xFF1A1726);
  static const Color lightTextSecondary = Color(0xFF5D596B);
  static const Color lightTextTertiary = Color(0xFF9894A3);

  // ── Dark theme neutrals ───────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0E0D14);
  static const Color darkSurface = Color(0xFF17161E);
  static const Color darkSurfaceVariant = Color(0xFF211F2A);
  static const Color darkBorder = Color(0xFF322F3D);
  static const Color darkTextPrimary = Color(0xFFF5F3F8);
  static const Color darkTextSecondary = Color(0xFFB5B1C0);
  static const Color darkTextTertiary = Color(0xFF7D7990);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF2FA76A);
  static const Color warning = Color(0xFFE0A22B);
  static const Color error = Color(0xFFE0503C);
  static const Color info = Color(0xFF3E8DE0);

  // ── High-contrast overrides ───────────────────────────────────────────────
  static const Color highContrastLightText = Color(0xFF000000);
  static const Color highContrastDarkText = Color(0xFFFFFFFF);
  static const Color highContrastLightBg = Color(0xFFFFFFFF);
  static const Color highContrastDarkBg = Color(0xFF000000);

  /// Color-blind friendly categorical palette (Okabe–Ito derived),
  /// used for tags, charts, and content-type indicators.
  static const List<Color> categorical = [
    Color(0xFF4A3BC7),
    Color(0xFFE0503C),
    Color(0xFF2FA76A),
    Color(0xFFE0A22B),
    Color(0xFF3E8DE0),
    Color(0xFF9C6EDC),
  ];
}
