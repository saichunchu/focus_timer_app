import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_tokens.dart';

class ThemeModeSelector extends StatelessWidget {
  const ThemeModeSelector({super.key, required this.selected, required this.onChanged});

  final ThemeMode selected;
  final ValueChanged<ThemeMode> onChanged;

  static const _options = [
    (mode: ThemeMode.system, label: 'System', icon: Icons.smartphone_rounded),
    (mode: ThemeMode.light, label: 'Light', icon: Icons.light_mode_rounded),
    (mode: ThemeMode.dark, label: 'Dark', icon: Icons.dark_mode_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: _options.map((option) {
          final isSelected = option.mode == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(option.mode),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.darkBorder.withValues(alpha: 0.3) : AppColors.lightBorder),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      option.icon,
                      size: 20,
                      color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.label,
                      style: AppTextStyles.caption(
                        color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
