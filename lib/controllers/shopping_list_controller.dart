import 'package:get/get.dart';
import '../models/shopping_list.dart';
import '../models/shopping_item.dart';
import '../services/firestore_service.dart';

class ShoppingListController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  
  final Rx<ShoppingList?> currentList = Rx<ShoppingList?>(null);
  final RxBool isLoading = false.obs;

  // Load a shopping list
  Future<void> loadShoppingList(String id) async {
    isLoading.value = true;
    try {
      final list = await _firestoreService.getShoppingList(id);
      currentList.value = list;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load shopping list: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Add an item to the shopping list
  Future<void> addItem(String itemName) async {
    if (currentList.value == null) return;
    
    try {
      final newItem = ShoppingItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: itemName,
        completed: false,
      );
      
      final updatedItems = [...currentList.value!.items, newItem];
      final updatedList = currentList.value!.copyWith(items: updatedItems);
      
      await _firestoreService.updateShoppingList(updatedList);
      currentList.value = updatedList;
      
      Get.snackbar('Success', 'Item added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add item: $e');
    }
  }

  // Toggle item completion status
  Future<void> toggleItemCompleted(String itemId) async {
    if (currentList.value == null) return;
    
    try {
      final updatedItems = currentList.value!.items.map((item) {
        if (item.id == itemId) {
          return item.copyWith(completed: !item.completed);
        }
        return item;
      }).toList();
      
      final updatedList = currentList.value!.copyWith(items: updatedItems);
      
      await _firestoreService.updateShoppingList(updatedList);
      currentList.value = updatedList;
    } catch (e) {
      Get.snackbar('Error', 'Failed to toggle item: $e');
    }
  }

  // Remove an item from the shopping list
  Future<void> removeItem(String itemId) async {
    if (currentList.value == null) return;
    
    try {
      final updatedItems = currentList.value!.items
          .where((item) => item.id != itemId)
          .toList();
      
      final updatedList = currentList.value!.copyWith(items: updatedItems);
      
      await _firestoreService.updateShoppingList(updatedList);
      currentList.value = updatedList;
      
      Get.snackbar('Success', 'Item removed successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove item: $e');
    }
  }
}
