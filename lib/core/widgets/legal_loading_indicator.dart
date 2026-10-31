import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../theme/theme_extensions.dart';

/// Reusable Themed Loading Indicator
class LegalLoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;

  const LegalLoadingIndicator({
    super.key,
    this.message,
    this.size = 36.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentViolet),
            ),
          ),
          if (message != null) ...[
            AppSpacing.verticalSpaceMd,
            Text(
              message!,
              style: AppTypography.bodyMedium.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

