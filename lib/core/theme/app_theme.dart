import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';

/// Builds Pyago's Material 3 [ThemeData] for every supported theme mode:
/// standard light/dark, and high-contrast variants for low-vision users.
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
    required bool highContrast,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: Colors.white,
      secondary: AppColors.brandAccent,
      onSecondary: Colors.white,
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
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: highContrast ? 0 : 1,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: textTheme.headlineSmall,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusMd,
          side: BorderSide(color: border, width: highContrast ? 1.5 : 1),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        labelStyle: textTheme.labelMedium,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusPill),
        side: BorderSide(color: border),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: surfaceVariant,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: border, width: highContrast ? 1.5 : 1),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide(color: border),
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
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusLg),
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withValues(alpha: 0.15),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.all(textTheme.labelSmall),
        height: 64,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: brightness == Brightness.light ? Colors.white : background,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusSm),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
