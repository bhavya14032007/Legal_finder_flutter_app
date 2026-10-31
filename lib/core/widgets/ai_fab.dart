import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../routing/route_names.dart';

/// Floating AI Advisor Action Button
///
/// Provides quick, persistent access to the AI Legal Advisor across main tabs.
/// Positioned and sized carefully to prevent obscuring bottom nav or keyboards.
class AiFab extends StatelessWidget {
  final bool extended;

  const AiFab({
    super.key,
    this.extended = true,
  });

  @override
  Widget build(BuildContext context) {
    // Hide FAB automatically when virtual keyboard is open
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 100;
    if (keyboardOpen) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      button: true,
      label: 'Open AI Legal Advisor',
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.accentViolet,
              AppColors.accentPurple,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentViolet.withValues(alpha: isDark ? 0.35 : 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              context.push(RouteNames.legalAdvisor);
            },
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 20,
                    color: Colors.white,
                  ),
                  if (extended) ...[
                    AppSpacing.horizontalSpaceXs,
                    Text(
                      'AI Advisor',
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
