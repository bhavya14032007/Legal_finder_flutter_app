import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../localization/app_translations.dart';
import '../routing/route_names.dart';

/// Floating AI Advisor Action Button
///
/// Provides quick, persistent access to the AI Legal Advisor across main tabs.
/// Positioned and sized carefully to prevent obscuring bottom nav or keyboards.
class AiFab extends ConsumerWidget {
  final bool extended;

  const AiFab({
    super.key,
    this.extended = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        height: 44,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF7C3AED),
              Color(0xFF6366F1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: isDark ? 0.45 : 0.35),
              blurRadius: 16,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
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
                horizontal: 18,
                vertical: 8,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: Colors.white,
                  ),
                  if (extended) ...[
                    AppSpacing.horizontalSpaceXs,
                    Text(
                      ref.tr('ai_advisor_fab'),
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: 0.2,
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
