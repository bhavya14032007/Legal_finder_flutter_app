import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/disclaimer_banner.dart';
import '../widgets/feature_card.dart';

class ExploreScreen extends ConsumerWidget {
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

  static FeatureItem _localizeItem(FeatureItem item, bool isHindi) {
    if (!isHindi) return item;
    switch (item.route) {
      case RouteNames.legalAdvisor:
        return FeatureItem(
          title: 'कानूनी सलाहकार',
          description: 'कानूनी धाराओं और उदाहरणों के साथ त्वरित एआई परामर्श।',
          icon: item.icon,
          route: item.route,
          accentColor: item.accentColor,
          badgeText: 'लोकप्रिय',
        );
      case RouteNames.legalResearch:
        return FeatureItem(
          title: 'कानूनी शोध और निर्णय',
          description: 'भारतीय अदालती निर्णय, धाराएं और कानूनी नज़ीरें खोजें।',
          icon: item.icon,
          route: item.route,
          accentColor: item.accentColor,
        );
      case RouteNames.documentSimplifier:
        return FeatureItem(
          title: 'दस्तावेज़ सरलीकरण',
          description: 'जटिल कानूनी अनुबंधों और नोटिसों को सरल भाषा में समझें।',
          icon: item.icon,
          route: item.route,
          accentColor: item.accentColor,
        );
      case RouteNames.drafting:
        return FeatureItem(
          title: 'वैधानिक प्रारूपण',
          description: 'किरायानामा, एनडीए, शपथ पत्र और कानूनी मांग पत्र बनाएं।',
          icon: item.icon,
          route: item.route,
          accentColor: item.accentColor,
        );
      case RouteNames.noticeReply:
        return FeatureItem(
          title: 'नोटिस प्रत्युत्तर',
          description: 'कानूनी नोटिस का विश्लेषण करें और औपचारिक जवाब तैयार करें।',
          icon: item.icon,
          route: item.route,
          accentColor: item.accentColor,
        );
      case RouteNames.legalVault:
        return FeatureItem(
          title: 'सुरक्षित कानूनी वॉल्ट',
          description: 'अनुबंधों और पहचान पत्रों को सुरक्षित एन्क्रिप्टेड वॉल्ट में रखें।',
          icon: item.icon,
          route: item.route,
          accentColor: item.accentColor,
        );
      case RouteNames.scamDetector:
        return FeatureItem(
          title: 'धोखाधड़ी एवं स्कैम शील्ड',
          description: 'फर्जी कॉल, एसएमएस और वित्तीय धोखाधड़ी संदेशों की पहचान करें।',
          icon: item.icon,
          route: item.route,
          accentColor: item.accentColor,
          badgeText: 'सुरक्षा',
        );
      case RouteNames.evidenceTimeline:
        return FeatureItem(
          title: 'साक्ष्य समयरेखा',
          description: 'घटनाओं, तिथियों और साक्ष्यों को कालक्रम में व्यवस्थित करें।',
          icon: item.icon,
          route: item.route,
          accentColor: item.accentColor,
        );
      case RouteNames.lawyerPrep:
        return FeatureItem(
          title: 'वकील परामर्श तैयारी',
          description: 'वकील से मिलने से पहले केस सारांश और मुख्य प्रश्न तैयार करें।',
          icon: item.icon,
          route: item.route,
          accentColor: item.accentColor,
        );
      case RouteNames.legalAid:
        return FeatureItem(
          title: 'मुफ्त कानूनी सहायता',
          description: 'नालसा और डालसा से मुफ्त कानूनी सहायता व वकील सेवा प्राप्त करें।',
          icon: item.icon,
          route: item.route,
          accentColor: item.accentColor,
        );
      default:
        return item;
    }
  }

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
  Widget build(BuildContext context, WidgetRef ref) {
    final isHindi = ref.isHindi;

    return Scaffold(
      appBar: AppBar(
        title: Text(isHindi ? 'कानूनी उपकरण' : 'Explore Tools'),
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
          _buildSectionHeader(
            context,
            isHindi ? 'एआई कानूनी सहायता' : AppConstants.categoryAiAssistance,
          ),
          ...aiAssistanceFeatures.map(
            (item) {
              final localized = _localizeItem(item, isHindi);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: FeatureCard(
                  item: localized,
                  onTap: () => context.push(item.route),
                ),
              );
            },
          ),

          // DOCUMENTS
          _buildSectionHeader(
            context,
            isHindi ? 'दस्तावेज़ एवं अनुपालन' : AppConstants.categoryDocuments,
          ),
          ...documentFeatures.map(
            (item) {
              final localized = _localizeItem(item, isHindi);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: FeatureCard(
                  item: localized,
                  onTap: () => context.push(item.route),
                ),
              );
            },
          ),

          // SAFETY & HELP
          _buildSectionHeader(
            context,
            isHindi ? 'सुरक्षा एवं सहायता' : AppConstants.categorySafetyHelp,
          ),
          ...safetyHelpFeatures.map(
            (item) {
              final localized = _localizeItem(item, isHindi);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: FeatureCard(
                  item: localized,
                  onTap: () => context.push(item.route),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
