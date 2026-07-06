import 'package:flutter/material.dart';

/// Centralized color palette for the app.
/// Soft purple accents with a clean, premium neutral base.
abstract class AppColors {
  AppColors._();

  // Brand / accent
  static const Color primary = Color(0xFF7C6AF0);
  static const Color primaryDark = Color(0xFF6952E8);
  static const Color primaryLight = Color(0xFFB7ADF7);
  static const Color primarySoft = Color(0xFFEDE9FE);

  // Gradients
  static const List<Color> primaryGradient = [
    Color(0xFF8B7BF7),
    Color(0xFF6952E8),
  ];

  // Light theme neutrals
  static const Color lightBackground = Color(0xFFFAFAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF4F3F8);
  static const Color lightBorder = Color(0xFFEDEDF2);
  static const Color lightTextPrimary = Color(0xFF15131F);
  static const Color lightTextSecondary = Color(0xFF817E90);
  static const Color lightTextTertiary = Color(0xFFB0AEBB);

  // Dark theme neutrals
  static const Color darkBackground = Color(0xFF0F0D16);
  static const Color darkSurface = Color(0xFF19172236);
  static const Color darkSurfaceSolid = Color(0xFF1B1926);
  static const Color darkCard = Color(0xFF211F2E);
  static const Color darkBorder = Color(0xFF2C2A3A);
  static const Color darkTextPrimary = Color(0xFFF6F5FA);
  static const Color darkTextSecondary = Color(0xFFA6A3B5);
  static const Color darkTextTertiary = Color(0xFF6F6C80);

  // Semantic
  static const Color success = Color(0xFF3FC17F);
  static const Color warning = Color(0xFFF5A623);
  static const Color error = Color(0xFFEF5A6F);
  static const Color info = Color(0xFF4EA1F7);

  // Heatmap intensity scale (light -> dark purple)
  static const List<Color> heatmapScaleLight = [
    Color(0xFFEFEDF9),
    Color(0xFFD7CFF5),
    Color(0xFFB2A0EE),
    Color(0xFF8B72E6),
    Color(0xFF6952E8),
  ];

  static const List<Color> heatmapScaleDark = [
    Color(0xFF221F30),
    Color(0xFF362E5C),
    Color(0xFF4B3C86),
    Color(0xFF6249B0),
    Color(0xFF8B72E6),
  ];

  // Session type colors
  static const Color focusColor = primary;
  static const Color shortBreakColor = Color(0xFF3FC17F);
  static const Color longBreakColor = Color(0xFF4EA1F7);
}
