import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/legal_api_service.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/disclaimer_banner.dart';
import '../../../../core/widgets/legal_button.dart';
import '../../../../core/widgets/legal_card.dart';
import '../../../../core/widgets/legal_loading_indicator.dart';
import '../../../../core/widgets/legal_text_field.dart';

class ScamAnalysisResult {
  final int riskScore; // 0 to 100
  final String riskLevel; // Low, Moderate, High, Critical
  final Color riskColor;
  final String summary;
  final List<String> redFlags;
  final List<String> recommendedActions;

  const ScamAnalysisResult({
    required this.riskScore,
    required this.riskLevel,
    required this.riskColor,
    required this.summary,
    required this.redFlags,
    required this.recommendedActions,
  });
}

class ScamDetectorScreen extends StatefulWidget {
  const ScamDetectorScreen({super.key});

  @override
  State<ScamDetectorScreen> createState() => _ScamDetectorScreenState();
}

class _ScamDetectorScreenState extends State<ScamDetectorScreen> {
  final _inputController = TextEditingController();
  final _urlController = TextEditingController();
  bool _isAnalyzing = false;
  ScamAnalysisResult? _analysis;

  @override
  void dispose() {
    _inputController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _analyzeInput() async {
    final text = _inputController.text.trim();
    final url = _urlController.text.trim();

    if (text.isEmpty && url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter message text, email body, or website link')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysis = null;
    });

    final backendScan = await LegalApiService.scanForScam(
      content: text.isNotEmpty ? text : null,
      url: url.isNotEmpty ? url : null,
    );

    final isHighRisk = backendScan.riskScore >= 60;
    final riskColor = isHighRisk ? AppColors.danger : (backendScan.riskScore >= 30 ? AppColors.warning : AppColors.success);

    final result = ScamAnalysisResult(
      riskScore: backendScan.riskScore,
      riskLevel: backendScan.riskLevel,
      riskColor: riskColor,
      summary: backendScan.detailedAnalysis.isNotEmpty
          ? backendScan.detailedAnalysis
          : 'Detailed AI security inspection completed.',
      redFlags: backendScan.suspiciousIndicators,
      recommendedActions: backendScan.recommendedActions,
    );

    setState(() {
      _analysis = result;
      _isAnalyzing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Scam & Fraud Detector'),
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.paddingScreen,
          children: [
            const DisclaimerBanner(compact: true),
            AppSpacing.verticalSpaceMd,

            LegalTextField(
              controller: _inputController,
              label: 'Suspicious Email, Message, or Contract Text',
              hintText: 'Paste WhatsApp messages, job offer letters, investment pitches, or suspicious emails...',
              minLines: 4,
              maxLines: 7,
            ),
            AppSpacing.verticalSpaceSm,

            LegalTextField(
              controller: _urlController,
              label: 'Suspicious Link or Website Domain (Optional)',
              hintText: 'e.g. https://secure-bank-login-update.online',
              prefixIcon: const Icon(Icons.link_rounded),
            ),
            AppSpacing.verticalSpaceLg,

            LegalButton(
              text: 'Run Scam & Fraud Inspection',
              icon: Icons.security_rounded,
              isLoading: _isAnalyzing,
              onPressed: _analyzeInput,
            ),
            AppSpacing.verticalSpaceLg,

            if (_isAnalyzing)
              const LegalLoadingIndicator(
                message: 'Evaluating fraud heuristics, phishing signals, and impersonation indicators...',
              ),

            if (_analysis != null) ...[
              LegalCard(
                padding: AppSpacing.paddingLg,
                backgroundColor: context.legalTheme.elevatedSurface,
                borderColor: _analysis!.riskColor.withValues(alpha: 0.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RISK EVALUATION',
                              style: AppTypography.labelSmall.copyWith(
                                color: context.colors.onSurface.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              _analysis!.riskLevel,
                              style: AppTypography.titleMedium.copyWith(
                                color: _analysis!.riskColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: _analysis!.riskColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: _analysis!.riskColor, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              '${_analysis!.riskScore}',
                              style: AppTypography.titleMedium.copyWith(
                                color: _analysis!.riskColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.verticalSpaceMd,
                    Text(
                      _analysis!.summary,
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.colors.onSurface,
                        height: 1.5,
                      ),
                    ),
                    AppSpacing.verticalSpaceMd,
                    const Divider(),
                    AppSpacing.verticalSpaceSm,
                    Text(
                      'Detected Red Flags:',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AppSpacing.verticalSpaceXs,
                    ..._analysis!.redFlags.map(
                      (rf) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('⚠️ ', style: TextStyle(fontSize: 12)),
                            Expanded(
                              child: Text(
                                rf,
                                style: AppTypography.bodySmall.copyWith(
                                  color: context.colors.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AppSpacing.verticalSpaceMd,
                    Text(
                      'Immediate Protective Actions:',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AppSpacing.verticalSpaceXs,
                    ..._analysis!.recommendedActions.map(
                      (action) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('🛡️ ', style: TextStyle(fontSize: 12)),
                            Expanded(
                              child: Text(
                                action,
                                style: AppTypography.bodySmall.copyWith(
                                  color: context.colors.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

