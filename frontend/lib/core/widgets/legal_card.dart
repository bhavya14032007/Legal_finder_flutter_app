import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';
import '../theme/theme_extensions.dart';

/// Reusable Card component respecting the 8px grid and subtle borders
class LegalCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final bool isInteractive;

  const LegalCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = AppSpacing.paddingMd,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = AppSpacing.radiusLg,
    this.isInteractive = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeExt = context.legalTheme;
    final bg = backgroundColor ?? themeExt.cardBackground;
    final border = borderColor ?? themeExt.cardBorder;

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(color: border, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
