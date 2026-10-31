import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/legal_button.dart';
import '../../../../core/widgets/legal_card.dart';
import '../../../../core/widgets/legal_empty_state.dart';
import '../../../../core/widgets/legal_text_field.dart';

class TimelineEntry {
  final String id;
  final String date;
  final String title;
  final String description;
  final String? attachedEvidence;
  final String category; // Communication, Payment, Contract, Incident

  const TimelineEntry({
    required this.id,
    required this.date,
    required this.title,
    required this.description,
    this.attachedEvidence,
    required this.category,
  });
}

class EvidenceTimelineScreen extends StatefulWidget {
  const EvidenceTimelineScreen({super.key});

  @override
  State<EvidenceTimelineScreen> createState() => _EvidenceTimelineScreenState();
}

class _EvidenceTimelineScreenState extends State<EvidenceTimelineScreen> {
  final List<TimelineEntry> _entries = [
    const TimelineEntry(
      id: 'e-1',
      date: 'Oct 01, 2026',
      title: 'Initial Contract Execution',
      description: 'Signed residential lease deed with security deposit of \$2,400 transferred via NEFT.',
      attachedEvidence: 'Lease_Deed_Signed.pdf & Bank_Receipt.png',
      category: 'Contract',
    ),
    const TimelineEntry(
      id: 'e-2',
      date: 'Oct 15, 2026',
      title: 'First Notice of Water Damage Sent',
      description: 'Notified landlord via registered email regarding major ceiling pipe leakage.',
      attachedEvidence: 'Email_Thread_Receipt.eml',
      category: 'Communication',
    ),
    const TimelineEntry(
      id: 'e-3',
      date: 'Oct 24, 2026',
      title: 'Unlawful Deductions Demand',
      description: 'Landlord refused repairs and sent unauthorized demand for \$800 structural renovation.',
      attachedEvidence: 'WhatsApp_Export.txt',
      category: 'Incident',
    ),
  ];

  void _showAddEditModal([TimelineEntry? existing]) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final dateCtrl = TextEditingController(text: existing?.date ?? 'Oct 30, 2026');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final evidenceCtrl = TextEditingController(text: existing?.attachedEvidence ?? '');
    String cat = existing?.category ?? 'Incident';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.legalTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                existing == null ? 'Add Timeline Event' : 'Edit Timeline Event',
                style: AppTypography.titleMedium.copyWith(
                  color: context.colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              AppSpacing.verticalSpaceMd,
              LegalTextField(
                controller: titleCtrl,
                label: 'Event Title',
                hintText: 'e.g. Email refusal received',
              ),
              AppSpacing.verticalSpaceSm,
              LegalTextField(
                controller: dateCtrl,
                label: 'Incident Date',
                hintText: 'e.g. Oct 25, 2026',
              ),
              AppSpacing.verticalSpaceSm,
              LegalTextField(
                controller: descCtrl,
                label: 'Fact Summary & Witnesses',
                hintText: 'Describe exactly what happened chronologically...',
                minLines: 3,
                maxLines: 5,
              ),
              AppSpacing.verticalSpaceSm,
              LegalTextField(
                controller: evidenceCtrl,
                label: 'Attached Document or Proof Name',
                hintText: 'e.g. Screenshot_Call_Log.png',
              ),
              AppSpacing.verticalSpaceLg,
              LegalButton(
                text: existing == null ? 'Save to Timeline' : 'Update Event',
                onPressed: () {
                  if (titleCtrl.text.trim().isEmpty) return;
                  setState(() {
                    if (existing != null) {
                      final idx = _entries.indexWhere((e) => e.id == existing.id);
                      if (idx != -1) {
                        _entries[idx] = TimelineEntry(
                          id: existing.id,
                          date: dateCtrl.text,
                          title: titleCtrl.text,
                          description: descCtrl.text,
                          attachedEvidence: evidenceCtrl.text.isNotEmpty ? evidenceCtrl.text : null,
                          category: cat,
                        );
                      }
                    } else {
                      _entries.insert(
                        0,
                        TimelineEntry(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          date: dateCtrl.text,
                          title: titleCtrl.text,
                          description: descCtrl.text,
                          attachedEvidence: evidenceCtrl.text.isNotEmpty ? evidenceCtrl.text : null,
                          category: cat,
                        ),
                      );
                    }
                  });
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evidence & Case Timeline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Add Incident Event',
            onPressed: () => _showAddEditModal(),
          ),
        ],
      ),
      body: SafeArea(
        child: _entries.isEmpty
            ? LegalEmptyState(
                title: 'No Timeline Events',
                message: 'Chronologically log dates, communications, payments, and photos to construct an evidentiary chain for counsel.',
                actionLabel: 'Log First Event',
                onAction: () => _showAddEditModal(),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: _entries.length,
                itemBuilder: (context, index) {
                  final entry = _entries[index];
                  final isLast = index == _entries.length - 1;

                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Timeline Column
                        Column(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: AppColors.warning,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: context.legalTheme.cardBackground,
                                  width: 3,
                                ),
                              ),
                            ),
                            if (!isLast)
                              Expanded(
                                child: Container(
                                  width: 2,
                                  color: AppColors.warning.withValues(alpha: 0.3),
                                ),
                              ),
                          ],
                        ),
                        AppSpacing.horizontalSpaceMd,

                        // Event Card
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                            child: LegalCard(
                              onTap: () => _showAddEditModal(entry),
                              padding: AppSpacing.paddingMd,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        entry.date,
                                        style: AppTypography.labelSmall.copyWith(
                                          color: AppColors.warning,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: context.legalTheme.elevatedSurface,
                                          borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                                        ),
                                        child: Text(
                                          entry.category,
                                          style: AppTypography.labelSmall.copyWith(fontSize: 10),
                                        ),
                                      ),
                                    ],
                                  ),
                                  AppSpacing.verticalSpaceXs,
                                  Text(
                                    entry.title,
                                    style: AppTypography.titleSmall.copyWith(
                                      color: context.colors.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  AppSpacing.verticalSpaceXxs,
                                  Text(
                                    entry.description,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: context.colors.onSurface.withValues(alpha: 0.75),
                                      height: 1.45,
                                    ),
                                  ),
                                  if (entry.attachedEvidence != null) ...[
                                    AppSpacing.verticalSpaceSm,
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.attach_file_rounded,
                                          size: 14,
                                          color: AppColors.accentVioletLight,
                                        ),
                                        AppSpacing.horizontalSpaceXxs,
                                        Expanded(
                                          child: Text(
                                            entry.attachedEvidence!,
                                            style: AppTypography.bodySmall.copyWith(
                                              fontSize: 11,
                                              color: AppColors.accentVioletLight,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

