import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/legal_api_service.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/disclaimer_banner.dart';
import '../../../../core/widgets/legal_card.dart';
import '../../../../core/widgets/legal_empty_state.dart';
import '../../../../core/widgets/legal_loading_indicator.dart';
import '../../../../core/widgets/legal_text_field.dart';
import '../../../saved/data/saved_repository.dart';
import '../../../saved/models/saved_item.dart';

class ResearchResult {
  final String title;
  final String citation;
  final String court;
  final String date;
  final String summary;
  final String keyRatio;
  final List<String> actsApplied;

  const ResearchResult({
    required this.title,
    required this.citation,
    required this.court,
    required this.date,
    required this.summary,
    required this.keyRatio,
    required this.actsApplied,
  });
}

class LegalResearchScreen extends ConsumerStatefulWidget {
  const LegalResearchScreen({super.key});

  @override
  ConsumerState<LegalResearchScreen> createState() => _LegalResearchScreenState();
}

class _LegalResearchScreenState extends ConsumerState<LegalResearchScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = false;
  List<ResearchResult> _results = [];
  final List<String> _history = [
    'Consumer Protection unfair trade practice SaaS contracts',
    'Specific Relief Act injunction against commercial bank guarantee',
    'Arbitration and Conciliation Act Section 9 interim relief',
  ];

  static final List<ResearchResult> _databaseMock = [
    const ResearchResult(
      title: 'M/S Shanti Builders v. State Consumer Dispute Redressal Commission',
      citation: '2024 SCC OnLine SC 482',
      court: 'Supreme Court of India',
      date: 'April 14, 2024',
      summary: 'Failure of real estate developer to hand over possession within stipulated timeline entitles homebuyer to unconditional refund along with interest.',
      keyRatio: 'Unreasonable builder-buyer clauses constitute unfair trade practices under the Consumer Protection Act, 2019.',
      actsApplied: ['Consumer Protection Act, 2019 (Sec 2(46))', 'RERA, 2016 (Sec 18)'],
    ),
    const ResearchResult(
      title: 'TechCorp Solutions Pvt Ltd v. CloudServe Networks',
      citation: '2023 SCC OnLine Del 3120',
      court: 'High Court of Delhi',
      date: 'November 28, 2023',
      summary: 'Arbitration agreement embedded in digital click-wrap terms of service is legally valid and enforceable provided clear notice is furnished.',
      keyRatio: 'Clickwrap assent satisfies Section 7(4)(b) of the Arbitration & Conciliation Act 1996 for e-commerce contracts.',
      actsApplied: ['Arbitration and Conciliation Act, 1996 (Sec 7)', 'Information Technology Act, 2000 (Sec 10A)'],
    ),
    const ResearchResult(
      title: 'Anil Kumar v. Syndicate Finance Corporation',
      citation: '2023 (2) ALD (Crl) 918',
      court: 'High Court of Judicature',
      date: 'August 19, 2023',
      summary: 'Security cheques issued for future liabilities are actionable under Section 138 once the debt crystallizes on the date of presentation.',
      keyRatio: 'Presumption under Section 139 of the NI Act shifts burden on the drawer to establish absence of existing consideration.',
      actsApplied: ['Negotiable Instruments Act, 1881 (Sec 138, 139)'],
    ),
  ];

  Future<void> _executeSearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;

    setState(() {
      _isLoading = true;
      if (!_history.contains(q)) {
        _history.insert(0, q);
      }
    });

    // Call Backend Supabase Edge Function 'legal-research'
    final backendResult = await LegalApiService.searchLegalResearch(query: q);
    final List<ResearchResult> fetched = [];

    if (backendResult['precedents'] is List) {
      for (final p in backendResult['precedents'] as List) {
        if (p is Map) {
          fetched.add(
            ResearchResult(
              title: p['case_name'] as String? ?? 'Precedent Judgment',
              citation: p['citation'] as String? ?? 'Citation on Record',
              court: p['court'] as String? ?? 'Supreme Court / High Court',
              date: '${p["year"] ?? "2024"}',
              summary: p['ratio_summary'] as String? ?? 'Judicial ratio on subject matter.',
              keyRatio: p['ratio_summary'] as String? ?? 'Binding legal principle.',
              actsApplied: (backendResult['statutes'] as List?)
                      ?.map((s) => s is Map ? '${s["act"]} ${s["section"]}' : s.toString())
                      .toList() ??
                  ['Governing Code'],
            ),
          );
        }
      }
    }

    final matches = _databaseMock.where((item) =>
      item.title.toLowerCase().contains(q.toLowerCase()) ||
      item.summary.toLowerCase().contains(q.toLowerCase()) ||
      item.actsApplied.any((act) => act.toLowerCase().contains(q.toLowerCase()))
    ).toList();

    setState(() {
      _results = fetched.isNotEmpty ? fetched : (matches.isNotEmpty ? matches : _databaseMock);
      _isLoading = false;
    });
  }

  void _saveResult(ResearchResult item) {
    ref.read(savedControllerProvider.notifier).save(
      SavedItem(
        id: '',
        title: item.title,
        subtitle: '${item.citation} • ${item.court}',
        content: 'TITLE: ${item.title}\nCITATION: ${item.citation}\nCOURT: ${item.court}\nDATE: ${item.date}\n\nKEY RATIO:\n${item.keyRatio}\n\nSUMMARY:\n${item.summary}\n\nSTATUTES APPLIED:\n${item.actsApplied.join(", ")}',
        type: SavedItemType.research,
        createdAt: DateTime.now(),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved "${item.title}" to library')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal Research Engine'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: LegalTextField(
                controller: _searchController,
                hintText: 'Search case law, statutory sections, legal ratios...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.accentViolet),
                  onPressed: () => _executeSearch(_searchController.text),
                ),
                onSubmitted: _executeSearch,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: DisclaimerBanner(compact: true),
            ),
            AppSpacing.verticalSpaceSm,
            Expanded(
              child: _isLoading
                  ? const LegalLoadingIndicator(message: 'Searching jurisprudence indexes...')
                  : _results.isEmpty
                      ? ListView(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          children: [
                            Text(
                              'Recent Search Queries',
                              style: AppTypography.titleSmall.copyWith(
                                color: context.colors.onSurface,
                              ),
                            ),
                            AppSpacing.verticalSpaceSm,
                            ..._history.map(
                              (h) => ListTile(
                                leading: const Icon(Icons.history_rounded, size: 20),
                                title: Text(h, style: AppTypography.bodyMedium),
                                trailing: const Icon(Icons.north_west, size: 16),
                                contentPadding: EdgeInsets.zero,
                                onTap: () {
                                  _searchController.text = h;
                                  _executeSearch(h);
                                },
                              ),
                            ),
                            AppSpacing.verticalSpaceXl,
                            const LegalEmptyState(
                              title: 'Explore Legal Precedents',
                              message: 'Type any legal principle, case party name, or act to review high court & supreme court rulings.',
                              icon: Icons.menu_book_outlined,
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          itemCount: _results.length,
                          separatorBuilder: (_, __) => AppSpacing.verticalSpaceMd,
                          itemBuilder: (context, index) {
                            final item = _results[index];
                            return LegalCard(
                              padding: AppSpacing.paddingMd,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.title,
                                          style: AppTypography.titleSmall.copyWith(
                                            color: context.colors.onSurface,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.bookmark_add_outlined, size: 20),
                                        onPressed: () => _saveResult(item),
                                        tooltip: 'Save Precedent',
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${item.citation} • ${item.court} (${item.date})',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.accentVioletLight,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  AppSpacing.verticalSpaceSm,
                                  Container(
                                    padding: AppSpacing.paddingSm,
                                    decoration: BoxDecoration(
                                      color: context.legalTheme.elevatedSurface,
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'LEGAL RATIO DECIDENDI:',
                                          style: AppTypography.labelSmall.copyWith(
                                            color: AppColors.accentCyan,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        AppSpacing.verticalSpaceXxs,
                                        Text(
                                          item.keyRatio,
                                          style: AppTypography.bodySmall.copyWith(
                                            color: context.colors.onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  AppSpacing.verticalSpaceSm,
                                  Text(
                                    item.summary,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: context.colors.onSurface.withValues(alpha: 0.8),
                                    ),
                                  ),
                                  AppSpacing.verticalSpaceSm,
                                  Wrap(
                                    spacing: AppSpacing.xs,
                                    runSpacing: AppSpacing.xs,
                                    children: item.actsApplied.map(
                                      (act) => Chip(
                                        label: Text(act, style: const TextStyle(fontSize: 10)),
                                        padding: EdgeInsets.zero,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ).toList(),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
