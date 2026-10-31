import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/infinite_ribbon_motif.dart';
import '../../../../core/widgets/legal_button.dart';
import '../../../../core/widgets/legal_card.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../shared/providers/storage_provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../saved/data/saved_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.legalTheme.cardBackground,
        title: const Text('Privacy & Data Governance'),
        content: SingleChildScrollView(
          child: Text(
            'Legal Helper is built with privacy-by-design principles:\n\n'
            '1. Zero-Retention AI Pipelines: Documents submitted to simplification or scam detection are processed in memory and never used for foundation model training without explicit consent.\n\n'
            '2. End-to-End Encryption: Documents in the Legal Vault are protected by AES-256 client-side encryption.\n\n'
            '3. Supabase Auth & Row Level Security (RLS): All database tables strictly enforce RLS policies so users only access their own records.',
            style: AppTypography.bodySmall.copyWith(
              color: context.colors.onSurface,
              height: 1.5,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final storage = ref.watch(storageServiceProvider);
    final savedState = ref.watch(savedControllerProvider);

    final isHindi = locale.languageCode == 'hi';

    return Scaffold(
      appBar: AppBar(
        title: Text(isHindi ? 'मेरी प्रोफ़ाइल और सेटिंग्स' : 'Me & Account Settings'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned(
              bottom: -40,
              right: -30,
              child: InfiniteRibbonMotif(
                height: 160,
                width: 240,
                opacity: 0.15,
              ),
            ),
            ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.massive, // Clearance for FAB and nav bar
              ),
              children: [
                // User Profile Header Card
                LegalCard(
                  padding: AppSpacing.paddingLg,
                  backgroundColor: context.legalTheme.elevatedSurface,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.accentViolet.withValues(alpha: 0.25),
                        child: Text(
                          (authState.userName?.isNotEmpty ?? false)
                              ? authState.userName![0].toUpperCase()
                              : 'U',
                          style: AppTypography.titleLarge.copyWith(
                            color: AppColors.accentVioletLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      AppSpacing.horizontalSpaceMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authState.userName ?? 'Advocate Rajesh Sharma',
                              style: AppTypography.titleMedium.copyWith(
                                color: context.colors.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              authState.userEmail ?? 'advocate.user@example.com',
                              style: AppTypography.bodySmall.copyWith(
                                color: context.colors.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            AppSpacing.verticalSpaceXs,
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                              ),
                              child: Text(
                                'VERIFIED ACCOUNT',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.success,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.verticalSpaceMd,

                // Quick Library Stats
                Row(
                  children: [
                    Expanded(
                      child: LegalCard(
                        padding: AppSpacing.paddingSm,
                        child: Column(
                          children: [
                            Text(
                              '${savedState.items.length}',
                              style: AppTypography.titleLarge.copyWith(
                                color: AppColors.accentVioletLight,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              isHindi ? 'सहेजे गए दस्तावेज़' : 'Saved Items',
                              style: AppTypography.bodySmall.copyWith(
                                color: context.colors.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AppSpacing.horizontalSpaceMd,
                    Expanded(
                      child: LegalCard(
                        padding: AppSpacing.paddingSm,
                        child: Column(
                          children: [
                            Text(
                              SupabaseConfig.isConfigured ? 'LIVE' : 'LOCAL',
                              style: AppTypography.titleLarge.copyWith(
                                color: SupabaseConfig.isConfigured ? AppColors.success : AppColors.accentCyan,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Cloud Sync Status',
                              style: AppTypography.bodySmall.copyWith(
                                color: context.colors.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalSpaceLg,

                // Preferences & Customization Section
                Text(
                  isHindi ? 'प्राथमिकताएं' : 'PREFERENCES & LOCALIZATION',
                  style: AppTypography.labelLarge.copyWith(
                    color: context.colors.primary,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.verticalSpaceSm,

                // Theme Mode Selector
                LegalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHindi ? 'थीम मोड' : 'App Theme Mode',
                        style: AppTypography.titleSmall.copyWith(
                          color: context.colors.onSurface,
                        ),
                      ),
                      AppSpacing.verticalSpaceSm,
                      SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.dark,
                            label: Text('Midnight Dark'),
                            icon: Icon(Icons.dark_mode_rounded, size: 16),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            label: Text('Light'),
                            icon: Icon(Icons.light_mode_rounded, size: 16),
                          ),
                          ButtonSegment(
                            value: ThemeMode.system,
                            label: Text('System'),
                            icon: Icon(Icons.settings_system_daydream_rounded, size: 16),
                          ),
                        ],
                        selected: {themeMode},
                        onSelectionChanged: (set) {
                          ref.read(themeModeProvider.notifier).setThemeMode(set.first);
                        },
                      ),
                    ],
                  ),
                ),
                AppSpacing.verticalSpaceSm,

                // Language Selector (English & Hindi)
                LegalCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isHindi ? 'भाषा (Language)' : 'Interface Language',
                            style: AppTypography.titleSmall.copyWith(
                              color: context.colors.onSurface,
                            ),
                          ),
                          Text(
                            isHindi ? 'वर्तमान: हिन्दी (Hindi)' : 'Current: English (US)',
                            style: AppTypography.bodySmall.copyWith(
                              color: context.colors.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'en', label: Text('EN')),
                          ButtonSegment(value: 'hi', label: Text('हिन्दी')),
                        ],
                        selected: {locale.languageCode},
                        onSelectionChanged: (val) {
                          final code = val.first;
                          ref.read(localeProvider.notifier).setLocale(
                                Locale(code, code == 'hi' ? 'IN' : 'US'),
                              );
                        },
                      ),
                    ],
                  ),
                ),
                AppSpacing.verticalSpaceSm,

                // Notification Toggle
                LegalCard(
                  child: SwitchListTile(
                    title: Text(
                      isHindi ? 'सूचनाएं' : 'Push Notifications',
                      style: AppTypography.titleSmall.copyWith(
                        color: context.colors.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      isHindi
                          ? 'केस अपडेट और नोटिस की समयसीमा'
                          : 'Legal notice deadlines & case reminders',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    value: storage.getNotificationsEnabled(),
                    activeTrackColor: AppColors.accentViolet,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      storage.setNotificationsEnabled(val);
                      (context as Element).markNeedsBuild();
                    },
                  ),
                ),
                AppSpacing.verticalSpaceLg,

                // System & Legal Section
                Text(
                  'SYSTEM & COMPLIANCE',
                  style: AppTypography.labelLarge.copyWith(
                    color: context.colors.primary,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.verticalSpaceSm,

                LegalCard(
                  onTap: () => _showPrivacyDialog(context),
                  isInteractive: true,
                  child: Row(
                    children: [
                      const Icon(Icons.shield_outlined, color: AppColors.accentVioletLight),
                      AppSpacing.horizontalSpaceMd,
                      Expanded(
                        child: Text(
                          'Privacy Policy & Data Security',
                          style: AppTypography.bodyMedium.copyWith(
                            color: context.colors.onSurface,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 20),
                    ],
                  ),
                ),
                AppSpacing.verticalSpaceSm,

                // Public GitHub Link (Mandatory Requirement)
                LegalCard(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Public GitHub: ${AppConstants.githubRepoUrl}'),
                      ),
                    );
                  },
                  isInteractive: true,
                  child: Row(
                    children: [
                      const Icon(Icons.code_rounded, color: AppColors.accentCyan),
                      AppSpacing.horizontalSpaceMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Public GitHub Repository',
                              style: AppTypography.bodyMedium.copyWith(
                                color: context.colors.onSurface,
                              ),
                            ),
                            Text(
                              AppConstants.githubRepoUrl,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.accentCyan,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.open_in_new_rounded, size: 18),
                    ],
                  ),
                ),
                AppSpacing.verticalSpaceXl,

                // Logout Button
                LegalButton(
                  text: isHindi ? 'लॉग आउट' : 'Sign Out',
                  variant: LegalButtonVariant.outline,
                  icon: Icons.logout_rounded,
                  onPressed: () async {
                    await ref.read(authControllerProvider.notifier).logout();
                    if (context.mounted) {
                      context.go(RouteNames.login);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
