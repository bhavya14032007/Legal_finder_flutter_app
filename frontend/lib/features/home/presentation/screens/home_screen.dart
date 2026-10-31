import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/disclaimer_banner.dart';
import '../../../../core/widgets/infinite_ribbon_motif.dart';
import '../../../../core/widgets/legal_card.dart';
import '../../../../core/widgets/legal_text_field.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../saved/data/saved_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final savedState = ref.watch(savedControllerProvider);

    final displayName = authState.userName ?? 'Legal Explorer';

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned(
              top: -30,
              right: -50,
              child: InfiniteRibbonMotif(
                height: 180,
                width: 280,
                opacity: 0.2,
              ),
            ),
            ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.massive, // Clearance for FAB and bottom navigation
              ),
              children: [
                // Header with User Profile snippet
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: AppTypography.bodySmall.copyWith(
                              color: context.colors.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          Text(
                            displayName,
                            style: AppTypography.titleLarge.copyWith(
                              color: context.colors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go(RouteNames.me),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.accentViolet.withValues(alpha: 0.2),
                        child: Text(
                          displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.accentVioletLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalSpaceMd,

                // Global Ask / Search Legal Bar
                LegalTextField(
                  hintText: 'Ask any legal question or search statutes...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.accentViolet,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
                      onPressed: () {
                        context.push(RouteNames.legalAdvisor);
                      },
                    ),
                  ),
                  onSubmitted: (query) {
                    if (query.trim().isNotEmpty) {
                      context.push(RouteNames.legalAdvisor);
                    }
                  },
                ),
                AppSpacing.verticalSpaceMd,

                // AI Advisor Hero Card
                LegalCard(
                  onTap: () => context.push(RouteNames.legalAdvisor),
                  isInteractive: true,
                  backgroundColor: context.legalTheme.elevatedSurface,
                  borderColor: AppColors.accentViolet.withValues(alpha: 0.35),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.xs),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: AppColors.primaryButtonGradient,
                              ),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                          AppSpacing.horizontalSpaceSm,
                          Text(
                            'AI Legal Advisor',
                            style: AppTypography.titleSmall.copyWith(
                              color: context.colors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Start Consult',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.accentVioletLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: AppColors.accentVioletLight,
                          ),
                        ],
                      ),
                      AppSpacing.verticalSpaceSm,
                      Text(
                        'Get instant statutory clarifications, legal notice analysis, and procedural roadmap guidance.',
                        style: AppTypography.bodySmall.copyWith(
                          color: context.colors.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.verticalSpaceLg,

                // Quick-Access Legal Tools
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quick-Access Tools',
                      style: AppTypography.titleSmall.copyWith(
                        color: context.colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go(RouteNames.explore),
                      child: Text(
                        'View All',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.accentVioletLight,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalSpaceXs,
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.45,
                  children: [
                    _QuickToolTile(
                      title: 'Simplifier',
                      subtitle: 'Plain language clauses',
                      icon: Icons.auto_stories_outlined,
                      accentColor: AppColors.accentCyan,
                      onTap: () => context.push(RouteNames.documentSimplifier),
                    ),
                    _QuickToolTile(
                      title: 'Drafting',
                      subtitle: 'Agreements & notices',
                      icon: Icons.history_edu_outlined,
                      accentColor: AppColors.accentPurple,
                      onTap: () => context.push(RouteNames.drafting),
                    ),
                    _QuickToolTile(
                      title: 'Notice Reply',
                      subtitle: 'Rebuttal generator',
                      icon: Icons.reply_all_outlined,
                      accentColor: AppColors.info,
                      onTap: () => context.push(RouteNames.noticeReply),
                    ),
                    _QuickToolTile(
                      title: 'Scam Detector',
                      subtitle: 'Risk & threat score',
                      icon: Icons.shield_outlined,
                      accentColor: AppColors.danger,
                      onTap: () => context.push(RouteNames.scamDetector),
                    ),
                  ],
                ),
                AppSpacing.verticalSpaceLg,

                // Recently Saved Documents
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recently Saved',
                      style: AppTypography.titleSmall.copyWith(
                        color: context.colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go(RouteNames.saved),
                      child: Text(
                        'Open Library',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.accentVioletLight,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalSpaceXs,
                if (savedState.items.isEmpty)
                  LegalCard(
                    padding: AppSpacing.paddingMd,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.bookmark_border_rounded,
                          color: AppColors.textSecondaryDark,
                        ),
                        AppSpacing.horizontalSpaceMd,
                        Expanded(
                          child: Text(
                            'No documents saved yet. Draft or simplify files to save them here.',
                            style: AppTypography.bodySmall.copyWith(
                              color: context.colors.onSurface.withValues(alpha: 0.65),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...savedState.items.take(2).map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: LegalCard(
                            onTap: () => context.go(RouteNames.saved),
                            isInteractive: true,
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: AppColors.accentViolet.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                  ),
                                  child: const Icon(
                                    Icons.description_outlined,
                                    size: 20,
                                    color: AppColors.accentVioletLight,
                                  ),
                                ),
                                AppSpacing.horizontalSpaceMd,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: AppTypography.labelLarge.copyWith(
                                          color: context.colors.onSurface,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        DateFormatter.formatRelative(item.createdAt),
                                        style: AppTypography.bodySmall.copyWith(
                                          color: context.colors.onSurface.withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                AppSpacing.verticalSpaceLg,

                // Legal Disclaimer Banner
                const DisclaimerBanner(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickToolTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _QuickToolTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LegalCard(
      onTap: onTap,
      isInteractive: true,
      padding: AppSpacing.paddingSm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          AppSpacing.verticalSpaceSm,
          Text(
            title,
            style: AppTypography.titleSmall.copyWith(
              color: context.colors.onSurface,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.6),
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
