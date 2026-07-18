import 'package:flutter/material.dart';

/// Elevation / shadow system. Warm, violet-tinted shadows give Pyago a
/// premium editorial aesthetic distinct from default Material's gray.
class AppElevation {
  const AppElevation._();

  /// Resting card shadow — subtle and warm.
  static List<BoxShadow> cardResting(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return [
      BoxShadow(
        color: (isDark ? Colors.black : const Color(0xFF4A3BC7))
            .withValues(alpha: isDark ? 0.25 : 0.06),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];
  }

  static List<BoxShadow> level1(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return [
      BoxShadow(
        color: (isDark ? Colors.black : const Color(0xFF4A3BC7))
            .withValues(alpha: isDark ? 0.35 : 0.08),
        blurRadius: 12,
        offset: const Offset(0, 3),
      ),
    ];
  }

  static List<BoxShadow> level2(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return [
      BoxShadow(
        color: (isDark ? Colors.black : const Color(0xFF4A3BC7))
            .withValues(alpha: isDark ? 0.45 : 0.12),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ];
  }

  static List<BoxShadow> level3(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return [
      BoxShadow(
        color: (isDark ? Colors.black : const Color(0xFF4A3BC7))
            .withValues(alpha: isDark ? 0.55 : 0.16),
        blurRadius: 40,
        offset: const Offset(0, 16),
      ),
    ];
  }
}
