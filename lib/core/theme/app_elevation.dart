import 'package:flutter/material.dart';

/// Elevation / shadow system. Kept subtle and warm rather than the
/// harsh default Material shadow, matching Pyago's quiet aesthetic.
class AppElevation {
  const AppElevation._();

  static List<BoxShadow> level1(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return [
      BoxShadow(
        color: (isDark ? Colors.black : const Color(0xFF1B1A1F))
            .withValues(alpha: isDark ? 0.35 : 0.06),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  static List<BoxShadow> level2(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return [
      BoxShadow(
        color: (isDark ? Colors.black : const Color(0xFF1B1A1F))
            .withValues(alpha: isDark ? 0.45 : 0.10),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ];
  }

  static List<BoxShadow> level3(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return [
      BoxShadow(
        color: (isDark ? Colors.black : const Color(0xFF1B1A1F))
            .withValues(alpha: isDark ? 0.55 : 0.14),
        blurRadius: 36,
        offset: const Offset(0, 16),
      ),
    ];
  }
}
