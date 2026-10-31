import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/disclaimer_banner.dart';
import '../../../../core/widgets/legal_button.dart';
import '../../../../core/widgets/legal_card.dart';
import '../../../../core/widgets/legal_text_field.dart';

class LawyerPrepScreen extends StatefulWidget {
  const LawyerPrepScreen({super.key});

  @override
  State<LawyerPrepScreen> createState() => _LawyerPrepScreenState();
}

class _LawyerPrepScreenState extends State<LawyerPrepScreen> {
  final _caseSummaryController = TextEditingController(
    text: 'Dispute regarding wrongful withholding of \$3,200 commercial deposit despite satisfactory handover on Oct 15, 2026.',
  );
  final _reliefSoughtController = TextEditingController(
    text: 'Full refund of security deposit with 18% statutory interest and compensation for arbitrary delay.',
  );

  final Map<String, bool> _checklist = {
    'Collected primary signed agreement / contract copy': true,
    'Compiled chronological bank payment statements': true,
    'Printed or saved digital email threads & WhatsApp exports': true,
    'Drafted factual 1-page timeline of events': false,
    'Identified potential witnesses & third-party correspondence': false,
  };

  static const List<Map<String, dynamic>> _suggestedQuestions = [
    {
      'category': 'FEE STRUCTURE & COSTS',
      'questions': [
        'What is your fee billing structure (per-hearing, lump-sum retainer, or stage-based)?',
        'Are court filing fees, clerical typing expenses, and process fees included or separate?',
      ],
    },
    {
      'category': 'CASE MERITS & REALISTIC ODDS',
      'questions': [
        'Based on judicial precedents in this forum, what is our realistic likelihood of success?',
        'What are the strongest vulnerabilities in our evidence that the opposing party will attack?',
      ],
    },
    {
      'category': 'TIMELINE & PROCEDURE',
      'questions': [
        'How many months or years does a typical trial take in this specific jurisdiction?',
        'Is mandatory mediation or conciliation available before contested litigation?',
      ],
    },
  ];

  @override
  void dispose() {
    _caseSummaryController.dispose();
    _reliefSoughtController.dispose();
    super.dispose();
  }

  void _copyConsultationDossier() {
    final buffer = StringBuffer();
    buffer.writeln('LAWYER CONSULTATION PREPARATION DOSSIER\n');
    buffer.writeln('CASE SUMMARY:\n${_caseSummaryController.text}\n');
    buffer.writeln('RELIEF SOUGHT:\n${_reliefSoughtController.text}\n');
    buffer.writeln('DOCUMENTATION CHECKLIST:');
    _checklist.forEach((k, v) {
      buffer.writeln('  [${v ? "X" : " "}] $k');
    });
    buffer.writeln('\nKEY QUESTIONS TO ASK COUNSEL:');
    for (final section in _suggestedQuestions) {
      buffer.writeln('--- ${section["category"]} ---');
      for (final q in section["questions"] as List<String>) {
        buffer.writeln('• $q');
      }
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Consultation Dossier copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lawyer Preparation Kit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Export Dossier',
            onPressed: _copyConsultationDossier,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.paddingScreen,
          children: [
            const DisclaimerBanner(compact: true),
            AppSpacing.verticalSpaceMd,

            // Case Information Form
            Text(
              '1. Case Foundation Summary',
              style: AppTypography.titleSmall.copyWith(
                color: context.colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpacing.verticalSpaceSm,
            LegalTextField(
              controller: _caseSummaryController,
              label: 'Succinct Fact Description (For Counsel)',
              minLines: 3,
              maxLines: 5,
            ),
            AppSpacing.verticalSpaceSm,
            LegalTextField(
              controller: _reliefSoughtController,
              label: 'Exact Outcome / Relief You Want to Achieve',
              minLines: 2,
              maxLines: 4,
            ),
            AppSpacing.verticalSpaceLg,

            // Checklist
            Text(
              '2. Pre-Consultation Checklist',
              style: AppTypography.titleSmall.copyWith(
                color: context.colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpacing.verticalSpaceSm,
            LegalCard(
              padding: AppSpacing.paddingXs,
              child: Column(
                children: _checklist.keys.map((item) {
                  return CheckboxListTile(
                    title: Text(item, style: AppTypography.bodySmall),
                    value: _checklist[item],
                    activeColor: AppColors.accentViolet,
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                    dense: true,
                    onChanged: (val) {
                      setState(() {
                        _checklist[item] = val ?? false;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            AppSpacing.verticalSpaceLg,

            // Suggested Questions to Ask
            Text(
              '3. Essential Questions to Ask Your Lawyer',
              style: AppTypography.titleSmall.copyWith(
                color: context.colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpacing.verticalSpaceSm,
            ..._suggestedQuestions.map((section) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: LegalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section['category'] as String,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.accentVioletLight,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      AppSpacing.verticalSpaceSm,
                      ...((section['questions'] as List<String>).map(
                        (q) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(color: AppColors.accentCyan)),
                              Expanded(
                                child: Text(
                                  q,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: context.colors.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              );
            }),
            AppSpacing.verticalSpaceMd,

            LegalButton(
              text: 'Copy Ready Consultation Dossier',
              icon: Icons.copy_rounded,
              onPressed: _copyConsultationDossier,
            ),
          ],
        ),
      ),
    );
  }
}

