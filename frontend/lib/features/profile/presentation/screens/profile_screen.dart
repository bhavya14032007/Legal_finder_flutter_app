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
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      AppSpacing.verticalSpaceSm,
                      _ThemeModeSelector(
                        currentMode: themeMode,
                        onModeChanged: (mode) {
                          ref.read(themeModeProvider.notifier).setThemeMode(mode);
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
                            isHindi ? 'इंटरफ़ेस भाषा (Language)' : 'Interface Language',
                            style: AppTypography.titleSmall.copyWith(
                              color: context.colors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isHindi ? 'वर्तमान: हिन्दी (भारत)' : 'Current: English (India)',
                            style: AppTypography.bodySmall.copyWith(
                              color: context.colors.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      _LanguageSelector(
                        currentCode: locale.languageCode,
                        onLanguageChanged: (code) {
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

class _ThemeModeSelector extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onModeChanged;

  const _ThemeModeSelector({
    required this.currentMode,
    required this.onModeChanged,
  });

  Widget _buildOption({
    required BuildContext context,
    required ThemeMode mode,
    required String label,
    required IconData icon,
  }) {
    final isSelected = currentMode == mode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () => onModeChanged(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF6366F1) : const Color(0xFF4F46E5))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected
                    ? Colors.white
                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerBg = isDark ? const Color(0xFF101524) : const Color(0xFFF1F5F9);
    final containerBorder = isDark ? const Color(0xFF1E2840) : const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: containerBorder, width: 1.1),
      ),
      child: Row(
        children: [
          _buildOption(
            context: context,
            mode: ThemeMode.dark,
            label: 'Midnight',
            icon: Icons.nightlight_round,
          ),
          _buildOption(
            context: context,
            mode: ThemeMode.light,
            label: 'Light',
            icon: Icons.wb_sunny_rounded,
          ),
          _buildOption(
            context: context,
            mode: ThemeMode.system,
            label: 'System',
            icon: Icons.devices_rounded,
          ),
        ],
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final String currentCode;
  final ValueChanged<String> onLanguageChanged;

  const _LanguageSelector({
    required this.currentCode,
    required this.onLanguageChanged,
  });

  Widget _buildOption({
    required BuildContext context,
    required String code,
    required String label,
  }) {
    final isSelected = currentCode == code;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onLanguageChanged(code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF6366F1) : const Color(0xFF4F46E5))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(
                Icons.check_rounded,
                size: 14,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerBg = isDark ? const Color(0xFF101524) : const Color(0xFFF1F5F9);
    final containerBorder = isDark ? const Color(0xFF1E2840) : const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: containerBorder, width: 1.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOption(
            context: context,
            code: 'en',
            label: 'EN',
          ),
          _buildOption(
            context: context,
            code: 'hi',
            label: 'हिंदी',
          ),
        ],
      ),
    );
  }
}
