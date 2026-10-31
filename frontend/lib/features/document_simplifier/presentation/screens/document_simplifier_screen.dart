import 'package:file_picker/file_picker.dart';
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

enum SimplificationMode {
  plainEnglish,
  clauseByClause,
  riskHighlights,
}

class DocumentSimplifierScreen extends ConsumerStatefulWidget {
  const DocumentSimplifierScreen({super.key});

  @override
  ConsumerState<DocumentSimplifierScreen> createState() => _DocumentSimplifierScreenState();
}

class _DocumentSimplifierScreenState extends ConsumerState<DocumentSimplifierScreen> {
  final _textController = TextEditingController();
  String? _pickedFileName;
  SimplificationMode _selectedMode = SimplificationMode.plainEnglish;
  bool _isProcessing = false;
  String? _simplifiedResult;
  bool _isPlayingAudio = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'doc', 'txt'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _pickedFileName = result.files.first.name;
          _textController.text =
              '[Document: $_pickedFileName]\nWHEREAS the Licensor is the sole absolute owner of the premises, AND WHEREAS the Licensee is desirous of occupying the premises on a temporary leave and license basis for 11 months subject to non-refundable caution deposit and indemnification in case of premature termination...';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File selection error: $e')),
        );
      }
    }
  }

  Future<void> _simplifyDocument() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a file or paste legal text to simplify')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _simplifiedResult = null;
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    String result;
    switch (_selectedMode) {
      case SimplificationMode.plainEnglish:
        result = 'SUMMARY IN EVERYDAY ENGLISH:\n\n'
            '1. **What this agreement is**: A temporary 11-month rental permit, not a permanent tenancy.\n'
            '2. **Your Payment Obligations**: Monthly rent must be paid on or before the 5th of each month. Late fees apply after 5 days.\n'
            '3. **Security Deposit**: The owner holds 2 months of rent as a security deposit and must return it within 14 days of you moving out after deducting verified repairs.\n'
            '4. **Ending the Agreement**: Either party can end the deal early by providing 30 days written notice.';
        break;
      case SimplificationMode.clauseByClause:
        result = 'CLAUSE-BY-CLAUSE BREAKDOWN:\n\n'
            '• **Clause 1 (Grant of License)**: Gives you lawful permission to use the property without creating tenancy ownership rights.\n'
            '• **Clause 4 (Lock-in Period)**: Neither party may exit during the first 6 months without paying penalty damages equal to remaining months.\n'
            '• **Clause 8 (Maintenance & Repairs)**: Minor repairs under \$50 are your responsibility; structural damage remains landlord duty.\n'
            '• **Clause 12 (Dispute Arbitration)**: All disputes must be referred to a sole arbitrator in the designated jurisdiction.';
        break;
      case SimplificationMode.riskHighlights:
        result = 'HIGH-RISK WARNINGS & OBLIGATIONS:\n\n'
            '⚠️ **Unilateral Eviction Clause**: The document claims the owner can lock premises on 48 hours notice for minor breach. (Legally questionable under standard tenant protection laws).\n'
            '⚠️ **Forfeiture of Deposit**: Full deposit forfeiture upon early termination is an onerous penalty.\n'
            '💡 **Recommended Amendment**: Require 15 days written cure notice before any termination or deposit forfeiture.';
        break;
    }

    setState(() {
      _simplifiedResult = result;
      _isProcessing = false;
    });
  }

  void _saveToLibrary() {
    if (_simplifiedResult == null) return;

    ref.read(savedControllerProvider.notifier).save(
      SavedItem(
        id: '',
        title: _pickedFileName != null ? 'Simplified: $_pickedFileName' : 'Simplified Legal Clause',
        subtitle: 'Mode: ${_selectedMode.name}',
        content: 'ORIGINAL TEXT:\n${_textController.text}\n\nSIMPLIFIED ANALYSIS:\n$_simplifiedResult',
        type: SavedItemType.document,
        createdAt: DateTime.now(),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved simplified document to Saved Library')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Simplifier'),
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.paddingScreen,
          children: [
            const DisclaimerBanner(compact: true),
            AppSpacing.verticalSpaceMd,

            // File Upload / Drop Area
            LegalCard(
              onTap: _pickDocument,
              isInteractive: true,
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.accentCyan.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_upload_outlined,
                      size: 26,
                      color: AppColors.accentCyan,
                    ),
                  ),
                  AppSpacing.verticalSpaceSm,
                  Text(
                    _pickedFileName ?? 'Tap to Upload Legal Document',
                    style: AppTypography.titleSmall.copyWith(
                      color: context.colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppSpacing.verticalSpaceXxs,
                  Text(
                    'Supported file formats: PDF, DOCX, TXT, DOC (Up to 15MB)',
                    style: AppTypography.bodySmall.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.verticalSpaceMd,

            // Paste Text Alternative
            LegalTextField(
              controller: _textController,
              label: 'Or Paste Complex Legal Text Directly',
              hintText: 'Paste contract paragraphs, legal notices, or terms of service here...',
              minLines: 4,
              maxLines: 8,
            ),
            AppSpacing.verticalSpaceMd,

            // Simplification Options
            Text(
              'Simplification Mode',
              style: AppTypography.labelLarge.copyWith(
                color: context.colors.onSurface,
              ),
            ),
            AppSpacing.verticalSpaceXs,
            SegmentedButton<SimplificationMode>(
              segments: const [
                ButtonSegment(
                  value: SimplificationMode.plainEnglish,
                  label: Text('Plain English'),
                  icon: Icon(Icons.language_rounded, size: 16),
                ),
                ButtonSegment(
                  value: SimplificationMode.clauseByClause,
                  label: Text('Clauses'),
                  icon: Icon(Icons.list_alt_rounded, size: 16),
                ),
                ButtonSegment(
                  value: SimplificationMode.riskHighlights,
                  label: Text('Risks'),
                  icon: Icon(Icons.warning_amber_rounded, size: 16),
                ),
              ],
              selected: {_selectedMode},
              onSelectionChanged: (val) {
                setState(() {
                  _selectedMode = val.first;
                });
              },
            ),
            AppSpacing.verticalSpaceLg,

            LegalButton(
              text: 'Simplify Document with AI',
              icon: Icons.auto_awesome,
              isLoading: _isProcessing,
              onPressed: _simplifyDocument,
            ),
            AppSpacing.verticalSpaceLg,

            // Result Display
            if (_isProcessing)
              const LegalLoadingIndicator(
                message: 'Deconstructing legal clauses and evaluating risks...',
              ),

            if (_simplifiedResult != null) ...[
              LegalCard(
                padding: AppSpacing.paddingMd,
                backgroundColor: context.legalTheme.elevatedSurface,
                borderColor: AppColors.accentCyan.withValues(alpha: 0.4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
                        AppSpacing.horizontalSpaceXs,
                        Text(
                          'Simplified Analysis',
                          style: AppTypography.titleSmall.copyWith(
                            color: context.colors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            _isPlayingAudio ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
                            color: AppColors.accentCyan,
                          ),
                          tooltip: 'Read Aloud',
                          onPressed: () {
                            setState(() {
                              _isPlayingAudio = !_isPlayingAudio;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_isPlayingAudio
                                    ? 'Simulating audio read-aloud...'
                                    : 'Audio stopped'),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 20),
                          tooltip: 'Copy',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _simplifiedResult!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Analysis copied to clipboard')),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.bookmark_add_outlined, size: 20),
                          tooltip: 'Save',
                          onPressed: _saveToLibrary,
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    SelectableText(
                      _simplifiedResult!,
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.colors.onSurface,
                        height: 1.6,
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
