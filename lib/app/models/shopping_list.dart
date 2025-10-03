import 'package:cloud_firestore/cloud_firestore.dart';
import 'shopping_item.dart';

class ShoppingList {
  String? id;
  String name;
  String description;
  List<ShoppingItem> items;
  DateTime createdAt;
  DateTime updatedAt;
  bool isCompleted;
  double? latitude;  // Para recordatorios de ubicación
  double? longitude; // Para recordatorios de ubicación
  String? locationName; // Nombre del lugar (ej: "Supermercado X")

  ShoppingList({
    this.id,
    required this.name,
    this.description = '',
    this.items = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isCompleted = false,
    this.latitude,
    this.longitude,
    this.locationName,
  }) : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'items': items.map((item) => item.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isCompleted': isCompleted,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
    };
  }

  // Crear desde Map de Firestore
  factory ShoppingList.fromMap(Map<String, dynamic> map, String id) {
    return ShoppingList(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      items: (map['items'] as List<dynamic>?)
          ?.map((item) => ShoppingItem.fromMap(item))
          .toList() ?? [],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isCompleted: map['isCompleted'] ?? false,
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      locationName: map['locationName'],
    );
  }

  // Copiar con modificaciones
  ShoppingList copyWith({
    String? id,
    String? name,
    String? description,
    List<ShoppingItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isCompleted,
    double? latitude,
    double? longitude,
    String? locationName,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
    );
  }
}