import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../theme/theme_extensions.dart';
import 'legal_button.dart';

/// Reusable Error View with Retry Action
class LegalErrorView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  const LegalErrorView({
    super.key,
    this.title = 'Something went wrong',
    required this.message,
    this.onRetry,
    this.retryLabel = 'Try Again',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.dangerBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.danger.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 28,
                color: AppColors.danger,
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
                color: context.colors.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              AppSpacing.verticalSpaceLg,
              LegalButton(
                text: retryLabel,
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
                variant: LegalButtonVariant.outline,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
