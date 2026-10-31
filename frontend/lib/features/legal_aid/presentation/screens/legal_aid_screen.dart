import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/legal_api_service.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/disclaimer_banner.dart';
import '../../../../core/widgets/legal_button.dart';
import '../../../../core/widgets/legal_card.dart';

class LegalAidScreen extends StatefulWidget {
  const LegalAidScreen({super.key});

  @override
  State<LegalAidScreen> createState() => _LegalAidScreenState();
}

class _LegalAidScreenState extends State<LegalAidScreen> {
  bool _isWomanOrChild = false;
  bool _isScheduledOrMarginalized = false;
  bool _isInCustody = false;
  bool _annualIncomeUnderThreshold = true;
  bool _evaluated = false;
  bool _isEligible = true;
  List<Map<String, String>> _dynamicDirectories = [];

  @override
  void initState() {
    super.initState();
    _loadDirectory();
  }

  Future<void> _loadDirectory() async {
    final list = await LegalApiService.getLegalAidDirectory();
    if (list.isNotEmpty && mounted) {
      setState(() {
        _dynamicDirectories = list.map((item) {
          if (item is Map) {
            return {
              'title': item['title']?.toString() ?? 'Legal Aid Authority',
              'tollFree': item['toll_free']?.toString() ?? '15100',
              'scope': item['scope']?.toString() ?? 'State-funded legal counsel and consultation.',
            };
          }
          return {
            'title': 'Legal Services Authority',
            'tollFree': '15100',
            'scope': 'Empanelled legal assistance.',
          };
        }).toList();
      });
    }
  }

  void _evaluateEligibility() {
    setState(() {
      _evaluated = true;
      _isEligible = _isWomanOrChild ||
          _isScheduledOrMarginalized ||
          _isInCustody ||
          _annualIncomeUnderThreshold;
    });
  }

  static const List<Map<String, String>> _legalAidDirectories = [
    {
      'title': 'National Legal Services Authority (NALSA)',
      'tollFree': '15100 (24x7 National Legal Aid Helpline)',
      'scope': 'Free legal aid, counsel assignment, and Lok Adalat dispute settlement across India.',
      'url': 'https://nalsa.gov.in',
    },
    {
      'title': 'State & District Legal Services Authority (DLSA)',
      'tollFree': 'Located at every District Court Complex',
      'scope': 'Appoints empanelled advocates free of cost for qualifying citizens in civil and criminal courts.',
      'url': 'District Court Complex Front Desk',
    },
    {
      'title': 'Tele-Law Portal (Ministry of Law & Justice)',
      'tollFree': 'Available at Common Service Centers (CSCs)',
      'scope': 'Video-conferencing consultation with panel lawyers at grassroot village panchayat levels.',
      'url': 'https://tele-law.in',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Free Legal Aid & Pro Bono'),
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.paddingScreen,
          children: [
            const DisclaimerBanner(compact: true),
            AppSpacing.verticalSpaceMd,

            // Constitutional Right Banner
            LegalCard(
              backgroundColor: AppColors.success.withValues(alpha: 0.1),
              borderColor: AppColors.success.withValues(alpha: 0.3),
              child: Row(
                children: [
                  const Icon(Icons.volunteer_activism_rounded, color: AppColors.success, size: 28),
                  AppSpacing.horizontalSpaceMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Constitutional Right to Counsel',
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Under Article 39A & Legal Services Authorities Act 1987, the state provides free legal aid to ensure justice is not denied due to economic or other disabilities.',
                          style: AppTypography.bodySmall.copyWith(
                            color: context.colors.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.verticalSpaceLg,

            Text(
              '1. Instant Eligibility Assessment',
              style: AppTypography.titleSmall.copyWith(
                color: context.colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpacing.verticalSpaceSm,
            LegalCard(
              padding: AppSpacing.paddingXs,
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Annual family income under ₹3,00,000 (\$3,600)'),
                    value: _annualIncomeUnderThreshold,
                    activeTrackColor: AppColors.success,
                    dense: true,
                    onChanged: (v) => setState(() => _annualIncomeUnderThreshold = v),
                  ),
                  SwitchListTile(
                    title: const Text('Woman or Child applicant'),
                    value: _isWomanOrChild,
                    activeTrackColor: AppColors.success,
                    dense: true,
                    onChanged: (v) => setState(() => _isWomanOrChild = v),
                  ),
                  SwitchListTile(
                    title: const Text('SC / ST or marginalized social category'),
                    value: _isScheduledOrMarginalized,
                    activeTrackColor: AppColors.success,
                    dense: true,
                    onChanged: (v) => setState(() => _isScheduledOrMarginalized = v),
                  ),
                  SwitchListTile(
                    title: const Text('Person in custody, prison, or protective home'),
                    value: _isInCustody,
                    activeTrackColor: AppColors.success,
                    dense: true,
                    onChanged: (v) => setState(() => _isInCustody = v),
                  ),
                ],
              ),
            ),
            AppSpacing.verticalSpaceMd,
            LegalButton(
              text: 'Check My Aid Eligibility',
              variant: LegalButtonVariant.secondary,
              onPressed: _evaluateEligibility,
            ),
            AppSpacing.verticalSpaceMd,

            if (_evaluated) ...[
              Container(
                padding: AppSpacing.paddingMd,
                decoration: BoxDecoration(
                  color: _isEligible ? AppColors.successBg : AppColors.warningBg,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: _isEligible ? AppColors.success : AppColors.warning,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isEligible ? Icons.check_circle : Icons.info_outline,
                      color: _isEligible ? AppColors.success : AppColors.warning,
                    ),
                    AppSpacing.horizontalSpaceMd,
                    Expanded(
                      child: Text(
                        _isEligible
                            ? 'You appear eligible for 100% Free Government Legal Counsel and waived court fee exemptions.'
                            : 'Based on your income, subsidized clinics and Lok Adalat conciliation remain open to you.',
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.verticalSpaceLg,
            ],

            Text(
              '2. Verified Assistance Directories & Helplines',
              style: AppTypography.titleSmall.copyWith(
                color: context.colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpacing.verticalSpaceSm,
            ...(_dynamicDirectories.isNotEmpty ? _dynamicDirectories : _legalAidDirectories).map(
              (res) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: LegalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        res['title']!,
                        style: AppTypography.titleSmall.copyWith(
                          color: context.colors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      AppSpacing.verticalSpaceXxs,
                      Row(
                        children: [
                          const Icon(Icons.call_rounded, size: 14, color: AppColors.success),
                          AppSpacing.horizontalSpaceXxs,
                          Text(
                            res['tollFree']!,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.verticalSpaceXs,
                      Text(
                        res['scope']!,
                        style: AppTypography.bodySmall.copyWith(
                          color: context.colors.onSurface.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
