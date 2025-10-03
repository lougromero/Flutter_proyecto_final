import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shopping_list.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'shopping_lists';

  // Get shopping lists with real-time synchronization
  Stream<List<ShoppingList>> getShoppingLists() {
    return _firestore
        .collection(_collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ShoppingList.fromMap(data);
      }).toList();
    });
  }

  // Get a single shopping list
  Future<ShoppingList?> getShoppingList(String id) async {
    final doc = await _firestore.collection(_collectionName).doc(id).get();
    if (doc.exists) {
      final data = doc.data()!;
      data['id'] = doc.id;
      return ShoppingList.fromMap(data);
    }
    return null;
  }

  // Create a new shopping list
  Future<String> createShoppingList(ShoppingList list) async {
    final docRef = await _firestore.collection(_collectionName).add(list.toMap());
    return docRef.id;
  }

  // Update an existing shopping list
  Future<void> updateShoppingList(ShoppingList list) async {
    await _firestore.collection(_collectionName).doc(list.id).update(list.toMap());
  }

  // Delete a shopping list
  Future<void> deleteShoppingList(String id) async {
    await _firestore.collection(_collectionName).doc(id).delete();
  }
}
