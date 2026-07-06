import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

class _NavItemData {
  const _NavItemData(this.icon, this.activeIcon,);
  final IconData icon;
  final IconData activeIcon;
  // final String label;
}

const _navItems = [
  _NavItemData(Icons.home_outlined, Icons.home_rounded,),
  _NavItemData(Icons.donut_large_outlined, Icons.donut_large_rounded, ),
  _NavItemData(Icons.timer_outlined, Icons.timer_rounded, ),
  _NavItemData(Icons.history_rounded, Icons.history_rounded,),
  _NavItemData(Icons.settings_outlined, Icons.settings_rounded,),
];

/// A floating, pill-shaped bottom navigation bar with a sliding active
/// indicator, matching the soft/minimal aesthetic of the rest of the app.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Vertical space occupied by the floating bar (safe area + margins + pill).
  static double reservedHeight(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    return padding.bottom + AppSpacing.sm + 68;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final barColor = isDark ? AppColors.darkSurfaceSolid : Colors.white;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: barColor,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_navItems.length, (index) {
            final item = _navItems[index];
            final selected = index == currentIndex;
            return Expanded(
              child: _NavButton(
                item: item,
                selected: selected,
                onTap: () => onTap(index),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItemData item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final inactiveColor =
        isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.medium,
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 14 : 0,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? item.activeIcon : item.icon,
              size: 22,
              color: selected ? Colors.white : inactiveColor,
            ),
            // AnimatedSize(
            //   duration: AppDurations.medium,
            //   curve: Curves.easeOutCubic,
            //   child: selected
            //       ? Padding(
            //           padding: const EdgeInsets.only(left: 6),
            //           child: Text(
            //             item.label,
            //             style: AppTextStyles.labelMedium(color: Colors.white),
            //           ),
            //         )
            //       : const SizedBox.shrink(),
            // ),
          ],
        ),
      ),
    );
  }
}
