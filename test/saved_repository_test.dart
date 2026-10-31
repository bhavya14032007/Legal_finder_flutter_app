import 'package:flutter_test/flutter_test.dart';
import 'package:legal_helper/features/saved/data/saved_repository.dart';
import 'package:legal_helper/features/saved/models/saved_item.dart';

void main() {
  group('SavedRepository Tests', () {
    late SupabaseSavedRepository repository;

    setUp(() {
      repository = SupabaseSavedRepository();
    });

    test('retrieves default items', () async {
      final items = await repository.getSavedItems();
      expect(items.isNotEmpty, isTrue);
    });

    test('can save a new item and query it', () async {
      final newItem = SavedItem(
        id: 'test-item-1',
        title: 'Cease and Desist Draft',
        subtitle: 'Trademark infringement notice',
        content: 'Formal demand to cease domain squatting...',
        type: SavedItemType.draft,
        createdAt: DateTime.now(),
      );

      final saved = await repository.saveItem(newItem);
      expect(saved.id, 'test-item-1');

      final results = await repository.getSavedItems(searchQuery: 'trademark');
      expect(results.any((i) => i.id == 'test-item-1'), isTrue);
    });

    test('filters items by SavedItemType', () async {
      final drafts = await repository.getSavedItems(type: SavedItemType.draft);
      expect(drafts.every((i) => i.type == SavedItemType.draft), isTrue);
    });

    test('deletes item by id', () async {
      final toDelete = SavedItem(
        id: 'delete-me-id',
        title: 'Temporary Doc',
        subtitle: 'Sub',
        content: 'Content',
        type: SavedItemType.document,
        createdAt: DateTime.now(),
      );

      await repository.saveItem(toDelete);
      var items = await repository.getSavedItems();
      expect(items.any((i) => i.id == 'delete-me-id'), isTrue);

      await repository.deleteItem('delete-me-id');
      items = await repository.getSavedItems();
      expect(items.any((i) => i.id == 'delete-me-id'), isFalse);
    });
  });
}
