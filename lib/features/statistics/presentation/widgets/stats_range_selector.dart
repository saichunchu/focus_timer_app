import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/statistics_providers.dart';

class StatsRangeSelector extends StatelessWidget {
  const StatsRangeSelector({super.key, required this.selected, required this.onChanged});

  final StatsRange selected;
  final ValueChanged<StatsRange> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        children: StatsRange.values.map((range) {
          final isSelected = range == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(range),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                alignment: Alignment.center,
                child: Text(
                  range.label,
                  style: AppTextStyles.labelMedium(
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
