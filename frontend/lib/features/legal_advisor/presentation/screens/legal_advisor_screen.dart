import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/disclaimer_banner.dart';
import '../controllers/advisor_controller.dart';
import '../../models/chat_message.dart';

class LegalAdvisorScreen extends ConsumerStatefulWidget {
  const LegalAdvisorScreen({super.key});

  @override
  ConsumerState<LegalAdvisorScreen> createState() => _LegalAdvisorScreenState();
}

class _LegalAdvisorScreenState extends ConsumerState<LegalAdvisorScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  static const List<String> _promptSuggestions = [
    'How do I respond to a 15-day cheque bounce notice?',
    'What are my rights if my landlord refuses to return deposit?',
    'Can an employer enforce a 2-year non-compete clause?',
    'How do I file a deficiency claim under Consumer Protection Act?',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend([String? presetText]) async {
    final text = presetText ?? _textController.text;
    if (text.trim().isEmpty) return;

    _textController.clear();
    await ref.read(advisorControllerProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(advisorControllerProvider);
    final controller = ref.read(advisorControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI Legal Advisor'),
            Text(
              'Online • Statutory Reasoning Engine',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.success,
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined),
            tooltip: 'Save Conversation',
            onPressed: () async {
              await controller.saveCurrentConversation();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Consultation saved to Saved Library')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'New Conversation',
            onPressed: () {
              controller.startNewConversation();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const DisclaimerBanner(compact: true),

            // Messages List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                itemCount: state.messages.length,
                itemBuilder: (context, index) {
                  final msg = state.messages[index];
                  return _buildMessageBubble(msg);
                },
              ),
            ),

            // Thinking Indicator
            if (state.isThinking)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    AppSpacing.horizontalSpaceXs,
                    Text(
                      'AI Legal Advisor is analyzing legal statutes...',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.accentVioletLight,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

            // Quick Prompt Suggestions (if few messages)
            if (state.messages.length <= 2)
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: _promptSuggestions.length,
                  separatorBuilder: (_, __) => AppSpacing.horizontalSpaceXs,
                  itemBuilder: (context, index) {
                    final suggestion = _promptSuggestions[index];
                    return ActionChip(
                      label: Text(
                        suggestion,
                        style: AppTypography.labelSmall.copyWith(
                          color: context.colors.onSurface,
                        ),
                      ),
                      backgroundColor: context.legalTheme.elevatedSurface,
                      side: BorderSide(color: context.legalTheme.cardBorder),
                      onPressed: () => _handleSend(suggestion),
                    );
                  },
                ),
              ),

            AppSpacing.verticalSpaceXs,

            // Input Bar
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: context.legalTheme.cardBackground,
                border: Border(
                  top: BorderSide(
                    color: context.legalTheme.cardBorderSubtle,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      minLines: 1,
                      maxLines: 4,
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.colors.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Describe your legal question or notice...',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                          borderSide: BorderSide(color: context.legalTheme.cardBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                          borderSide: BorderSide(color: context.legalTheme.cardBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                          borderSide: const BorderSide(color: AppColors.accentViolet, width: 1.5),
                        ),
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                  AppSpacing.horizontalSpaceXs,
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.primaryButtonGradient,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: () => _handleSend(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.sender == MessageSender.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.primaryButtonGradient),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
            ),
            AppSpacing.horizontalSpaceXs,
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.accentViolet
                    : context.legalTheme.elevatedSurface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppSpacing.radiusLg),
                  topRight: const Radius.circular(AppSpacing.radiusLg),
                  bottomLeft: Radius.circular(isUser ? AppSpacing.radiusLg : 4),
                  bottomRight: Radius.circular(isUser ? 4 : AppSpacing.radiusLg),
                ),
                border: Border.all(
                  color: isUser
                      ? AppColors.accentIndigo
                      : context.legalTheme.cardBorder,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormattedMessage(msg.content, isUser, context),
                  if (msg.legalCitations != null && msg.legalCitations!.isNotEmpty) ...[
                    AppSpacing.verticalSpaceSm,
                    const Divider(height: 12),
                    Text(
                      'Statutory References:',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.accentCyan,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AppSpacing.verticalSpaceXxs,
                    ...msg.legalCitations!.map(
                      (citation) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(color: AppColors.accentCyan)),
                            Expanded(
                              child: Text(
                                citation,
                                style: AppTypography.bodySmall.copyWith(
                                  color: context.colors.onSurface.withValues(alpha: 0.85),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  AppSpacing.verticalSpaceXxs,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormatter.formatTime(msg.timestamp),
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 10,
                          color: isUser
                              ? Colors.white.withValues(alpha: 0.7)
                              : context.colors.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      if (!isUser) ...[
                        AppSpacing.horizontalSpaceXs,
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: msg.content));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Response copied to clipboard')),
                            );
                          },
                          child: Icon(
                            Icons.copy_rounded,
                            size: 13,
                            color: context.colors.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            AppSpacing.horizontalSpaceXs,
            CircleAvatar(
              radius: 16,
              backgroundColor: context.legalTheme.cardBorder,
              child: const Icon(Icons.person, size: 18, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFormattedMessage(String text, bool isUser, BuildContext context) {
    final baseStyle = AppTypography.bodyMedium.copyWith(
      color: isUser ? Colors.white : context.colors.onSurface,
      height: 1.45,
    );
    final boldStyle = baseStyle.copyWith(
      fontWeight: FontWeight.w700,
      color: isUser ? Colors.white : (context.colors.primary.withValues(alpha: 0.95)),
    );

    // Strip any leading hashtag markers if any exist
    final cleanText = text.replaceAll(RegExp(r'^\s*#{1,6}\s*', multiLine: true), '');

    // Split on **bold** segments
    final regex = RegExp(r'\*\*(.*?)\*\*');
    final matches = regex.allMatches(cleanText);

    if (matches.isEmpty) {
      return SelectableText(cleanText, style: baseStyle);
    }

    final spans = <TextSpan>[];
    int lastMatchEnd = 0;

    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: cleanText.substring(lastMatchEnd, match.start),
          style: baseStyle,
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: boldStyle,
      ));
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < cleanText.length) {
      spans.add(TextSpan(
        text: cleanText.substring(lastMatchEnd),
        style: baseStyle,
      ));
    }

    return SelectableText.rich(
      TextSpan(children: spans),
      style: baseStyle,
    );
  }
}
