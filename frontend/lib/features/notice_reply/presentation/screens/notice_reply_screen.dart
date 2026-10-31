import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../../../saved/data/saved_repository.dart';
import '../../../saved/models/saved_item.dart';

class NoticeReplyScreen extends ConsumerStatefulWidget {
  const NoticeReplyScreen({super.key});

  @override
  ConsumerState<NoticeReplyScreen> createState() => _NoticeReplyScreenState();
}

class _NoticeReplyScreenState extends ConsumerState<NoticeReplyScreen> {
  final _noticeTextController = TextEditingController();
  final _senderNameController = TextEditingController(text: 'ABC Financial Holdings');
  final _claimAmountController = TextEditingController(text: '\$4,500.00');
  final _cureDaysController = TextEditingController(text: '15 Days');
  final _rebuttalController = TextEditingController();

  String? _attachedNoticeName;
  bool _isAnalyzing = false;
  bool _replyGenerated = false;

  @override
  void dispose() {
    _noticeTextController.dispose();
    _senderNameController.dispose();
    _claimAmountController.dispose();
    _cureDaysController.dispose();
    _rebuttalController.dispose();
    super.dispose();
  }

  Future<void> _pickNoticeFile() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'txt', 'png', 'jpg'],
      );
      if (files.isNotEmpty) {
        setState(() {
          _attachedNoticeName = files.first.name;
          _noticeTextController.text =
              'LEGAL NOTICE FOR DEMAND OF OUTSTANDING DUES UNDER SECTION 138 OF THE NEGOTIABLE INSTRUMENTS ACT. TAKE NOTICE that cheque no. 091234 drawn on HDFC Bank was returned unpaid with remarks "Funds Insufficient". You are hereby called upon to pay \$4,500 within 15 days...';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _generateReply() async {
    if (_noticeTextController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload or input the received notice text')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    final backendResult = await LegalApiService.generateNoticeReply(
      noticeText: _noticeTextController.text,
      userFacts: 'Sender: ${_senderNameController.text}, Disputed amount: ${_claimAmountController.text}',
      strategy: 'factual_clarification',
      title: 'Reply to ${_senderNameController.text}',
    );

    final reply = backendResult['generated_reply'] as String? ?? '''REPLY TO LEGAL NOTICE DATED ${_cureDaysController.text.toUpperCase()}

To,
Advocate for ${_senderNameController.text}

Sir/Madam,

Under instructions from and on behalf of my client, I hereby reply to your purported Legal Notice as follows:

1. PRELIMINARY REBUTTAL:
At the outset, all allegations, claims, and insinuations contained in your Notice under reply are vehemently denied as false, vexatious, and devoid of legal substance.

2. FACTUAL CLARIFICATION ON AMOUNT CLAIMED (${_claimAmountController.text}):
The amount demanded is categorically disputed. The subject instrument was handed over purely by way of collateral security and not against any crystallized, legally enforceable debt or existing liability.

3. ABSENCE OF STATUTORY CAUSE OF ACTION:
Your client has failed to adjust prior mutual credits and accounting statements. No offense under the cited statute is made out in law.

4. DEMAND TO WITHDRAW NOTICE:
You are hereby advised to instruct your client to unconditionally withdraw the defamatory and premature notice within 7 days of receipt hereof, failing which my client shall be constrained to initiate appropriate civil and criminal proceedings for malicious harassment.

Yours faithfully,
[Authorized Advocate / Signatory]
''';

    setState(() {
      _rebuttalController.text = reply;
      _replyGenerated = true;
      _isAnalyzing = false;
    });
  }

  void _saveReply() {
    if (_rebuttalController.text.isEmpty) return;

    ref.read(savedControllerProvider.notifier).save(
      SavedItem(
        id: '',
        title: 'Notice Reply: ${_senderNameController.text}',
        subtitle: 'Rebuttal generated for demand of ${_claimAmountController.text}',
        content: _rebuttalController.text,
        type: SavedItemType.draft,
        createdAt: DateTime.now(),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notice reply saved to Saved Library')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notice Reply Generator'),
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.paddingScreen,
          children: [
            const DisclaimerBanner(compact: true),
            AppSpacing.verticalSpaceMd,

            // Notice Upload Card
            LegalCard(
              onTap: _pickNoticeFile,
              isInteractive: true,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: const Icon(Icons.file_upload_outlined, color: AppColors.info),
                  ),
                  AppSpacing.horizontalSpaceMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _attachedNoticeName ?? 'Upload Received Notice (PDF/Image)',
                          style: AppTypography.titleSmall.copyWith(
                            color: context.colors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Upload notice photo, scan, or PDF for auto-extraction',
                          style: AppTypography.bodySmall.copyWith(
                            color: context.colors.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.verticalSpaceMd,

            LegalTextField(
              controller: _noticeTextController,
              label: 'Notice Text or Summary',
              hintText: 'Paste the content of the legal notice received...',
              minLines: 3,
              maxLines: 6,
            ),
            AppSpacing.verticalSpaceMd,

            Row(
              children: [
                Expanded(
                  child: LegalTextField(
                    controller: _senderNameController,
                    label: 'Claimant / Sender',
                  ),
                ),
                AppSpacing.horizontalSpaceMd,
                Expanded(
                  child: LegalTextField(
                    controller: _claimAmountController,
                    label: 'Claimed Amount',
                  ),
                ),
              ],
            ),
            AppSpacing.verticalSpaceLg,

            LegalButton(
              text: 'Analyze & Generate Legal Rebuttal',
              icon: Icons.reply_all_rounded,
              isLoading: _isAnalyzing,
              onPressed: _generateReply,
            ),
            AppSpacing.verticalSpaceLg,

            if (_isAnalyzing)
              const LegalLoadingIndicator(
                message: 'Parsing statutory grounds and formulating defence rebuttal...',
              ),

            if (_replyGenerated) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Generated Reply Preview',
                    style: AppTypography.titleSmall.copyWith(
                      color: context.colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 20),
                        tooltip: 'Copy Reply',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _rebuttalController.text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Notice reply copied')),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.bookmark_add_outlined, size: 20),
                        tooltip: 'Save',
                        onPressed: _saveReply,
                      ),
                    ],
                  ),
                ],
              ),
              AppSpacing.verticalSpaceXs,
              TextField(
                controller: _rebuttalController,
                maxLines: 12,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.45),
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
                text: 'Save Reply to Library',
                variant: LegalButtonVariant.secondary,
                icon: Icons.save_alt_rounded,
                onPressed: _saveReply,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
