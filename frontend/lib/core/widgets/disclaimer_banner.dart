import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../theme/theme_extensions.dart';

/// Standard Legal Disclaimer Banner for AI Output
class DisclaimerBanner extends StatelessWidget {
  final bool compact;
  final String? customText;

  const DisclaimerBanner({
    super.key,
    this.compact = false,
    this.customText,
  });

  @override
  Widget build(BuildContext context) {
    final text = customText ?? (compact ? AppConstants.aiShortDisclaimer : AppConstants.aiDisclaimer);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: compact ? AppSpacing.xs : AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.legalTheme.elevatedSurface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: context.legalTheme.cardBorderSubtle,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_outlined,
            size: compact ? 14 : 18,
            color: AppColors.accentVioletLight,
          ),
          AppSpacing.horizontalSpaceXs,
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.65),
                fontSize: compact ? 11 : 12,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

