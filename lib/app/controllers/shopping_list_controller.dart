import 'package:get/get.dart';
import '../models/shopping_list.dart';
import '../models/shopping_item.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';

// Gestiona toda la lógica de una lista individual
class ShoppingListController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final LocationService _locationService = LocationService();
  final NotificationService _notificationService = NotificationService();

  final _shoppingList = Rxn<ShoppingList>();
  final _isLoading = false.obs;

  ShoppingList? get shoppingList => _shoppingList.value;
  bool get isLoading => _isLoading.value;

  List<ShoppingItem> get pendingItems =>
      _shoppingList.value?.items.where((item) => !item.isCompleted).toList() ?? [];
  
  List<ShoppingItem> get completedItems =>
      _shoppingList.value?.items.where((item) => item.isCompleted).toList() ?? [];

  @override
  void onInit() {
    super.onInit();
    final listId = Get.arguments as String?;
    if (listId != null) {
      loadShoppingList(listId);
    }
  }

  Future<void> loadShoppingList(String listId) async {
    _isLoading.value = true;
    try {
      final list = await _firestoreService.getShoppingList(listId);
      if (list != null) {
        _shoppingList.value = list;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo cargar la lista',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
    _isLoading.value = false;
  }

  Future<void> addItem({
    required String name,
    int quantity = 1,
    String category = 'General',
    String? notes,
    double? price,
  }) async {
    if (_shoppingList.value == null) return;

    final newItem = ShoppingItem(
      name: name,
      quantity: quantity,
      category: category,
      notes: notes,
      price: price,
    );

    final updatedList = _shoppingList.value!.copyWith(
      items: [..._shoppingList.value!.items, newItem],
    );

    final success = await _updateList(updatedList);
    if (success) {
      Get.snackbar(
        'Éxito',
        'Artículo agregado',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> toggleItemCompletion(ShoppingItem item) async {
    if (_shoppingList.value == null) return;

    final updatedItems = _shoppingList.value!.items.map((listItem) {
      if (listItem.id == item.id) {
        return listItem.copyWith(isCompleted: !listItem.isCompleted);
      }
      return listItem;
    }).toList();

    final updatedList = _shoppingList.value!.copyWith(items: updatedItems);
    await _updateList(updatedList);
  }

  Future<void> removeItem(ShoppingItem item) async {
    if (_shoppingList.value == null) return;

    final updatedItems = _shoppingList.value!.items
        .where((listItem) => listItem.id != item.id)
        .toList();

    final updatedList = _shoppingList.value!.copyWith(items: updatedItems);
    final success = await _updateList(updatedList);
    
    if (success) {
      Get.snackbar(
        'Éxito',
        'Artículo eliminado',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateItem(ShoppingItem item) async {
    if (_shoppingList.value == null) return;

    final updatedItems = _shoppingList.value!.items.map((listItem) {
      if (listItem.id == item.id) {
        return item;
      }
      return listItem;
    }).toList();

    final updatedList = _shoppingList.value!.copyWith(items: updatedItems);
    await _updateList(updatedList);
  }

  Future<void> setLocationReminder(String locationName) async {
    if (_shoppingList.value == null) return;

    final position = await _locationService.getCurrentLocation();
    if (position == null) {
      Get.snackbar(
        'Error',
        'No se pudo obtener la ubicación actual',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }

    final updatedList = _shoppingList.value!.copyWith(
      latitude: position.latitude,
      longitude: position.longitude,
      locationName: locationName,
    );

    final success = await _updateList(updatedList);
    if (success) {
      Get.snackbar(
        'Éxito',
        'Recordatorio de ubicación configurado para $locationName',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<bool> _updateList(ShoppingList list) async {
    _isLoading.value = true;
    final success = await _firestoreService.updateShoppingList(list);
    
    if (success) {
      _shoppingList.value = list;
    } else {
      Get.snackbar(
        'Error',
        'No se pudo actualizar la lista',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
    
    _isLoading.value = false;
    return success;
  }
}