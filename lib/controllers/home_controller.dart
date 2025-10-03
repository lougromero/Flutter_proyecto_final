import 'package:get/get.dart';
import '../models/shopping_list.dart';
import '../services/firestore_service.dart';

class HomeController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  
  final RxList<ShoppingList> shoppingLists = <ShoppingList>[].obs;
  final RxList<ShoppingList> filteredLists = <ShoppingList>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _subscribeToShoppingLists();
  }

  // Subscribe to real-time updates from Firestore
  void _subscribeToShoppingLists() {
    _firestoreService.getShoppingLists().listen(
      (lists) {
        shoppingLists.value = lists;
        _applySearch();
      },
      onError: (error) {
        Get.snackbar('Error', 'Failed to load shopping lists: $error');
      },
    );
  }

  // Search shopping lists by name
  void searchLists(String query) {
    searchQuery.value = query;
    _applySearch();
  }

  // Apply search filter to shopping lists
  void _applySearch() {
    if (searchQuery.value.isEmpty) {
      filteredLists.value = shoppingLists;
    } else {
      filteredLists.value = shoppingLists.where((list) {
        return list.name
            .toLowerCase()
            .contains(searchQuery.value.toLowerCase());
      }).toList();
    }
  }

  // Create a new shopping list
  Future<void> createShoppingList(String name) async {
    isLoading.value = true;
    try {
      final newList = ShoppingList(
        id: '',
        name: name,
        items: [],
        createdAt: DateTime.now(),
      );
      
      await _firestoreService.createShoppingList(newList);
      Get.snackbar('Success', 'Shopping list created successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create shopping list: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Delete a shopping list
  Future<void> deleteShoppingList(String id) async {
    isLoading.value = true;
    try {
      await _firestoreService.deleteShoppingList(id);
      Get.snackbar('Success', 'Shopping list deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete shopping list: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
