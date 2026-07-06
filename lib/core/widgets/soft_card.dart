import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// A consistently-styled rounded surface used for cards throughout the app.
/// Adapts its fill color to the current theme brightness.
class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.color,
    this.borderRadius,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedColor =
        color ?? (isDark ? AppColors.darkCard : AppColors.lightCard);
    final radius = borderRadius ?? BorderRadius.circular(AppRadius.md);

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(color: resolvedColor, borderRadius: radius),
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: content,
      ),
    );
  }
}
