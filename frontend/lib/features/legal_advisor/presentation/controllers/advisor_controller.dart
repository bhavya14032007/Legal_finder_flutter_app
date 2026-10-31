import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../features/saved/data/saved_repository.dart';
import '../../../../features/saved/models/saved_item.dart';
import '../../models/chat_message.dart';

class AdvisorState {
  final List<ChatMessage> messages;
  final bool isThinking;
  final String? errorMessage;
  final String conversationId;

  const AdvisorState({
    required this.messages,
    this.isThinking = false,
    this.errorMessage,
    required this.conversationId,
  });

  AdvisorState copyWith({
    List<ChatMessage>? messages,
    bool? isThinking,
    String? errorMessage,
    String? conversationId,
  }) {
    return AdvisorState(
      messages: messages ?? this.messages,
      isThinking: isThinking ?? this.isThinking,
      errorMessage: errorMessage,
      conversationId: conversationId ?? this.conversationId,
    );
  }
}

final advisorControllerProvider =
    StateNotifierProvider<AdvisorController, AdvisorState>((ref) {
  final savedRepo = ref.watch(savedRepositoryProvider);
  return AdvisorController(savedRepo);
});

class AdvisorController extends StateNotifier<AdvisorState> {
  final SavedRepository _savedRepo;

  AdvisorController(this._savedRepo)
      : super(
          AdvisorState(
            conversationId: const Uuid().v4(),
            messages: [
              ChatMessage(
                id: 'welcome-msg',
                sender: MessageSender.ai,
                timestamp: DateTime.now(),
                content:
                    'Hello. I am your AI Legal Advisor. I can explain statutory rights, evaluate contractual clauses, guide you through court notice deadlines, or help prepare strategy for legal representation.\n\nHow may I assist your legal inquiry today?',
                legalCitations: const [
                  'Constitution of India - Article 39A (Equal Justice & Free Legal Aid)',
                  'Code of Civil Procedure, 1908 - Order VIII Rule 1',
                ],
              ),
            ],
          ),
        );

  void startNewConversation() {
    state = AdvisorState(
      conversationId: const Uuid().v4(),
      messages: [
        ChatMessage(
          id: const Uuid().v4(),
          sender: MessageSender.ai,
          timestamp: DateTime.now(),
          content: 'Started a fresh consultation session. What legal situation or document would you like to review?',
        ),
      ],
    );
  }

  Future<void> sendMessage(String text) async {
    final query = text.trim();
    if (query.isEmpty) return;

    final userMsg = ChatMessage(
      id: const Uuid().v4(),
      sender: MessageSender.user,
      content: query,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isThinking: true,
      errorMessage: null,
    );

    // Simulate real AI legal reasoning based on user's query
    try {
      await Future.delayed(const Duration(milliseconds: 1000));
      final responseContent = _generateLegalResponse(query);
      final citations = _extractRelevantCitations(query);

      final aiMsg = ChatMessage(
        id: const Uuid().v4(),
        sender: MessageSender.ai,
        content: responseContent,
        timestamp: DateTime.now(),
        legalCitations: citations,
      );

      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isThinking: false,
      );
    } catch (e) {
      state = state.copyWith(
        isThinking: false,
        errorMessage: 'Unable to reach legal intelligence server: ${e.toString()}',
      );
    }
  }

  Future<void> saveCurrentConversation() async {
    final summary = state.messages
        .where((m) => m.sender == MessageSender.user)
        .map((m) => m.content)
        .take(1)
        .join();

    final title = summary.isNotEmpty
        ? (summary.length > 40 ? '${summary.substring(0, 40)}...' : summary)
        : 'AI Consultation';

    final fullContent = state.messages
        .map((m) => '${m.sender == MessageSender.user ? "USER" : "LEGAL ADVISOR"}:\n${m.content}\n')
        .join('\n---\n');

    await _savedRepo.saveItem(
      SavedItem(
        id: state.conversationId,
        title: 'Advisor: $title',
        subtitle: '${state.messages.length} messages exchanged',
        content: fullContent,
        type: SavedItemType.conversation,
        createdAt: DateTime.now(),
      ),
    );
  }

  String _generateLegalResponse(String query) {
    final q = query.toLowerCase();

    if (q.contains('rent') || q.contains('tenant') || q.contains('lease') || q.contains('evict')) {
      return 'Regarding tenancy and lease rights:\n\n'
          '1. **Notice Requirement**: Under the Transfer of Property Act (Section 106) and local Model Tenancy Acts, an eviction notice usually requires 15 to 30 days mandatory written notice unless contractual breach provides otherwise.\n'
          '2. **Security Deposit**: Unreasonable withholding of security deposit can be contested in Small Causes Court or the Rent Authority.\n'
          '3. **Immediate Actions**: Ensure all rent receipts and the registered/notarized lease agreement are securely preserved.\n\n'
          'Recommendation: Review the lock-in clause and dispute resolution forum specified in your rental deed.';
    }

    if (q.contains('cheque') || q.contains('bounce') || q.contains('138') || q.contains('dishonour')) {
      return 'Regarding Negotiable Instruments & Cheque Dishonour:\n\n'
          '1. **Statutory Time Limit (Section 138 NI Act)**: Notice of dishonour must be served within 30 days of receiving the cheque return memo from the bank.\n'
          '2. **Cure Period**: The drawer is given 15 days from notice receipt to pay the dues.\n'
          '3. **Filing Complaint**: If unpaid within 15 days, a criminal complaint under Sec 138 must be instituted in the Metropolitan Magistrate Court within 1 month thereafter.';
    }

    if (q.contains('refund') || q.contains('consumer') || q.contains('defect') || q.contains('scam')) {
      return 'Under the Consumer Protection Act, 2019:\n\n'
          '1. **Deficiency in Service**: Consumers are entitled to seek full refund, interest, and compensation for mental agony from district consumer commissions.\n'
          '2. **E-Daakhil Portal**: Complaints can be filed online digitally without mandatory physical advocate appearance for claims up to ₹50 Lakhs.\n'
          '3. **Evidence Requirement**: Preserve transaction invoices, transaction IDs, correspondence emails, and warranty cards.';
    }

    return 'Based on your legal inquiry:\n\n'
        '1. **Legal Categorization**: This matter involves actionable civil and statutory rights under governing law.\n'
        '2. **Procedural Pre-requisites**: It is advisable to issue a formal Legal Notice before initiating formal judicial or arbitral proceedings.\n'
        '3. **Documentation**: Collect all primary contracts, dated communications, bank transaction proofs, and relevant timestamps.\n\n'
        'Would you like me to draft a preliminary legal notice, or summarize the exact questions you should present to licensed counsel?';
  }

  List<String> _extractRelevantCitations(String query) {
    final q = query.toLowerCase();
    if (q.contains('rent') || q.contains('lease')) {
      return [
        'Transfer of Property Act, 1882 - Section 106',
        'Model Tenancy Act - Section 21',
      ];
    }
    if (q.contains('cheque') || q.contains('bounce')) {
      return [
        'Negotiable Instruments Act, 1881 - Section 138 & 142',
        'Supreme Court in Dashrath Rupsingh Rathod v. State of Maharashtra (2014)',
      ];
    }
    return [
      'Code of Civil Procedure, 1908',
      'Indian Contract Act, 1872 - Section 73 (Compensation for Breach)',
    ];
  }
}
