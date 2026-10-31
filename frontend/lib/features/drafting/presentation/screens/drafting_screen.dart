import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/disclaimer_banner.dart';
import '../../../../core/widgets/legal_button.dart';
import '../../../../core/widgets/legal_card.dart';
import '../../../../core/widgets/legal_loading_indicator.dart';
import '../../../../core/widgets/legal_text_field.dart';
import '../../../saved/data/saved_repository.dart';
import '../../../saved/models/saved_item.dart';

enum DraftType {
  nda('Non-Disclosure Agreement (NDA)', 'Mutual protection of trade secrets & proprietary data'),
  lease('Residential Lease Agreement', '11-month rental deed with standard deposit terms'),
  demandLetter('Formal Legal Demand Letter', 'Statutory payment recovery or performance demand'),
  freelance('Freelance Services Contract', 'Milestones, IP ownership transfer, and payment schedule'),
  ceaseAndDesist('Cease & Desist Notice', 'Formal notice against IP infringement or defamation');

  final String title;
  final String description;
  const DraftType(this.title, this.description);
}

class DraftingScreen extends ConsumerStatefulWidget {
  const DraftingScreen({super.key});

  @override
  ConsumerState<DraftingScreen> createState() => _DraftingScreenState();
}

class _DraftingScreenState extends ConsumerState<DraftingScreen> {
  DraftType _selectedType = DraftType.nda;
  final _partyOneController = TextEditingController(text: 'Acme Technologies Pvt Ltd');
  final _partyTwoController = TextEditingController(text: 'John Doe, Independent Consultant');
  final _effectiveDateController = TextEditingController(text: 'November 1, 2026');
  final _jurisdictionController = TextEditingController(text: 'New Delhi, India');
  final _keyTermsController = TextEditingController(text: '2-year non-disclosure confidentiality term with \$10,000 liquidated damages clause.');

  final _generatedDraftController = TextEditingController();
  bool _isGenerating = false;
  bool _hasGenerated = false;

  @override
  void dispose() {
    _partyOneController.dispose();
    _partyTwoController.dispose();
    _effectiveDateController.dispose();
    _jurisdictionController.dispose();
    _keyTermsController.dispose();
    _generatedDraftController.dispose();
    super.dispose();
  }

  Future<void> _generateDraft() async {
    setState(() {
      _isGenerating = true;
    });

    await Future.delayed(const Duration(milliseconds: 1400));

    final draft = '''${_selectedType.title.toUpperCase()}

This Agreement is entered into on this ${_effectiveDateController.text}, by and between:

FIRST PARTY (Disclosing / Primary Party):
${_partyOneController.text}

AND

SECOND PARTY (Receiving / Counter Party):
${_partyTwoController.text}

1. PURPOSE & SCOPE
The parties intend to engage in collaborative discussions and mutual business evaluation. In connection therewith, certain confidential, proprietary, and commercial information may be disclosed.

2. OBLIGATIONS & RESTRICTIONS
${_keyTermsController.text}
The Receiving Party agrees to exercise at least standard professional degree of care to preserve confidentiality and not to disclose such information to third parties without prior express written consent.

3. GOVERNING LAW & JURISDICTION
This Agreement and any dispute or controversy arising out of or in connection with it shall be governed by, and construed in accordance with, the laws of ${_jurisdictionController.text}.

4. ENTIRE AGREEMENT & AMENDMENTS
This instrument contains the entire understanding between the parties concerning its subject matter.

IN WITNESS WHEREOF, the parties hereto have executed this Agreement as of the date first written above.

_____________________________                _____________________________
For: ${_partyOneController.text}               For: ${_partyTwoController.text}
Authorized Signatory                         Authorized Signatory
''';

    setState(() {
      _generatedDraftController.text = draft;
      _hasGenerated = true;
      _isGenerating = false;
    });
  }

  void _saveDraft() {
    if (_generatedDraftController.text.trim().isEmpty) return;

    ref.read(savedControllerProvider.notifier).save(
      SavedItem(
        id: '',
        title: _selectedType.title,
        subtitle: 'Parties: ${_partyOneController.text} & ${_partyTwoController.text}',
        content: _generatedDraftController.text,
        type: SavedItemType.draft,
        createdAt: DateTime.now(),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Draft saved to library')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drafting Assistant'),
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.paddingScreen,
          children: [
            const DisclaimerBanner(compact: true),
            AppSpacing.verticalSpaceMd,

            // Draft Type Selector
            Text(
              'Select Agreement or Instrument Type',
              style: AppTypography.labelLarge.copyWith(
                color: context.colors.onSurface,
              ),
            ),
            AppSpacing.verticalSpaceXs,
            ...DraftType.values.map(
              (type) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: LegalCard(
                  onTap: () {
                    setState(() {
                      _selectedType = type;
                    });
                  },
                  isInteractive: true,
                  borderColor: _selectedType == type
                      ? AppColors.accentPurple
                      : context.legalTheme.cardBorder,
                  child: Row(
                    children: [
                      Radio<DraftType>(
                        value: type,
                        groupValue: _selectedType, // ignore: deprecated_member_use
                        activeColor: AppColors.accentPurple,
                        onChanged: (val) { // ignore: deprecated_member_use
                          if (val != null) setState(() => _selectedType = val);
                        },
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              type.title,
                              style: AppTypography.titleSmall.copyWith(
                                color: context.colors.onSurface,
                              ),
                            ),
                            Text(
                              type.description,
                              style: AppTypography.bodySmall.copyWith(
                                color: context.colors.onSurface.withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AppSpacing.verticalSpaceMd,

            // Form Inputs
            Text(
              'Instrument Parameters',
              style: AppTypography.titleSmall.copyWith(
                color: context.colors.onSurface,
              ),
            ),
            AppSpacing.verticalSpaceSm,
            LegalTextField(
              controller: _partyOneController,
              label: 'Party One (Disclosing / Landlord / Issuer)',
              hintText: 'Enter full legal name or registered entity',
            ),
            AppSpacing.verticalSpaceSm,
            LegalTextField(
              controller: _partyTwoController,
              label: 'Party Two (Counterparty / Recipient / Tenant)',
              hintText: 'Enter full legal name or registered entity',
            ),
            AppSpacing.verticalSpaceSm,
            Row(
              children: [
                Expanded(
                  child: LegalTextField(
                    controller: _effectiveDateController,
                    label: 'Effective Date',
                    hintText: 'e.g. Nov 1, 2026',
                  ),
                ),
                AppSpacing.horizontalSpaceMd,
                Expanded(
                  child: LegalTextField(
                    controller: _jurisdictionController,
                    label: 'Governing Jurisdiction',
                    hintText: 'e.g. New Delhi, India',
                  ),
                ),
              ],
            ),
            AppSpacing.verticalSpaceSm,
            LegalTextField(
              controller: _keyTermsController,
              label: 'Key Commercial Terms & Specific Clauses',
              hintText: 'Specify compensation, term length, non-compete, or penalty conditions...',
              maxLines: 3,
            ),
            AppSpacing.verticalSpaceLg,

            LegalButton(
              text: 'Generate Legal Draft',
              icon: Icons.auto_awesome,
              isLoading: _isGenerating,
              onPressed: _generateDraft,
            ),
            AppSpacing.verticalSpaceLg,

            if (_isGenerating)
              const LegalLoadingIndicator(
                message: 'Synthesizing standard legal covenants and recitals...',
              ),

            // Editable Generated Output
            if (_hasGenerated) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Editable Draft Output',
                    style: AppTypography.titleSmall.copyWith(
                      color: context.colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 20),
                        tooltip: 'Copy Draft',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _generatedDraftController.text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Draft copied to clipboard')),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.bookmark_add_outlined, size: 20),
                        tooltip: 'Save Draft',
                        onPressed: _saveDraft,
                      ),
                    ],
                  ),
                ],
              ),
              AppSpacing.verticalSpaceXs,
              TextField(
                controller: _generatedDraftController,
                maxLines: 14,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  height: 1.45,
                ),
                decoration: InputDecoration(
                  fillColor: context.legalTheme.elevatedSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: BorderSide(color: context.legalTheme.cardBorder),
                  ),
                ),
              ),
              AppSpacing.verticalSpaceMd,
              LegalButton(
                text: 'Save Draft to Saved Library',
                icon: Icons.save_alt_rounded,
                variant: LegalButtonVariant.secondary,
                onPressed: _saveDraft,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
