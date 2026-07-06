import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography system built on Plus Jakarta Sans for a premium, modern feel.
abstract class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base({
    required double size,
    required FontWeight weight,
    double? letterSpacing,
    double? height,
    Color? color,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      height: height,
      color: color,
    );
  }

  // Display / hero numbers (timer countdown)
  static TextStyle displayTimer({Color? color}) => _base(
        size: 64,
        weight: FontWeight.w700,
        letterSpacing: -1.5,
        color: color,
      );

  static TextStyle displayLarge({Color? color}) => _base(
        size: 34,
        weight: FontWeight.w800,
        letterSpacing: -0.8,
        color: color,
      );

  // Headings
  static TextStyle h1({Color? color}) => _base(
        size: 26,
        weight: FontWeight.w800,
        letterSpacing: -0.5,
        color: color,
      );

  static TextStyle h2({Color? color}) => _base(
        size: 22,
        weight: FontWeight.w700,
        letterSpacing: -0.3,
        color: color,
      );

  static TextStyle h3({Color? color}) => _base(
        size: 18,
        weight: FontWeight.w700,
        letterSpacing: -0.2,
        color: color,
      );

  // Overline / eyebrow (tracked uppercase labels like design reference)
  static TextStyle overline({Color? color}) => _base(
        size: 12,
        weight: FontWeight.w700,
        letterSpacing: 1.2,
        color: color,
      );

  // Body
  static TextStyle bodyLarge({Color? color}) => _base(
        size: 16,
        weight: FontWeight.w500,
        height: 1.4,
        color: color,
      );

  static TextStyle bodyMedium({Color? color}) => _base(
        size: 14,
        weight: FontWeight.w500,
        height: 1.4,
        color: color,
      );

  static TextStyle bodySmall({Color? color}) => _base(
        size: 12,
        weight: FontWeight.w500,
        height: 1.3,
        color: color,
      );

  // Labels / buttons
  static TextStyle labelLarge({Color? color}) => _base(
        size: 16,
        weight: FontWeight.w700,
        color: color,
      );

  static TextStyle labelMedium({Color? color}) => _base(
        size: 14,
        weight: FontWeight.w700,
        color: color,
      );

  static TextStyle caption({Color? color}) => _base(
        size: 11,
        weight: FontWeight.w600,
        letterSpacing: 0.2,
        color: color,
      );

  // Numeric emphasis (stats)
  static TextStyle statValue({Color? color}) => _base(
        size: 28,
        weight: FontWeight.w800,
        letterSpacing: -0.6,
        color: color,
      );
}
