import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../theme/theme_extensions.dart';

enum LegalButtonVariant {
  primary,
  secondary,
  outline,
  danger,
  text,
}

/// Accessible, styled button component adhering to 8px grid and touch target guidelines
class LegalButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final LegalButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;
  final String? semanticLabel;

  const LegalButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = LegalButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = AppSpacing.xxxl, // 48dp accessible touch target
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDisabled = onPressed == null || isLoading;

    return Semantics(
      button: true,
      enabled: !isDisabled,
      label: semanticLabel ?? text,
      child: SizedBox(
        width: width,
        height: height,
        child: AnimatedOpacity(
          duration: context.reducesMotion ? Duration.zero : const Duration(milliseconds: 150),
          opacity: isDisabled ? 0.6 : 1.0,
          child: _buildButtonBody(context, isDark, isDisabled),
        ),
      ),
    );
  }

  Widget _buildButtonBody(BuildContext context, bool isDark, bool isDisabled) {
    switch (variant) {
      case LegalButtonVariant.primary:
        return Container(
          decoration: BoxDecoration(
            gradient: isDisabled
                ? null
                : const LinearGradient(
                    colors: AppColors.primaryButtonGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: isDisabled ? (isDark ? AppColors.darkCardElevated : Colors.grey.shade400) : null,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: isDisabled
                ? null
                : [
                    BoxShadow(
                      color: AppColors.accentViolet.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isDisabled ? null : onPressed,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: Center(
                child: _buildContent(Colors.white),
              ),
            ),
          ),
        );

      case LegalButtonVariant.secondary:
        return Material(
          color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: InkWell(
            onTap: isDisabled ? null : onPressed,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Center(
              child: _buildContent(isDark ? Colors.white : AppColors.textPrimaryLight),
            ),
          ),
        );

      case LegalButtonVariant.outline:
        return Material(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            side: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.5,
            ),
          ),
          child: InkWell(
            onTap: isDisabled ? null : onPressed,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Center(
              child: _buildContent(isDark ? AppColors.accentVioletLight : AppColors.accentIndigo),
            ),
          ),
        );

      case LegalButtonVariant.danger:
        return Material(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: InkWell(
            onTap: isDisabled ? null : onPressed,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Center(
              child: _buildContent(Colors.white),
            ),
          ),
        );

      case LegalButtonVariant.text:
        return TextButton(
          onPressed: isDisabled ? null : onPressed,
          child: _buildContent(isDark ? AppColors.accentVioletLight : AppColors.accentIndigo),
        );
    }
  }

  Widget _buildContent(Color textColor) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: textColor),
          AppSpacing.horizontalSpaceXs,
          Text(
            text,
            style: AppTypography.labelLarge.copyWith(color: textColor),
          ),
        ],
      );
    }

    return Text(
      text,
      style: AppTypography.labelLarge.copyWith(color: textColor),
    );
  }
}
