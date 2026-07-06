import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/soft_card.dart';

/// A titled group of settings rows, rendered as a single rounded card
/// with dividers between rows.
class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.sm),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.overline(
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
            ),
          ),
        ),
        SoftCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1)
                  Divider(
                    height: 1,
                    indent: AppSpacing.md,
                    endIndent: AppSpacing.md,
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// A row with a leading icon, title/subtitle, and a trailing [Switch].
class SettingsSwitchRow extends StatelessWidget {
  const SettingsSwitchRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final opacity = enabled ? 1.0 : 0.4;

    return Opacity(
      opacity: opacity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 20, color: theme.textTheme.bodyMedium?.color),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyLarge(color: theme.textTheme.headlineMedium?.color)),
                  if (subtitle != null)
                    Text(subtitle!, style: AppTextStyles.bodySmall(color: theme.textTheme.bodyMedium?.color)),
                ],
              ),
            ),
            Switch(value: value, onChanged: enabled ? onChanged : null),
          ],
        ),
      ),
    );
  }
}

/// A tappable row with a leading icon, title, and a trailing value label
/// + chevron — used for navigation-style settings entries.
class SettingsNavRow extends StatelessWidget {
  const SettingsNavRow({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailingText,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String? trailingText;
  final bool destructive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = destructive ? AppColors.error : theme.textTheme.headlineMedium?.color;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: destructive ? AppColors.error : theme.textTheme.bodyMedium?.color),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(title, style: AppTextStyles.bodyLarge(color: color)),
            ),
            if (trailingText != null) ...[
              Text(trailingText!, style: AppTextStyles.bodyMedium(color: theme.textTheme.bodyMedium?.color)),
              const SizedBox(width: 4),
            ],
            if (!destructive)
              Icon(Icons.chevron_right_rounded, size: 20, color: theme.textTheme.bodyMedium?.color),
          ],
        ),
      ),
    );
  }
}
