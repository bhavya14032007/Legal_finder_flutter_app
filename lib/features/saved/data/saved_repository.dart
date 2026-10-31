import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/supabase_service.dart';
import '../models/saved_item.dart';

abstract class SavedRepository {
  Future<List<SavedItem>> getSavedItems({SavedItemType? type, String? searchQuery});
  Future<SavedItem> saveItem(SavedItem item);
  Future<void> deleteItem(String id);
}

class SupabaseSavedRepository implements SavedRepository {
  // In-memory backing store for local/offline mode or before remote sync
  final List<SavedItem> _localItems = [
    SavedItem(
      id: 'mock-1',
      title: 'Residential Lease Agreement',
      subtitle: 'Draft generated on 11-month standard residential tenancy',
      content: 'STANDARD RESIDENTIAL LEASE AGREEMENT\n\nThis Agreement is made on this 24th day of October, 2026, between the Lessor and the Lessee...',
      type: SavedItemType.draft,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    SavedItem(
      id: 'mock-2',
      title: 'Section 138 NI Act Dishonour Notice Analysis',
      subtitle: 'Simplified legal notice breakdown with reply timeline',
      content: 'LEGAL NOTICE SUMMARY:\n- Statutory demand for cheque dishonour under Sec 138.\n- Mandatory 15-day cure notice period from receipt.',
      type: SavedItemType.document,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    SavedItem(
      id: 'mock-3',
      title: 'Consumer Protection Case Law: Deficient Cloud Hosting',
      subtitle: 'Precedent citations from National Commission',
      content: 'Relevant Citation: 2024 SCC OnLine NCDRC 112 - Failure to maintain 99.9% uptime SLA constitutes deficiency in service under CPA 2019.',
      type: SavedItemType.research,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  @override
  Future<List<SavedItem>> getSavedItems({SavedItemType? type, String? searchQuery}) async {
    final client = SupabaseService.client;
    List<SavedItem> items;

    if (client != null && SupabaseService.isAuthenticated) {
      try {
        final query = client.from('saved_items').select();
        final response = await query.order('created_at', ascending: false);
        items = (response as List).map((row) => SavedItem.fromJson(row)).toList();
      } catch (_) {
        items = List.from(_localItems);
      }
    } else {
      items = List.from(_localItems);
    }

    if (type != null) {
      items = items.where((i) => i.type == type).toList();
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase();
      items = items.where((i) =>
        i.title.toLowerCase().contains(q) ||
        i.subtitle.toLowerCase().contains(q) ||
        i.content.toLowerCase().contains(q),
      ).toList();
    }

    return items;
  }

  @override
  Future<SavedItem> saveItem(SavedItem item) async {
    final client = SupabaseService.client;
    final itemToSave = item.id.isEmpty
        ? item.copyWith(id: const Uuid().v4(), createdAt: DateTime.now())
        : item;

    if (client != null && SupabaseService.isAuthenticated) {
      try {
        await client.from('saved_items').upsert(itemToSave.toJson());
      } catch (_) {
        // Fallback local
      }
    }

    _localItems.removeWhere((i) => i.id == itemToSave.id);
    _localItems.insert(0, itemToSave);
    return itemToSave;
  }

  @override
  Future<void> deleteItem(String id) async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isAuthenticated) {
      try {
        await client.from('saved_items').delete().eq('id', id);
      } catch (_) {}
    }
    _localItems.removeWhere((i) => i.id == id);
  }
}

final savedRepositoryProvider = Provider<SavedRepository>((ref) {
  return SupabaseSavedRepository();
});

class SavedState {
  final List<SavedItem> items;
  final bool isLoading;
  final SavedItemType? selectedTypeFilter;
  final String searchQuery;

  const SavedState({
    this.items = const [],
    this.isLoading = false,
    this.selectedTypeFilter,
    this.searchQuery = '',
  });

  SavedState copyWith({
    List<SavedItem>? items,
    bool? isLoading,
    SavedItemType? selectedTypeFilter,
    bool clearTypeFilter = false,
    String? searchQuery,
  }) {
    return SavedState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      selectedTypeFilter: clearTypeFilter ? null : (selectedTypeFilter ?? this.selectedTypeFilter),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final savedControllerProvider = StateNotifierProvider<SavedController, SavedState>((ref) {
  final repo = ref.watch(savedRepositoryProvider);
  return SavedController(repo);
});

class SavedController extends StateNotifier<SavedState> {
  final SavedRepository _repo;

  SavedController(this._repo) : super(const SavedState()) {
    loadItems();
  }

  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true);
    final items = await _repo.getSavedItems(
      type: state.selectedTypeFilter,
      searchQuery: state.searchQuery,
    );
    state = state.copyWith(items: items, isLoading: false);
  }

  void setFilter(SavedItemType? type) {
    if (state.selectedTypeFilter == type) {
      state = state.copyWith(clearTypeFilter: true);
    } else {
      state = state.copyWith(selectedTypeFilter: type);
    }
    loadItems();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadItems();
  }

  Future<void> save(SavedItem item) async {
    await _repo.saveItem(item);
    await loadItems();
  }

  Future<void> delete(String id) async {
    await _repo.deleteItem(id);
    await loadItems();
  }
}
