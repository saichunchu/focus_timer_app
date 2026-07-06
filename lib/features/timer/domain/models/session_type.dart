import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// The kind of timer session being run.
enum SessionType {
  focus,
  shortBreak,
  longBreak;

  String get label {
    switch (this) {
      case SessionType.focus:
        return 'Focus';
      case SessionType.shortBreak:
        return 'Short Break';
      case SessionType.longBreak:
        return 'Long Break';
    }
  }

  Color get color {
    switch (this) {
      case SessionType.focus:
        return AppColors.focusColor;
      case SessionType.shortBreak:
        return AppColors.shortBreakColor;
      case SessionType.longBreak:
        return AppColors.longBreakColor;
    }
  }

  IconData get icon {
    switch (this) {
      case SessionType.focus:
        return Icons.bolt_rounded;
      case SessionType.shortBreak:
        return Icons.local_cafe_rounded;
      case SessionType.longBreak:
        return Icons.self_improvement_rounded;
    }
  }
}
