class ShoppingItem {
  final String id;
  final String name;
  final bool completed;

  ShoppingItem({
    required this.id,
    required this.name,
    this.completed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'completed': completed,
    };
  }

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      completed: map['completed'] ?? false,
    );
  }

  ShoppingItem copyWith({
    String? id,
    String? name,
    bool? completed,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      completed: completed ?? this.completed,
    );
  }
}
