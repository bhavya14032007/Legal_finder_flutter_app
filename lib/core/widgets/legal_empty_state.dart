import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../theme/theme_extensions.dart';
import 'infinite_ribbon_motif.dart';
import 'legal_button.dart';

/// Reusable Empty State with Ribbon motif and optional action
class LegalEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool showRibbon;

  const LegalEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.folder_open_outlined,
    this.actionLabel,
    this.onAction,
    this.showRibbon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showRibbon) ...[
              const InfiniteRibbonMotif(height: 60, opacity: 0.35),
              AppSpacing.verticalSpaceSm,
            ],
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: context.legalTheme.elevatedSurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.legalTheme.cardBorder,
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                size: 32,
                color: AppColors.accentVioletLight,
              ),
            ),
            AppSpacing.verticalSpaceMd,
            Text(
              title,
              style: AppTypography.titleMedium.copyWith(
                color: context.colors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSpaceXs,
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.65),
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              AppSpacing.verticalSpaceLg,
              LegalButton(
                text: actionLabel!,
                onPressed: onAction,
                variant: LegalButtonVariant.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
