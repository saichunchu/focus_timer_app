import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_tokens.dart';

class HistorySearchField extends StatelessWidget {
  const HistorySearchField({
    super.key,
    required this.onChanged,
    required this.controller,
  });

  final ValueChanged<String> onChanged;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: AppTextStyles.bodyLarge(color: theme.textTheme.headlineMedium?.color),
      decoration: InputDecoration(
        hintText: 'Search sessions',
        hintStyle: AppTextStyles.bodyLarge(color: theme.textTheme.bodyMedium?.color),
        prefixIcon: Icon(Icons.search_rounded, color: theme.textTheme.bodyMedium?.color),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.close_rounded, color: theme.textTheme.bodyMedium?.color),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              )
            : null,
        filled: true,
        fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
