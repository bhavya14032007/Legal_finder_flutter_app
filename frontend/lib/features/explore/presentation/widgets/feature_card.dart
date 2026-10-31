import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/legal_card.dart';

class FeatureItem {
  final String title;
  final String description;
  final IconData icon;
  final String route;
  final Color accentColor;
  final String? badgeText;

  const FeatureItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
    required this.accentColor,
    this.badgeText,
  });
}

class FeatureCard extends StatelessWidget {
  final FeatureItem item;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LegalCard(
      onTap: onTap,
      isInteractive: true,
      padding: AppSpacing.paddingMd,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: item.accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: item.accentColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              item.icon,
              color: item.accentColor,
              size: 24,
            ),
          ),
          AppSpacing.horizontalSpaceMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: AppTypography.titleSmall.copyWith(
                          color: context.colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (item.badgeText != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accentViolet.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                        ),
                        child: Text(
                          item.badgeText!,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.accentVioletLight,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                AppSpacing.verticalSpaceXxs,
                Text(
                  item.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.65),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          AppSpacing.horizontalSpaceSm,
          Icon(
            Icons.chevron_right_rounded,
            color: context.colors.onSurface.withValues(alpha: 0.3),
            size: 20,
          ),
        ],
      ),
    );
  }
}

