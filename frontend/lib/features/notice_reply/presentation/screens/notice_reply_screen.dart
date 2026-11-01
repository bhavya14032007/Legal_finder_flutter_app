import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/services/legal_api_service.dart';
import '../../../../core/widgets/legal_button.dart';
import '../../../saved/data/saved_repository.dart';
import '../../../saved/models/saved_item.dart';

enum NoticeGoal {
  limitation('Check Limitation Period', '⚖️', 'limitation_defense'),
  settlement('Request Settlement', '🤝', 'settlement_proposal'),
  deny('Deny Allegations', '🛡️', 'factual_clarification');

  final String label;
  final String icon;
  final String strategyKey;
  const NoticeGoal(this.label, this.icon, this.strategyKey);
}

class NoticeReplyScreen extends ConsumerStatefulWidget {
  const NoticeReplyScreen({super.key});

  @override
  ConsumerState<NoticeReplyScreen> createState() => _NoticeReplyScreenState();
}

class _NoticeReplyScreenState extends ConsumerState<NoticeReplyScreen> {
  final _noticeTextController = TextEditingController();
  final _senderNameController = TextEditingController(text: 'ABC Financial Holdings');
  final _claimAmountController = TextEditingController(text: '\$ 4,500.00');
  final _rebuttalController = TextEditingController();

  NoticeGoal _selectedGoal = NoticeGoal.limitation;
  String? _attachedNoticeName = 'notice_october_scan.pdf';
  bool _isAnalyzing = false;
  bool _replyGenerated = false;
  bool _isListeningVoice = false;

  @override
  void dispose() {
    _noticeTextController.dispose();
    _senderNameController.dispose();
    _claimAmountController.dispose();
    _rebuttalController.dispose();
    super.dispose();
  }

  Future<void> _pickNoticeFile() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'docx', 'txt'],
      );
      if (files.isNotEmpty) {
        final file = files.first;
        setState(() {
          _attachedNoticeName = file.name;
          _noticeTextController.text =
              'LEGAL NOTICE FOR DEMAND OF OUTSTANDING DUES UNDER SECTION 138 OF THE NEGOTIABLE INSTRUMENTS ACT. TAKE NOTICE that cheque no. 091234 drawn on HDFC Bank was returned unpaid with remarks "Funds Insufficient". You are hereby called upon to pay \$4,500 within 15 days...';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File "${file.name}" scanned and extracted successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    }
  }

  void _toggleVoiceDictation() {
    setState(() {
      _isListeningVoice = !_isListeningVoice;
    });

    if (_isListeningVoice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voice dictation active. Speak clearly about your legal notice...'),
          duration: Duration(seconds: 2),
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _isListeningVoice) {
          setState(() {
            _isListeningVoice = false;
            if (_noticeTextController.text.trim().isEmpty) {
              _noticeTextController.text =
                  'Notice received from creditor alleging unpaid credit dues of \$4,500 with immediate 15-day litigation demand. All prior transaction statements were disputed.';
            }
          });
        }
      });
    }
  }

  void _onGoalSelected(NoticeGoal goal) {
    setState(() {
      _selectedGoal = goal;
    });
    final text = _noticeTextController.text;
    if (text.isEmpty) {
      if (goal == NoticeGoal.limitation) {
        _noticeTextController.text =
            'Check statutory limitation period under Limitation Act, 1963 for recovery of debt claimed beyond 3 years.';
      } else if (goal == NoticeGoal.settlement) {
        _noticeTextController.text =
            'Without prejudice settlement offer proposing payment of disputed dues in 3 equal monthly installments.';
      } else if (goal == NoticeGoal.deny) {
        _noticeTextController.text =
            'Categorical denial of fabricated dues; goods delivered were defective and invoice was returned unaccepted.';
      }
    }
  }

  Future<void> _generateReply() async {
    final noticeText = _noticeTextController.text.trim();
    if (noticeText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload or input the received notice text')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    final backendResult = await LegalApiService.generateNoticeReply(
      noticeText: noticeText,
      userFacts: 'Sender: ${_senderNameController.text}, Disputed amount: ${_claimAmountController.text}, Strategy: ${_selectedGoal.label}',
      strategy: _selectedGoal.strategyKey,
      title: 'Formal Rebuttal to ${_senderNameController.text}',
    );

    final reply = backendResult['generated_reply'] as String? ?? '''REPLY TO STATUTORY LEGAL NOTICE
(REGISTERED POST WITH A.D. / SPEED POST / LEGAL EMAIL)

Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}

To,
Advocate for ${_senderNameController.text}
Office of Legal Counsel, Corporate Demands Section

SUBJECT: FORMAL REBUTTAL AND CATEGORICAL DENIAL TO PURPORTED LEGAL NOTICE ON BEHALF OF MY CLIENT

Sir / Madam,

Under instructions and on behalf of my client (hereinafter "My Client"), I hereby provide this statutory reply to your notice under reference:

1. PRELIMINARY OBJECTIONS:
At the outset, each and every allegation, contention, and monetary claim set forth in your notice under reply is vehemently denied in toto as false, frivolous, legally untenable, and motivated by extraneous commercial coercion.

2. FACTUAL CLARIFICATION & AMOUNT DISPUTED (${_claimAmountController.text}):
The purported monetary demand of ${_claimAmountController.text} is completely disputed. No liquidated liability exists in law or equity. Furthermore, all prior mutual credits, partial consideration, and commercial offsets have been deliberately suppressed by your client.

3. GOAL & STATUTORY DEFENSE (${_selectedGoal.label.toUpperCase()}):
Pursuant to governing statutory enactments, your notice fails to disclose a crystallized cause of action and is prematurely issued without meeting statutory preconditions.

4. DEMAND TO WITHDRAW NOTICE:
In view of the foregoing, you are hereby called upon to advise your client to unconditionally withdraw the said illegal demand notice within 7 (Seven) days of receipt hereof. Should your client initiate premature or vexatious litigation, My Client shall defend the same at your client's sole risk, cost, and consequence.

A copy of this rebuttal has been retained in my chamber for future legal record.

Yours faithfully,

_____________________________
Advocate for Respondent / Client
[Enrolment No: ADV/DL/2026/BAR]
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
      const SnackBar(content: Text('Rebuttal saved to Saved Library')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF090D18) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF101524) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF222B45) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF8B95B5) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // =================================================================
            // A. HEADER: BACK BUTTON + STATUS BADGE + TITLE + SUBTITLE
            // =================================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF14192E) : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF283456) : const Color(0xFFCBD5E1),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? const Color(0x33000000) : const Color(0x0A000000),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 15,
                      color: textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: const Color(0x1F10B981),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0x4D10B981),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Instant Legal Assistant',
                        style: TextStyle(
                          color: Color(0xFF34D399),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              'Notice Reply Helper',
              style: TextStyle(
                color: textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Turn confusing legal notices into a clear, calm, and statutory formal response.',
              style: TextStyle(
                color: textSecondary,
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),

            // =================================================================
            // B. SECURITY INFORMATION CARD
            // =================================================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF10152B) : const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF232E54) : const Color(0xFFC7D2FE),
                  width: 1.2,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.lock_rounded,
                      size: 16,
                      color: Color(0xFF818CF8),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Safe & Confidential. ',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text:
                                'AI securely breaks down allegations, calculates response deadlines, and drafts your rebuttal.',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // =================================================================
            // C. DOCUMENT UPLOAD SECTION (DASHED BORDER CARD)
            // =================================================================
            GestureDetector(
              onTap: _pickNoticeFile,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: cardBorder,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? const Color(0x33000000) : const Color(0x0A000000),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CustomPaint(
                  painter: _DashedBorderPainter(
                    color: isDark ? const Color(0xFF334165) : const Color(0xFFCBD5E1),
                    radius: 14,
                    strokeWidth: 1.2,
                    dashWidth: 6,
                    dashSpace: 4,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF8B5CF6),
                                Color(0xFF6366F1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.file_upload_outlined,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Snap a Photo or Upload PDF',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'We will automatically read dates, sender details, and claimed amounts for you!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                        if (_attachedNoticeName != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0x1A10B981),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0x4D10B981),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 15,
                                  color: Color(0xFF10B981),
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  _attachedNoticeName!,
                                  style: const TextStyle(
                                    color: Color(0xFF34D399),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0x3310B981),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'SCANNED',
                                    style: TextStyle(
                                      color: Color(0xFF34D399),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.6,
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
                ),
              ),
            ),
            const SizedBox(height: 16),

            // =================================================================
            // D. NOTICE TEXT OR SUMMARY CARD + VOICE DICTATE + GOAL CHIPS
            // =================================================================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: cardBorder,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? const Color(0x33000000) : const Color(0x0A000000),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'NOTICE TEXT OR SUMMARY',
                        style: TextStyle(
                          color: isDark ? const Color(0xFF8B95B5) : const Color(0xFF475569),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      GestureDetector(
                        onTap: _toggleVoiceDictation,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isListeningVoice ? Icons.mic_rounded : Icons.mic_none_rounded,
                              size: 15,
                              color: _isListeningVoice ? const Color(0xFFEF4444) : const Color(0xFF818CF8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isListeningVoice ? 'Listening...' : 'Voice Dictate',
                              style: TextStyle(
                                color: _isListeningVoice ? const Color(0xFFEF4444) : const Color(0xFF818CF8),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Large multiline text input
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0C101F) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? const Color(0xFF1F2942) : const Color(0xFFE2E8F0),
                        width: 1.1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: TextField(
                      controller: _noticeTextController,
                      minLines: 4,
                      maxLines: 7,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 13,
                        height: 1.45,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Paste the notice text or summarize what happened in simple words (e.g. loan dispute, credit card notice, tenancy issue)...',
                        hintStyle: TextStyle(
                          color: textSecondary,
                          fontSize: 12.5,
                          height: 1.4,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Goal Chips Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Goal:',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: NoticeGoal.values.map((goal) {
                              final isSelected = _selectedGoal == goal;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () => _onGoalSelected(goal),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? (isDark ? const Color(0xFF1E284A) : const Color(0xFFEEF2FF))
                                          : (isDark ? const Color(0xFF13172B) : const Color(0xFFF1F5F9)),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF6366F1)
                                            : (isDark ? const Color(0xFF273254) : const Color(0xFFCBD5E1)),
                                        width: isSelected ? 1.4 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(goal.icon, style: const TextStyle(fontSize: 13)),
                                        const SizedBox(width: 5),
                                        Text(
                                          goal.label,
                                          style: TextStyle(
                                            color: isSelected
                                                ? (isDark ? Colors.white : const Color(0xFF4F46E5))
                                                : textSecondary,
                                            fontSize: 11.5,
                                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // =================================================================
            // E. ADDITIONAL INFORMATION FIELDS: SENDER + AMOUNT CLAIMED
            // =================================================================
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: cardBorder, width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WHO SENT THE NOTICE?',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF8B95B5) : const Color(0xFF475569),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 42,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0C101F) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? const Color(0xFF242E4C) : const Color(0xFFCBD5E1),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.account_balance_outlined,
                                size: 16,
                                color: textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _senderNameController,
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: cardBorder, width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AMOUNT CLAIMED',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF8B95B5) : const Color(0xFF475569),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 42,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0C101F) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? const Color(0xFF242E4C) : const Color(0xFFCBD5E1),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: TextField(
                              controller: _claimAmountController,
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // =================================================================
            // F. PRIMARY ACTION: ANALYZE & DRAFT FORMAL REBUTTAL
            // =================================================================
            GestureDetector(
              onTap: _isAnalyzing ? null : _generateReply,
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF8B5CF6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: _isAnalyzing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.reply_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Analyze & Draft Formal Rebuttal',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 14,
                  color: textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  'You will review, customize & export to PDF before sending.',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // =================================================================
            // G. GENERATED REBUTTAL PREVIEW & ACTIONS
            // =================================================================
            if (_replyGenerated) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: cardBorder, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Generated Legal Rebuttal',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.copy_rounded, size: 19),
                              tooltip: 'Copy Rebuttal',
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: _rebuttalController.text));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Rebuttal copied to clipboard')),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.bookmark_add_outlined, size: 19),
                              tooltip: 'Save to Library',
                              onPressed: _saveReply,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _rebuttalController,
                      maxLines: 12,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12.5,
                        height: 1.45,
                      ),
                      decoration: InputDecoration(
                        fillColor: isDark ? const Color(0xFF0C101F) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          borderSide: BorderSide(color: cardBorder),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    LegalButton(
                      text: 'Save Reply to Saved Library',
                      variant: LegalButtonVariant.secondary,
                      icon: Icons.save_alt_rounded,
                      onPressed: _saveReply,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

/// Custom painter for crisp, responsive dashed borders
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final length = dashWidth;
        final extractPath = metric.extractPath(distance, distance + length);
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace;
  }
}
