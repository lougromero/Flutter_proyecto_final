import 'shopping_item.dart';

class ShoppingList {
  final String id;
  final String name;
  final List<ShoppingItem> items;
  final DateTime createdAt;

  ShoppingList({
    required this.id,
    required this.name,
    required this.items,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'items': items.map((item) => item.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory ShoppingList.fromMap(Map<String, dynamic> map) {
    return ShoppingList(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => ShoppingItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  ShoppingList copyWith({
    String? id,
    String? name,
    List<ShoppingItem>? items,
    DateTime? createdAt,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      name: name ?? this.name,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Calculate completion percentage
  double get completionPercentage {
    if (items.isEmpty) return 0.0;
    final completedCount = items.where((item) => item.completed).length;
    return (completedCount / items.length) * 100;
  }
}
