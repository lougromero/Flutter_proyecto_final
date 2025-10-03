import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shopping_list.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'shopping_lists';

  // Obtener todas las listas de compras
  Stream<List<ShoppingList>> getShoppingLists() {
    return _db
        .collection(_collection)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ShoppingList.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Obtener una lista específica
  Future<ShoppingList?> getShoppingList(String id) async {
    try {
      final doc = await _db.collection(_collection).doc(id).get();
      if (doc.exists) {
        return ShoppingList.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error obteniendo lista: $e');
      return null;
    }
  }

  // Crear nueva lista
  Future<String?> createShoppingList(ShoppingList list) async {
    try {
      final docRef = await _db.collection(_collection).add(list.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creando lista: $e');
      return null;
    }
  }

  // Actualizar lista
  Future<bool> updateShoppingList(ShoppingList list) async {
    try {
      if (list.id == null) return false;
      
      await _db.collection(_collection).doc(list.id).update({
        ...list.toMap(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      print('Error actualizando lista: $e');
      return false;
    }
  }

  // Eliminar lista
  Future<bool> deleteShoppingList(String id) async {
    try {
      await _db.collection(_collection).doc(id).delete();
      return true;
    } catch (e) {
      print('Error eliminando lista: $e');
      return false;
    }
  }

  // Marcar lista como completada
  Future<bool> markListAsCompleted(String id, bool isCompleted) async {
    try {
      await _db.collection(_collection).doc(id).update({
        'isCompleted': isCompleted,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      print('Error marcando lista: $e');
      return false;
    }
  }
}