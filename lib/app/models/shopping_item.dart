class ShoppingItem {
  String id;
  String name;
  int quantity;
  String category;
  bool isCompleted;
  String? notes;
  double? price;

  ShoppingItem({
    String? id,
    required this.name,
    this.quantity = 1,
    this.category = 'General',
    this.isCompleted = false,
    this.notes,
    this.price,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'category': category,
      'isCompleted': isCompleted,
      'notes': notes,
      'price': price,
    };
  }

  // Crear desde Map de Firestore
  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 1,
      category: map['category'] ?? 'General',
      isCompleted: map['isCompleted'] ?? false,
      notes: map['notes'],
      price: map['price']?.toDouble(),
    );
  }

  // Copiar con modificaciones
  ShoppingItem copyWith({
    String? id,
    String? name,
    int? quantity,
    String? category,
    bool? isCompleted,
    String? notes,
    double? price,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
      price: price ?? this.price,
    );
  }
}