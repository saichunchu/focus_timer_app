/// Design tokens shared across the app: spacing, radii, durations, elevation.
abstract class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

abstract class AppRadius {
  AppRadius._();
  static const double sm = 12;
  static const double md = 20;
  static const double lg = 28;
  static const double xl = 36;
  static const double pill = 999;
}

abstract class AppDurations {
  AppDurations._();
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration pageTransition = Duration(milliseconds: 380);
}
