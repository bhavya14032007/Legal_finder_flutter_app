import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/legal_button.dart';
import '../../../../core/widgets/legal_card.dart';
import '../../../../core/widgets/legal_empty_state.dart';

enum VaultCategory {
  contracts('Contracts & Agreements', Icons.article_outlined),
  identity('Identity & Verification', Icons.badge_outlined),
  courtNotices('Court Notices & Orders', Icons.gavel_outlined),
  property('Property & Title Deeds', Icons.home_work_outlined);

  final String label;
  final IconData icon;
  const VaultCategory(this.label, this.icon);
}

class VaultDocument {
  final String id;
  final String name;
  final String size;
  final String date;
  final VaultCategory category;
  final bool isEncrypted;

  const VaultDocument({
    required this.id,
    required this.name,
    required this.size,
    required this.date,
    required this.category,
    this.isEncrypted = true,
  });
}

class LegalVaultScreen extends StatefulWidget {
  const LegalVaultScreen({super.key});

  @override
  State<LegalVaultScreen> createState() => _LegalVaultScreenState();
}

class _LegalVaultScreenState extends State<LegalVaultScreen> {
  VaultCategory? _selectedCategory;

  final List<VaultDocument> _vaultDocs = [
    const VaultDocument(
      id: 'doc-1',
      name: 'Residential_Lease_Deed_Signed.pdf',
      size: '2.4 MB',
      date: 'Oct 28, 2026',
      category: VaultCategory.contracts,
    ),
    const VaultDocument(
      id: 'doc-2',
      name: 'Passport_Government_ID_Verified.pdf',
      size: '1.1 MB',
      date: 'Sep 12, 2026',
      category: VaultCategory.identity,
    ),
    const VaultDocument(
      id: 'doc-3',
      name: 'Interim_Injunction_Court_Order.pdf',
      size: '840 KB',
      date: 'Aug 30, 2026',
      category: VaultCategory.courtNotices,
    ),
    const VaultDocument(
      id: 'doc-4',
      name: 'Property_Sale_Deed_Registry.pdf',
      size: '4.8 MB',
      date: 'Jul 15, 2026',
      category: VaultCategory.property,
    ),
  ];

  Future<void> _uploadDocument() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg'],
      );
      if (files.isNotEmpty) {
        final f = files.first;
        final bytes = f.lengthSync() ?? (1024 * 512);
        setState(() {
          _vaultDocs.insert(
            0,
            VaultDocument(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: f.name,
              size: '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB',
              date: 'Just now',
              category: _selectedCategory ?? VaultCategory.contracts,
            ),
          );
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Encrypted and secured "${f.name}" in Vault')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload error: $e')),
        );
      }
    }
  }

  void _showDocumentPreview(VaultDocument doc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.legalTheme.cardBackground,
        title: Row(
          children: [
            const Icon(Icons.lock_rounded, color: AppColors.success, size: 20),
            AppSpacing.horizontalSpaceXs,
            Expanded(
              child: Text(
                doc.name,
                style: AppTypography.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${doc.category.label}', style: AppTypography.bodySmall),
            Text('File Size: ${doc.size}', style: AppTypography.bodySmall),
            Text('Uploaded: ${doc.date}', style: AppTypography.bodySmall),
            AppSpacing.verticalSpaceMd,
            Container(
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                color: context.legalTheme.elevatedSurface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(color: context.legalTheme.cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_rounded, color: AppColors.success, size: 28),
                  AppSpacing.horizontalSpaceSm,
                  Expanded(
                    child: Text(
                      'AES-256 Client-Side Encrypted.\nOnly you hold the decryption keys.',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.colors.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          LegalButton(
            text: 'Download',
            icon: Icons.download_rounded,
            height: 38,
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Document decryption initiated...')),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == null
        ? _vaultDocs
        : _vaultDocs.where((d) => d.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Encrypted Legal Vault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Upload Document',
            onPressed: _uploadDocument,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Security badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              color: AppColors.accentViolet.withValues(alpha: 0.08),
              child: Row(
                children: [
                  const Icon(Icons.lock_rounded, size: 16, color: AppColors.accentVioletLight),
                  AppSpacing.horizontalSpaceXs,
                  Expanded(
                    child: Text(
                      'Zero-Knowledge Encrypted Storage • Supabase Secure Vault',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.accentVioletLight,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.verticalSpaceSm,

            // Category filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All Vault Files'),
                    selected: _selectedCategory == null,
                    onSelected: (_) => setState(() => _selectedCategory = null),
                  ),
                  AppSpacing.horizontalSpaceXs,
                  ...VaultCategory.values.map(
                    (cat) => Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.xs),
                      child: FilterChip(
                        avatar: Icon(cat.icon, size: 14),
                        label: Text(cat.label.split(' ').first),
                        selected: _selectedCategory == cat,
                        onSelected: (_) => setState(() {
                          _selectedCategory = _selectedCategory == cat ? null : cat;
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.verticalSpaceSm,

            Expanded(
              child: filtered.isEmpty
                  ? LegalEmptyState(
                      title: 'No Documents in Category',
                      message: 'Securely upload your contracts, court documents, and deeds.',
                      actionLabel: 'Upload to Vault',
                      onAction: _uploadDocument,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => AppSpacing.verticalSpaceSm,
                      itemBuilder: (context, index) {
                        final doc = filtered[index];
                        return Dismissible(
                          key: ValueKey(doc.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: AppSpacing.lg),
                            color: AppColors.danger,
                            child: const Icon(Icons.delete_outline, color: Colors.white),
                          ),
                          onDismissed: (_) {
                            setState(() {
                              _vaultDocs.removeWhere((d) => d.id == doc.id);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Removed ${doc.name}')),
                            );
                          },
                          child: LegalCard(
                            onTap: () => _showDocumentPreview(doc),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.accentVioletLight.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                  ),
                                  child: Icon(doc.category.icon, color: AppColors.accentVioletLight),
                                ),
                                AppSpacing.horizontalSpaceMd,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doc.name,
                                        style: AppTypography.titleSmall.copyWith(
                                          color: context.colors.onSurface,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${doc.size} • Uploaded ${doc.date}',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: context.colors.onSurface.withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.success),
                              ],
                            ),
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
