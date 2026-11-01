import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/legal_button.dart';
import '../../../../core/widgets/legal_card.dart';
import '../../../../core/widgets/legal_empty_state.dart';
import '../../../../core/widgets/legal_loading_indicator.dart';
import '../../../../core/widgets/legal_text_field.dart';
import '../../data/saved_repository.dart';
import '../../models/saved_item.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  IconData _iconForType(SavedItemType type) {
    switch (type) {
      case SavedItemType.document:
        return Icons.description_outlined;
      case SavedItemType.draft:
        return Icons.edit_note_rounded;
      case SavedItemType.research:
        return Icons.travel_explore_rounded;
      case SavedItemType.conversation:
        return Icons.chat_bubble_outline_rounded;
    }
  }

  Color _colorForType(SavedItemType type) {
    switch (type) {
      case SavedItemType.document:
        return AppColors.accentCyan;
      case SavedItemType.draft:
        return AppColors.accentVioletLight;
      case SavedItemType.research:
        return AppColors.accentPurple;
      case SavedItemType.conversation:
        return AppColors.success;
    }
  }

  String _labelForType(SavedItemType type, [bool isHindi = false]) {
    switch (type) {
      case SavedItemType.document:
        return isHindi ? 'दस्तावेज़' : 'Document';
      case SavedItemType.draft:
        return isHindi ? 'प्रारूप' : 'Draft';
      case SavedItemType.research:
        return isHindi ? 'शोध' : 'Research';
      case SavedItemType.conversation:
        return isHindi ? 'एआई बातचीत' : 'AI Chat';
    }
  }

  void _showItemDetail(BuildContext context, SavedItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.legalTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) {
          return Padding(
            padding: AppSpacing.paddingScreen,
            child: ListView(
              controller: scrollController,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.legalTheme.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                AppSpacing.verticalSpaceMd,
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _colorForType(item.type).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Text(
                        _labelForType(item.type).toUpperCase(),
                        style: AppTypography.labelSmall.copyWith(
                          color: _colorForType(item.type),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormatter.formatReadable(item.createdAt),
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
                AppSpacing.verticalSpaceSm,
                Text(
                  item.title,
                  style: AppTypography.titleLarge.copyWith(
                    color: context.colors.onSurface,
                  ),
                ),
                AppSpacing.verticalSpaceXs,
                Text(
                  item.subtitle,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                AppSpacing.verticalSpaceLg,
                const Divider(),
                AppSpacing.verticalSpaceMd,
                SelectableText(
                  item.content,
                  style: AppTypography.bodyMedium.copyWith(
                    height: 1.6,
                    color: context.colors.onSurface,
                  ),
                ),
                AppSpacing.verticalSpaceXl,
                LegalButton(
                  text: 'Copy Content',
                  icon: Icons.copy_rounded,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: item.content));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Content copied to clipboard')),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(savedControllerProvider);
    final controller = ref.read(savedControllerProvider.notifier);
    final isHindi = ref.isHindi;

    return Scaffold(
      appBar: AppBar(
        title: Text(isHindi ? 'सहेजी गई लाइब्रेरी' : 'Saved Library'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            child: LegalTextField(
              hintText: isHindi
                  ? 'सहेजे गए प्रारूप, दस्तावेज़ एवं शोध खोजें...'
                  : 'Search saved drafts, documents & research...',
              prefixIcon: const Icon(Icons.search, size: 20),
              onChanged: controller.setSearchQuery,
            ),
          ),
          AppSpacing.verticalSpaceSm,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                FilterChip(
                  label: Text(isHindi ? 'सभी आइटम' : 'All Items'),
                  selected: state.selectedTypeFilter == null,
                  onSelected: (_) => controller.setFilter(null),
                  selectedColor: AppColors.accentViolet.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.accentVioletLight,
                ),
                AppSpacing.horizontalSpaceXs,
                ...SavedItemType.values.map(
                  (type) => Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: FilterChip(
                      label: Text(_labelForType(type, isHindi)),
                      selected: state.selectedTypeFilter == type,
                      onSelected: (_) => controller.setFilter(type),
                      selectedColor: _colorForType(type).withValues(alpha: 0.2),
                      checkmarkColor: _colorForType(type),
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.verticalSpaceSm,
          Expanded(
            child: state.isLoading
                ? LegalLoadingIndicator(
                    message: isHindi ? 'सहेजी गई सामग्री लोड हो रही है...' : 'Loading saved items...',
                  )
                : state.items.isEmpty
                    ? LegalEmptyState(
                        title: isHindi ? 'अभी कोई सामग्री सहेजी नहीं गई है' : 'No Saved Content Yet',
                        message: isHindi
                            ? 'सहेजे गए कानूनी दस्तावेज़, एआई विश्लेषण, शोध और प्रारूप यहां दिखाई देंगे।'
                            : 'Saved legal documents, AI analyses, research citations, and drafts will appear here.',
                        icon: Icons.bookmark_border_rounded,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: state.items.length,
                        separatorBuilder: (_, __) => AppSpacing.verticalSpaceMd,
                        itemBuilder: (context, index) {
                          final item = state.items[index];
                          return Dismissible(
                            key: ValueKey(item.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: AppSpacing.lg),
                              color: AppColors.danger,
                              child: const Icon(Icons.delete_outline, color: Colors.white),
                            ),
                            onDismissed: (_) {
                              controller.delete(item.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Removed "${item.title}"'),
                                ),
                              );
                            },
                            child: LegalCard(
                              onTap: () => _showItemDetail(context, item),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: _colorForType(item.type).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                    ),
                                    child: Icon(
                                      _iconForType(item.type),
                                      color: _colorForType(item.type),
                                      size: 22,
                                    ),
                                  ),
                                  AppSpacing.horizontalSpaceMd,
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item.title,
                                                style: AppTypography.titleSmall.copyWith(
                                                  color: context.colors.onSurface,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            AppSpacing.horizontalSpaceXs,
                                            Text(
                                              DateFormatter.formatRelative(item.createdAt),
                                              style: AppTypography.bodySmall.copyWith(
                                                color: context.colors.onSurface.withValues(alpha: 0.5),
                                              ),
                                            ),
                                          ],
                                        ),
                                        AppSpacing.verticalSpaceXxs,
                                        Text(
                                          item.subtitle,
                                          style: AppTypography.bodySmall.copyWith(
                                            color: context.colors.onSurface.withValues(alpha: 0.7),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

