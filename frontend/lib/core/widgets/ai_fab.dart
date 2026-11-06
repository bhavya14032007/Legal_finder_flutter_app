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
class AiFab extends ConsumerStatefulWidget {
  final bool extended;

  const AiFab({
    super.key,
    this.extended = true,
  });

  @override
  ConsumerState<AiFab> createState() => _AiFabState();
}

class _AiFabState extends ConsumerState<AiFab> {
  bool _isPressed = false;

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
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.94 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF7955F5),
                  Color(0xFF6366F1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7955F5).withValues(alpha: isDark ? 0.4 : 0.28),
                  blurRadius: 14,
                  spreadRadius: 0.5,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
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
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        size: 15,
                        color: Colors.white,
                      ),
                      if (widget.extended) ...[
                        AppSpacing.horizontalSpaceXs,
                        Text(
                          ref.tr('ai_advisor_fab'),
                          style: AppTypography.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
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
        ),
      ),
    );
  }
}
