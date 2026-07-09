import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_tokens.dart';

/// Branded launch screen shown briefly while the app initializes.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      context.go(AppRoutes.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final background = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x407C6AF0),
                    blurRadius: 28,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: const Icon(Icons.timer_rounded, color: Colors.white, size: 48),
            )
                .animate()
                .fadeIn(duration: 500.ms, curve: Curves.easeOut)
                .scale(
                  begin: const Offset(0.82, 0.82),
                  end: const Offset(1, 1),
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Focus Timer',
              style: AppTextStyles.h1(color: theme.textTheme.headlineMedium?.color),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 450.ms)
                .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 450.ms),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Deep work, gently guided',
              style: AppTextStyles.bodyMedium(color: subtitleColor),
            )
                .animate()
                .fadeIn(delay: 350.ms, duration: 450.ms)
                .slideY(begin: 0.15, end: 0, delay: 350.ms, duration: 450.ms),
          ],
        ),
      ),
    );
  }
}
