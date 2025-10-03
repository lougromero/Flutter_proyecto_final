import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_proyecto_final/models/shopping_item.dart';
import 'package:flutter_proyecto_final/models/shopping_list.dart';

void main() {
  group('ShoppingList', () {
    test('should calculate completion percentage correctly with no items', () {
      final list = ShoppingList(
        id: '1',
        name: 'Test List',
        items: [],
        createdAt: DateTime.now(),
      );

      expect(list.completionPercentage, 0.0);
    });

    test('should calculate completion percentage correctly with some completed items', () {
      final list = ShoppingList(
        id: '1',
        name: 'Test List',
        items: [
          ShoppingItem(id: '1', name: 'Item 1', completed: true),
          ShoppingItem(id: '2', name: 'Item 2', completed: false),
          ShoppingItem(id: '3', name: 'Item 3', completed: true),
          ShoppingItem(id: '4', name: 'Item 4', completed: false),
        ],
        createdAt: DateTime.now(),
      );

      expect(list.completionPercentage, 50.0);
    });

    test('should calculate completion percentage correctly with all completed items', () {
      final list = ShoppingList(
        id: '1',
        name: 'Test List',
        items: [
          ShoppingItem(id: '1', name: 'Item 1', completed: true),
          ShoppingItem(id: '2', name: 'Item 2', completed: true),
          ShoppingItem(id: '3', name: 'Item 3', completed: true),
        ],
        createdAt: DateTime.now(),
      );

      expect(list.completionPercentage, 100.0);
    });

    test('should serialize to and from map correctly', () {
      final list = ShoppingList(
        id: '1',
        name: 'Test List',
        items: [
          ShoppingItem(id: '1', name: 'Item 1', completed: true),
          ShoppingItem(id: '2', name: 'Item 2', completed: false),
        ],
        createdAt: DateTime(2023, 1, 1),
      );

      final map = list.toMap();
      final deserializedList = ShoppingList.fromMap(map);

      expect(deserializedList.id, list.id);
      expect(deserializedList.name, list.name);
      expect(deserializedList.items.length, list.items.length);
      expect(deserializedList.items[0].name, list.items[0].name);
      expect(deserializedList.items[0].completed, list.items[0].completed);
    });
  });
}
