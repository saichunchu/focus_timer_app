import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/greeting_utils.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key, required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateFormat('EEEE, MMMM d').format(DateTime.now());
    final greeting = greetingForHour();
    final initial = userName.trim().isNotEmpty
        ? userName.trim()[0].toUpperCase()
        : '?';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  today.toUpperCase(),
                  style: AppTextStyles.overline(
                    color: theme.brightness == Brightness.dark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$greeting, $userName',
                  style: AppTextStyles.h1(color: theme.textTheme.headlineMedium?.color),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.go(AppRoutes.settings),
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: AppTextStyles.h3(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 320.ms).slideY(begin: -0.08, end: 0, curve: Curves.easeOutCubic);
  }
}
