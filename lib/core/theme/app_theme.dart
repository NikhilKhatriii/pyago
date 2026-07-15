import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';

/// Builds Pyago's Material 3 [ThemeData] for every supported theme mode:
/// standard light/dark, and high-contrast variants for low-vision users.
///
/// The theme is designed for a premium editorial aesthetic: warm
/// backgrounds, soft borderless cards, pill-shaped buttons, and
/// a translucent navigation bar.
class AppTheme {
  const AppTheme._();

  static ThemeData light({bool highContrast = false}) => _build(
        brightness: Brightness.light,
        background:
            highContrast ? AppColors.highContrastLightBg : AppColors.lightBackground,
        surface: highContrast ? AppColors.highContrastLightBg : AppColors.lightSurface,
        surfaceVariant: AppColors.lightSurfaceVariant,
        border: highContrast ? AppColors.highContrastLightText : AppColors.lightBorder,
        textPrimary:
            highContrast ? AppColors.highContrastLightText : AppColors.lightTextPrimary,
        textSecondary:
            highContrast ? AppColors.highContrastLightText : AppColors.lightTextSecondary,
        primary: AppColors.brandPrimary,
        // Light theme: tertiary is a warm amber, used for the offline banner
        tertiary: AppColors.warning,
        onTertiary: Colors.white,
        tertiaryContainer: AppColors.warning.withValues(alpha: 0.12),
        onTertiaryContainer: const Color(0xFF7A4800),
        highContrast: highContrast,
      );

  static ThemeData dark({bool highContrast = false}) => _build(
        brightness: Brightness.dark,
        background:
            highContrast ? AppColors.highContrastDarkBg : AppColors.darkBackground,
        surface: highContrast ? AppColors.highContrastDarkBg : AppColors.darkSurface,
        surfaceVariant: AppColors.darkSurfaceVariant,
        border: highContrast ? AppColors.highContrastDarkText : AppColors.darkBorder,
        textPrimary:
            highContrast ? AppColors.highContrastDarkText : AppColors.darkTextPrimary,
        textSecondary:
            highContrast ? AppColors.highContrastDarkText : AppColors.darkTextSecondary,
        primary: AppColors.brandPrimaryLight,
        // Dark theme: tertiary is a muted amber so it reads well on dark surfaces
        tertiary: AppColors.warning,
        onTertiary: AppColors.darkBackground,
        tertiaryContainer: AppColors.warning.withValues(alpha: 0.18),
        onTertiaryContainer: const Color(0xFFFFDDB3),
        highContrast: highContrast,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfaceVariant,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
    required Color primary,
    required Color tertiary,
    required Color onTertiary,
    required Color tertiaryContainer,
    required Color onTertiaryContainer,
    required bool highContrast,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: Colors.white,
      secondary: AppColors.brandAccent,
      onSecondary: Colors.white,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: AppColors.error,
      onError: Colors.white,
      surface: surface,
      onSurface: textPrimary,
      surfaceContainerHighest: surfaceVariant,
      outline: border,
    );

    final textTheme = AppTypography.uiTextTheme(textPrimary);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      fontFamily: textTheme.bodyMedium?.fontFamily,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      dividerColor: border,

      // ── App Bar ──────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: highContrast ? 0 : 0.5,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),

      // ── Cards — borderless with warm shadow ─────────────────────────────
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusCard,
          side: highContrast
              ? BorderSide(color: border, width: 1.5)
              : BorderSide.none,
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Chips — pill-shaped with refined styling ────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        labelStyle: textTheme.labelMedium,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusPill),
        side: BorderSide(color: border.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // ── Elevated Button — pill-shaped gradient-ready ────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: surfaceVariant,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusPill),
          textStyle: textTheme.labelLarge?.copyWith(
            letterSpacing: 0.5,
          ),
        ),
      ),

      // ── Outlined Button ────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: border, width: highContrast ? 1.5 : 1),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusPill),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // ── Text Button ────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: textTheme.labelLarge,
        ),
      ),

      // ── Input Fields — elegant underline-forward styling ───────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide(color: border.withValues(alpha: 0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
        labelStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
      ),

      // ── Bottom Sheet — frosted glass aesthetic ─────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
      ),

      // ── Dialog ─────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusLg),
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
      ),

      // ── Navigation Bar — translucent with pill indicator ──────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface.withValues(alpha: 0.85),
        indicatorColor: primary.withValues(alpha: 0.12),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: primary,
              fontWeight: FontWeight.w700,
            );
          }
          return textTheme.labelSmall?.copyWith(
            color: textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primary, size: 24);
          }
          return IconThemeData(color: textSecondary, size: 22);
        }),
        height: 68,
      ),

      // ── Snack Bar ─────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: brightness == Brightness.light ? Colors.white : background,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusSm),
      ),

      // ── Page Transitions ──────────────────────────────────────────────
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
