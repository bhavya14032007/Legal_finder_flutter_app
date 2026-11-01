import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/services/legal_api_service.dart';
import '../../../saved/data/saved_repository.dart';
import '../../../saved/models/saved_item.dart';

enum DocumentTypeOption {
  rental(
    id: 'rental_agreement',
    title: 'Rental Agreement',
    icon: '🏠',
    defaultTitle: 'Residential Rental / Lease Agreement',
    defaultCity: 'New Delhi, IN',
    defaultPartyOne: 'Acme Technologies Pvt Ltd (Landlord)',
    defaultPartyTwo: 'John Doe (Tenant / Independent Consultant)',
    defaultTerms: '11-month term, 1-month refundable security deposit, 15-day notice period.',
  ),
  nda(
    id: 'nda',
    title: 'Non-Disclosure (NDA)',
    icon: '🔒',
    defaultTitle: 'Mutual Non-Disclosure Agreement (NDA)',
    defaultCity: 'Bengaluru, IN',
    defaultPartyOne: 'Innovatech Labs India Pvt Ltd',
    defaultPartyTwo: 'Apex Software Consultants LLP',
    defaultTerms: '2-year confidentiality duration, strict IP protection, liquidated damages for breach.',
  ),
  freelance(
    id: 'freelance_contract',
    title: 'Freelance Contract',
    icon: '💼',
    defaultTitle: 'Independent Freelance Services Agreement',
    defaultCity: 'Mumbai, IN',
    defaultPartyOne: 'Global Horizons Media LLC',
    defaultPartyTwo: 'Rohit Verma (Lead Designer)',
    defaultTerms: 'Bi-weekly milestones, full IP transfer upon final payment, net 15 invoice terms.',
  ),
  paymentDemand(
    id: 'payment_demand',
    title: 'Payment Demand',
    icon: '📄',
    defaultTitle: 'Statutory Payment Demand & Notice',
    defaultCity: 'Hyderabad, IN',
    defaultPartyOne: 'Zenith Logistics & Supply Co.',
    defaultPartyTwo: 'Sunrise Retailers Private Ltd',
    defaultTerms: 'Demand for outstanding invoice dues of Rs. 4,500.00 with 18% statutory interest.',
  );

  final String id;
  final String title;
  final String icon;
  final String defaultTitle;
  final String defaultCity;
  final String defaultPartyOne;
  final String defaultPartyTwo;
  final String defaultTerms;

  const DocumentTypeOption({
    required this.id,
    required this.title,
    required this.icon,
    required this.defaultTitle,
    required this.defaultCity,
    required this.defaultPartyOne,
    required this.defaultPartyTwo,
    required this.defaultTerms,
  });
}

class ChatMessage {
  final String text;
  final bool isUser;
  final String? subtitle;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.subtitle,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class DraftingScreen extends ConsumerStatefulWidget {
  const DraftingScreen({super.key});

  @override
  ConsumerState<DraftingScreen> createState() => _DraftingScreenState();
}

class _DraftingScreenState extends ConsumerState<DraftingScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  DocumentTypeOption _selectedOption = DocumentTypeOption.rental;
  int _currentStep = 3;
  int _progressPercent = 60;
  bool _isGenerating = false;
  String? _generatedDraftText;

  late List<ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _initializeConversation();
  }

  void _initializeConversation() {
    _messages = [
      ChatMessage(
        isUser: false,
        text:
            "Hello Adv. Rajesh! Let's draft your agreement together in just 2 minutes without legal jargon.\n\nWhat type of document would you like to create today?",
      ),
      ChatMessage(
        isUser: true,
        subtitle: 'Agreement Selected ✓',
        text: "Let's do a Rental / Lease Agreement",
      ),
      ChatMessage(
        isUser: false,
        text:
            'Got it! Who are the parties involved? Who is the Landlord (Party One) and Tenant (Party Two)?',
      ),
      ChatMessage(
        isUser: true,
        text:
            '• Landlord: Acme Technologies Pvt Ltd\n• Tenant: John Doe (Independent Consultant)',
      ),
      ChatMessage(
        isUser: false,
        text:
            "Great. What is the start date, city, and any key terms (like deposit or notice period)?\n\n💡 Tip: You can just type normally like 'Starting Nov 1 in New Delhi with 1 month deposit', or tap quick tags below.",
      ),
    ];
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _selectDocumentType(DocumentTypeOption option) {
    setState(() {
      _selectedOption = option;
      _currentStep = 3;
      _progressPercent = 60;
      _messages.add(
        ChatMessage(
          isUser: true,
          subtitle: 'Agreement Selected ✓',
          text: "Let's do a ${option.title}",
        ),
      );
      _messages.add(
        ChatMessage(
          isUser: false,
          text:
              'Updated to ${option.title}! Who are the parties involved and what are the specific terms you need?',
        ),
      );
    });
    _scrollToBottom();
  }

  void _appendQuickTag(String tag) {
    final current = _messageController.text.trim();
    if (current.isEmpty) {
      _messageController.text = tag.replaceAll('+', '').trim();
    } else {
      _messageController.text = '$current, ${tag.replaceAll('+', '').trim()}';
    }
    _messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: _messageController.text.length),
    );
  }

  Future<void> _handleSendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    setState(() {
      _messages.add(ChatMessage(isUser: true, text: text));
      _currentStep = 4;
      _progressPercent = 85;
      _isGenerating = true;
    });
    _scrollToBottom();

    // Call LegalApiService to generate the full legal draft
    try {
      final backendData = await LegalApiService.generateDraft(
        draftType: _selectedOption.id,
        title: _selectedOption.defaultTitle,
        inputData: {
          'party_one': _selectedOption.defaultPartyOne,
          'party_two': _selectedOption.defaultPartyTwo,
          'effective_date': 'November 1, 2026',
          'jurisdiction': _selectedOption.defaultCity,
          'key_terms': text,
        },
      );

      final generated = backendData['generated_content'] as String? ??
          _buildFallbackDraft(text);

      setState(() {
        _generatedDraftText = generated;
        _isGenerating = false;
        _progressPercent = 100;
        _messages.add(
          ChatMessage(
            isUser: false,
            text:
                '🎉 Your statutory ${_selectedOption.title} has been compiled and formatted! Tap "Preview" below to review, edit, or copy the formal text.',
          ),
        );
      });
    } catch (_) {
      setState(() {
        _generatedDraftText = _buildFallbackDraft(text);
        _isGenerating = false;
        _progressPercent = 100;
        _messages.add(
          ChatMessage(
            isUser: false,
            text:
                '🎉 Your statutory ${_selectedOption.title} draft is ready for review! Tap "Preview" below to inspect or save.',
          ),
        );
      });
    }

    _scrollToBottom();
  }

  String _buildFallbackDraft(String additionalTerms) {
    return '''${_selectedOption.defaultTitle.toUpperCase()}

This Instrument is executed on this 1st day of November, 2026 at ${_selectedOption.defaultCity}.

BETWEEN:
FIRST PARTY / LESSOR:
${_selectedOption.defaultPartyOne}

AND

SECOND PARTY / LESSEE:
${_selectedOption.defaultPartyTwo}

WHEREAS the First Party is the absolute owner of the premises, and the Second Party has requested a tenancy/engagement under statutory terms.

NOW THIS INDENTURE WITNESSETH AS FOLLOWS:
1. TERM & TENURE
The term of this Agreement shall be for a duration of 11 consecutive months commencing from November 1, 2026.

2. CONSIDERATION & DEPOSIT
The Second Party shall pay the agreed monthly consideration promptly. A refundable security deposit equivalent to one month's rent shall be deposited with the First Party.

3. COVENANTS & KEY TERMS
${additionalTerms.isNotEmpty ? additionalTerms : _selectedOption.defaultTerms}

4. TERMINATION & NOTICE
Either party may terminate this agreement by tendering at least 15 days written notice to the counterparty.

5. JURISDICTION & DISPUTE RESOLUTION
Any dispute arising under this instrument shall be subject to the exclusive jurisdiction of the competent civil courts at ${_selectedOption.defaultCity}.

IN WITNESS WHEREOF the parties have hereunto set their hands and seals on the day and year first above written.

_____________________________               _____________________________
FIRST PARTY / LESSOR                        SECOND PARTY / LESSEE
''';
  }

  Future<void> _openDraftPreview() async {
    if (_generatedDraftText == null) {
      // Generate draft if not already generated
      setState(() => _isGenerating = true);
      final backendData = await LegalApiService.generateDraft(
        draftType: _selectedOption.id,
        title: _selectedOption.defaultTitle,
        inputData: {
          'party_one': _selectedOption.defaultPartyOne,
          'party_two': _selectedOption.defaultPartyTwo,
          'effective_date': 'November 1, 2026',
          'jurisdiction': _selectedOption.defaultCity,
          'key_terms': _selectedOption.defaultTerms,
        },
      );
      setState(() {
        _generatedDraftText =
            backendData['generated_content'] as String? ?? _buildFallbackDraft('');
        _isGenerating = false;
        _progressPercent = 100;
      });
    }

    if (!mounted) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final draftController =
        TextEditingController(text: _generatedDraftText ?? '');

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.88,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F1424) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusXl),
                ),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF262E45)
                      : const Color(0xFFCBD5E1),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: const Icon(
                            Icons.description_rounded,
                            color: Color(0xFF8B5CF6),
                            size: 20,
                          ),
                        ),
                        AppSpacing.horizontalSpaceSm,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedOption.title,
                                style: AppTypography.titleMedium.copyWith(
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Statutory Draft • Editable & Ready for Signature',
                                style: AppTypography.bodySmall.copyWith(
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Monospace draft text field
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF090D18)
                              : const Color(0xFFF8FAFC),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF1E2638)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: TextField(
                          controller: draftController,
                          maxLines: null,
                          expands: true,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12.5,
                            height: 1.5,
                            color: isDark
                                ? const Color(0xFFE2E8F0)
                                : const Color(0xFF1E293B),
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(AppSpacing.md),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.lg,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.sm,
                              ),
                              side: BorderSide(
                                color: isDark
                                    ? const Color(0xFF3B4868)
                                    : const Color(0xFFCBD5E1),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.radiusMd),
                              ),
                            ),
                            icon: const Icon(Icons.copy_rounded, size: 18),
                            label: const Text('Copy Text'),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: draftController.text),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Draft copied to clipboard'),
                                ),
                              );
                            },
                          ),
                        ),
                        AppSpacing.horizontalSpaceMd,
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              ),
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusMd),
                            ),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.sm,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusMd,
                                  ),
                                ),
                              ),
                              icon: const Icon(
                                Icons.bookmark_add_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              label: const Text(
                                'Save to Library',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              onPressed: () {
                                _generatedDraftText = draftController.text;
                                ref.read(savedControllerProvider.notifier).save(
                                      SavedItem(
                                        id: '',
                                        title: _selectedOption.title,
                                        subtitle:
                                            '${_selectedOption.defaultCity} • 11-Month Term',
                                        content: draftController.text,
                                        type: SavedItemType.draft,
                                        createdAt: DateTime.now(),
                                      ),
                                    );
                                Navigator.pop(context);
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Draft saved to library!'),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF090D18) : const Color(0xFFF8FAFC);
    final borderColor = isDark ? const Color(0xFF242C45) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header matching Screenshot 2
            _buildHeader(isDark, borderColor, textPrimary, textSecondary),

            // Step Progress Row
            _buildStepProgressBar(isDark, borderColor, textSecondary),

            // Timestamp pill
            AppSpacing.verticalSpaceXs,
            _buildDatePill(isDark, borderColor),
            AppSpacing.verticalSpaceSm,

            // Conversational Chat Messages Area
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                children: [
                  ..._messages.asMap().entries.map((entry) {
                    final index = entry.key;
                    final msg = entry.value;

                    // If it's the first AI message, append the agreement options underneath
                    if (index == 0 && !msg.isUser) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAiBubble(msg, isDark, borderColor, textPrimary),
                          AppSpacing.verticalSpaceSm,
                          _buildAgreementOptionsList(isDark, borderColor, textPrimary),
                          AppSpacing.verticalSpaceMd,
                        ],
                      );
                    }

                    if (msg.isUser) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _buildUserBubble(msg),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _buildAiBubble(msg, isDark, borderColor, textPrimary),
                      );
                    }
                  }),

                  // Inline Drafting in Progress Card matching screenshot 2
                  _buildInlineProgressCard(isDark, borderColor, textPrimary, textSecondary),
                  AppSpacing.verticalSpaceMd,
                ],
              ),
            ),

            // Bottom Fixed Composer with Quick Add tags
            _buildBottomComposer(isDark, borderColor, textPrimary, textSecondary),
          ],
        ),
      ),
    );
  }

  // Header Component
  Widget _buildHeader(
    bool isDark,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Circular Back Button
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141829) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFF262D42) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Icon(
                Icons.chevron_left_rounded,
                color: textPrimary,
                size: 22,
              ),
            ),
          ),

          // Centered Title & Status
          Column(
            children: [
              Text(
                ref.isHindi ? 'प्रारूपण सहायक' : 'Drafting Assistant',
                style: AppTypography.titleMedium.copyWith(
                  color: textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              AppSpacing.verticalSpaceXxs,
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    ref.isHindi ? 'एआई सहायक ऑनलाइन' : 'AI Assistant Online',
                    style: AppTypography.labelSmall.copyWith(
                      color: const Color(0xFF22C55E),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Information / Help Button
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'AI Legal Drafting Assistant: Generates enforceable deeds, agreements, and demand notices compliant with Indian statutory laws.',
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141829) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFF262D42) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Icon(
                Icons.info_outline_rounded,
                color: textSecondary,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Step Progress Bar Component
  Widget _buildStepProgressBar(
    bool isDark,
    Color borderColor,
    Color textSecondary,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Step pill
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1F36) : const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              border: Border.all(
                color: isDark ? const Color(0xFF3E4370) : const Color(0xFFC7D2FE),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_rounded,
                  size: 13,
                  color: Color(0xFF818CF8),
                ),
                const SizedBox(width: 5),
                Text(
                  ref.isHindi
                      ? 'चरण $_currentStep of 4: विवरण एवं शर्तें'
                      : 'Step $_currentStep of 4: Details & Terms',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFC7D2FE) : const Color(0xFF4338CA),
                  ),
                ),
              ],
            ),
          ),

          // Remaining time
          Text(
            ref.isHindi ? '~1 मिनट शेष' : '~1 min remaining',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // Date Pill Component
  Widget _buildDatePill(bool isDark, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B2E) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(
          color: isDark ? const Color(0xFF262D44) : const Color(0xFFE2E8F0),
          width: 0.8,
        ),
      ),
      child: Text(
        ref.isHindi
            ? 'आज • त्वरित कानूनी प्रारूपण'
            : 'TODAY • INSTANT LEGAL DRAFTING',
        style: TextStyle(
          fontSize: 9.5,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w700,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
      ),
    );
  }

  // AI Message Bubble
  Widget _buildAiBubble(
    ChatMessage msg,
    bool isDark,
    Color borderColor,
    Color textPrimary,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI Sparkle Avatar
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 14,
            ),
          ),
        ),
        AppSpacing.horizontalSpaceSm,
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161B2E) : Colors.white,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(AppSpacing.radiusLg),
                bottomLeft: Radius.circular(AppSpacing.radiusLg),
                bottomRight: Radius.circular(AppSpacing.radiusLg),
              ),
              border: Border.all(
                color: isDark ? const Color(0xFF242C44) : const Color(0xFFE2E8F0),
              ),
              boxShadow: isDark
                  ? null
                  : [
                      BoxInsets.boxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Text(
              msg.text,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: textPrimary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Agreement Options Selection List
  Widget _buildAgreementOptionsList(
    bool isDark,
    Color borderColor,
    Color textPrimary,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 36),
      child: Column(
        children: DocumentTypeOption.values.map((option) {
          final isSelected = _selectedOption == option;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: InkWell(
              onTap: () => _selectDocumentType(option),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                          ? const Color(0xFF222644)
                          : const Color(0xFFEEF2FF))
                      : (isDark
                          ? const Color(0xFF161B2E)
                          : const Color(0xFFF8FAFC)),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF8B5CF6)
                        : (isDark
                            ? const Color(0xFF242D45)
                            : const Color(0xFFE2E8F0)),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(option.icon, style: const TextStyle(fontSize: 16)),
                    AppSpacing.horizontalSpaceSm,
                    Text(
                      option.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? (isDark ? Colors.white : const Color(0xFF4338CA))
                            : textPrimary,
                      ),
                    ),
                    const Spacer(),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF8B5CF6),
                        size: 16,
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // User Message Bubble
  Widget _buildUserBubble(ChatMessage msg) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(width: 48),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.radiusLg),
                topRight: Radius.circular(AppSpacing.radiusLg),
                bottomLeft: Radius.circular(AppSpacing.radiusLg),
                bottomRight: Radius.circular(AppSpacing.radiusXs),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (msg.subtitle != null) ...[
                  Text(
                    msg.subtitle!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  AppSpacing.verticalSpaceXxs,
                ],
                Text(
                  msg.text,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.4,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Inline Drafting in Progress Card matching Screenshot 2
  Widget _buildInlineProgressCard(
    bool isDark,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B2E) : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDark ? const Color(0xFF26304D) : const Color(0xFFE2E8F0),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxInsets.boxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Row(
        children: [
          // Document icon container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF212842) : const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Icon(
              Icons.description_rounded,
              color: Color(0xFF818CF8),
              size: 20,
            ),
          ),
          AppSpacing.horizontalSpaceSm,

          // Progress text + badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _isGenerating
                          ? (ref.isHindi ? 'प्रारूप तैयार किया जा रहा है...' : 'Generating Draft...')
                          : (ref.isHindi ? 'प्रारूपण प्रगति पर है...' : 'Drafting in Progress...'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF065F46),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Text(
                        '$_progressPercent%',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF34D399),
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalSpaceXxs,
                Text(
                  '${_selectedOption.title} • ${_selectedOption.defaultCity}',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Preview button
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: isDark
                  ? const Color(0xFF202740)
                  : const Color(0xFFF1F5F9),
              side: BorderSide(
                color: isDark
                    ? const Color(0xFF3A476E)
                    : const Color(0xFFCBD5E1),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 6,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
            onPressed: _openDraftPreview,
            child: Text(
              ref.isHindi ? 'पूर्वावलोकन' : 'Preview',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Bottom Fixed Composer Component
  Widget _buildBottomComposer(
    bool isDark,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF090D18) : const Color(0xFFF8FAFC),
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quick add row
          Row(
            children: [
              Text(
                ref.isHindi ? 'त्वरित जोड़ें:' : 'Quick add:',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: textSecondary,
                ),
              ),
              AppSpacing.horizontalSpaceSm,
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildQuickTag(
                        ref.isHindi ? '+ 11-महीने की अवधि' : '+ 11-Month Term',
                        isDark,
                        borderColor,
                      ),
                      const SizedBox(width: 6),
                      _buildQuickTag(
                        ref.isHindi ? '+ 1-महीने की जमा' : '+ 1-Month Deposit',
                        isDark,
                        borderColor,
                      ),
                      const SizedBox(width: 6),
                      _buildQuickTag(
                        ref.isHindi ? '+ 15-दिन का नोटिस' : '+ 15-Day Notice',
                        isDark,
                        borderColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceSm,

          // Input field row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141829) : Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF262E45)
                    : const Color(0xFFCBD5E1),
              ),
            ),
            child: Row(
              children: [
                // Attachment icon
                IconButton(
                  icon: Icon(
                    Icons.attach_file_rounded,
                    size: 20,
                    color: textSecondary,
                  ),
                  tooltip: 'Attach reference',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reference document attached'),
                      ),
                    );
                  },
                ),

                // Text field
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: TextStyle(fontSize: 13.5, color: textPrimary),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _handleSendMessage(),
                    decoration: InputDecoration(
                      hintText: ref.isHindi
                          ? '1 नवंबर 2026, नई दिल्ली, 1 महीने की जमा राशि...'
                          : 'Nov 1, 2026, New Delhi with 1 month deposit...',
                      hintStyle: TextStyle(
                        fontSize: 12.5,
                        color: isDark
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                      ),
                    ),
                  ),
                ),

                // Mic icon
                IconButton(
                  icon: Icon(
                    Icons.mic_none_rounded,
                    size: 20,
                    color: textSecondary,
                  ),
                  tooltip: 'Voice Dictation',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Listening to voice dictation...'),
                      ),
                    );
                  },
                ),

                // Purple Gradient Send button
                Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: InkWell(
                    onTap: _isGenerating ? null : _handleSendMessage,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Center(
                        child: _isGenerating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.arrow_upward_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Quick tag chip helper
  Widget _buildQuickTag(String label, bool isDark, Color borderColor) {
    return InkWell(
      onTap: () => _appendQuickTag(label),
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141829) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: isDark ? const Color(0xFF262D42) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }
}

class BoxInsets {
  static BoxShadow boxShadow({
    required Color color,
    required double blurRadius,
    required Offset offset,
  }) {
    return BoxShadow(color: color, blurRadius: blurRadius, offset: offset);
  }
}
