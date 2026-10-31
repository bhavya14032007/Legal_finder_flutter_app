import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/disclaimer_banner.dart';
import '../widgets/feature_card.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  static const List<FeatureItem> aiAssistanceFeatures = [
    FeatureItem(
      title: 'Legal Advisor',
      description: 'Conversational legal reasoning, statutory answers, and case strategy guidance.',
      icon: Icons.psychology_outlined,
      route: RouteNames.legalAdvisor,
      accentColor: AppColors.accentViolet,
      badgeText: 'POPULAR',
    ),
    FeatureItem(
      title: 'Legal Research',
      description: 'Find case laws, statutory provisions, precedent citations, and judicial ratios.',
      icon: Icons.menu_book_outlined,
      route: RouteNames.legalResearch,
      accentColor: AppColors.accentIndigo,
    ),
  ];

  static const List<FeatureItem> documentFeatures = [
    FeatureItem(
      title: 'Document Simplifier',
      description: 'Upload complex contracts and notices for plain-English clause breakdown and risk highlights.',
      icon: Icons.auto_stories_outlined,
      route: RouteNames.documentSimplifier,
      accentColor: AppColors.accentCyan,
    ),
    FeatureItem(
      title: 'Drafting Assistant',
      description: 'Draft customized NDAs, rental agreements, demand notices, and commercial contracts.',
      icon: Icons.history_edu_outlined,
      route: RouteNames.drafting,
      accentColor: AppColors.accentPurple,
    ),
    FeatureItem(
      title: 'Notice Reply',
      description: 'Upload legal notices and auto-generate structured, fact-grounded rebuttal responses.',
      icon: Icons.reply_all_outlined,
      route: RouteNames.noticeReply,
      accentColor: AppColors.info,
    ),
    FeatureItem(
      title: 'Legal Vault',
      description: 'Encrypted document depository to safely organize contracts, identity, and court records.',
      icon: Icons.lock_outline_rounded,
      route: RouteNames.legalVault,
      accentColor: AppColors.accentVioletLight,
    ),
  ];

  static const List<FeatureItem> safetyHelpFeatures = [
    FeatureItem(
      title: 'Scam Detector',
      description: 'Analyze suspicious emails, investment agreements, and payment requests for scam signals.',
      icon: Icons.shield_outlined,
      route: RouteNames.scamDetector,
      accentColor: AppColors.danger,
      badgeText: 'SECURITY',
    ),
    FeatureItem(
      title: 'Evidence & Timeline',
      description: 'Log and chronologically sequence incident proof, receipts, timestamps, and witness records.',
      icon: Icons.timeline_outlined,
      route: RouteNames.evidenceTimeline,
      accentColor: AppColors.warning,
    ),
    FeatureItem(
      title: 'Lawyer Preparation',
      description: 'Structure your case facts, key timelines, and smart prioritized questions before hiring counsel.',
      icon: Icons.assignment_outlined,
      route: RouteNames.lawyerPrep,
      accentColor: AppColors.accentIndigo,
    ),
    FeatureItem(
      title: 'Legal Aid',
      description: 'Check eligibility criteria and connect with subsidized and pro-bono state legal authorities.',
      icon: Icons.volunteer_activism_outlined,
      route: RouteNames.legalAid,
      accentColor: AppColors.success,
    ),
  ];

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
      child: Text(
        title,
        style: AppTypography.labelLarge.copyWith(
          color: context.colors.primary,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Tools'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.massive, // Bottom clearance for FAB & navigation
        ),
        children: [
          const DisclaimerBanner(compact: true),
          AppSpacing.verticalSpaceSm,

          // AI ASSISTANCE
          _buildSectionHeader(context, AppConstants.categoryAiAssistance),
          ...aiAssistanceFeatures.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: FeatureCard(
                item: item,
                onTap: () => context.push(item.route),
              ),
            ),
          ),

          // DOCUMENTS
          _buildSectionHeader(context, AppConstants.categoryDocuments),
          ...documentFeatures.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: FeatureCard(
                item: item,
                onTap: () => context.push(item.route),
              ),
            ),
          ),

          // SAFETY & HELP
          _buildSectionHeader(context, AppConstants.categorySafetyHelp),
          ...safetyHelpFeatures.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: FeatureCard(
                item: item,
                onTap: () => context.push(item.route),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
