import 'package:flutter/material.dart';

import 'tokens.dart';

enum AppButtonVariant { primary, secondary, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final style = _resolveStyle(context);

    if (icon != null) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
          style: style,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: style,
        child: Text(label),
      ),
    );
  }

  ButtonStyle _resolveStyle(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.full),
    );
    const padding = EdgeInsets.symmetric(vertical: AppSpacing.sm);
    final textStyle = Theme.of(context).textTheme.bodyLarge;

    switch (variant) {
      case AppButtonVariant.primary:
        return FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: shape,
          padding: padding,
          textStyle: textStyle,
        );
      case AppButtonVariant.secondary:
        return FilledButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.textMainLight,
          shape: shape,
          padding: padding,
          textStyle: textStyle,
          elevation: 0,
        );
      case AppButtonVariant.ghost:
        return FilledButton.styleFrom(
          backgroundColor: AppColors.primary10,
          foregroundColor: AppColors.primary,
          shape: shape,
          padding: padding,
          textStyle: textStyle,
          elevation: 0,
        );
    }
  }
}

enum AppCardPadding { compact, comfortable }

class AppCard extends StatelessWidget {
  final Widget child;
  final AppCardPadding padding;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = AppCardPadding.compact,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paddingValue =
        padding == AppCardPadding.compact ? AppSpacing.sm : AppSpacing.md;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: AppElevation.shadow1,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Padding(
            padding: EdgeInsets.all(paddingValue),
            child: child,
          ),
        ),
      ),
    );
  }
}
