import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_tokens.dart';

abstract class AppTheme {
  AppTheme._();

  static ThemeData get light => _buildTheme(
        brightness: Brightness.light,
        background: AppColors.lightBackground,
        surface: AppColors.lightSurface,
        card: AppColors.lightCard,
        border: AppColors.lightBorder,
        textPrimary: AppColors.lightTextPrimary,
        textSecondary: AppColors.lightTextSecondary,
      );

  static ThemeData get dark => _buildTheme(
        brightness: Brightness.dark,
        background: AppColors.darkBackground,
        surface: AppColors.darkSurfaceSolid,
        card: AppColors.darkCard,
        border: AppColors.darkBorder,
        textPrimary: AppColors.darkTextPrimary,
        textSecondary: AppColors.darkTextSecondary,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color card,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.primaryLight,
      onSecondary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      surface: surface,
      onSurface: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: AppTextStyles.bodyMedium().fontFamily,
      splashFactory: InkRipple.splashFactory,
      highlightColor: Colors.transparent,
      dividerColor: border,
      cardColor: card,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: AppTextStyles.h3(color: textPrimary),
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge(color: textPrimary),
        headlineMedium: AppTextStyles.h1(color: textPrimary),
        headlineSmall: AppTextStyles.h2(color: textPrimary),
        titleLarge: AppTextStyles.h3(color: textPrimary),
        bodyLarge: AppTextStyles.bodyLarge(color: textPrimary),
        bodyMedium: AppTextStyles.bodyMedium(color: textSecondary),
        bodySmall: AppTextStyles.bodySmall(color: textSecondary),
        labelLarge: AppTextStyles.labelLarge(color: textPrimary),
      ),
      iconTheme: IconThemeData(color: textPrimary),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          textStyle: AppTextStyles.labelLarge(color: Colors.white),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.labelMedium(),
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? Colors.white : textSecondary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary
              : border,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
