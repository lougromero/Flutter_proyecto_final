import 'package:get/get.dart';
import '../models/shopping_list.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';
import '../routes/app_routes.dart';

// Maneja todas las listas y navegación
class HomeController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final LocationService _locationService = LocationService();
  final _shoppingLists = <ShoppingList>[].obs;
  final _isLoading = false.obs;
  final _searchText = ''.obs;
  // Métodos críticos:
  // Carga todas las listas
  // Crea nuevas listas
  // Navega a lista específica
  // Filtrado de búsqueda
  List<ShoppingList> get shoppingLists => _shoppingLists;
  bool get isLoading => _isLoading.value;
  String get searchText => _searchText.value;

  List<ShoppingList> get filteredLists {
    if (_searchText.value.isEmpty) return _shoppingLists;
    return _shoppingLists.where((list) =>
        list.name.toLowerCase().contains(_searchText.value.toLowerCase()) ||
        list.description.toLowerCase().contains(_searchText.value.toLowerCase())
    ).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadShoppingLists();
    _requestLocationPermission();
  }

  void loadShoppingLists() {
    _isLoading.value = true;
    _firestoreService.getShoppingLists().listen(
      (lists) {
        _shoppingLists.value = lists;
        _isLoading.value = false;
      },
      onError: (error) {
        _isLoading.value = false;
        Get.snackbar(
          'Error',
          'No se pudieron cargar las listas',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      },
    );
  }

  void updateSearchText(String text) {
    _searchText.value = text;
  }

  void clearSearch() {
    _searchText.value = '';
  }

  Future<void> createNewList(String name, String description) async {
    _isLoading.value = true;

    final newList = ShoppingList(
      id: '', // Se asignará automáticamente
      name: name,
      description: description,
      items: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final id = await _firestoreService.createShoppingList(newList);
    
    if (id != null) {
      Get.snackbar(
        'Éxito',
        'Lista creada exitosamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } else {
      Get.snackbar(
        'Error',
        'No se pudo crear la lista',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
    _isLoading.value = false;
  }

  Future<void> deleteList(ShoppingList list) async {
    if (list.id != null) {
      final success = await _firestoreService.deleteShoppingList(list.id!);
      if (success) {
        Get.snackbar(
          'Éxito',
          'Lista eliminada',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          'No se pudo eliminar la lista',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }
    }
  }

  void openList(ShoppingList list) {
    Get.toNamed(AppRoutes.SHOPPING_LIST, arguments: list.id);
  }

  void goToSettings() {
    Get.toNamed(AppRoutes.SETTINGS);
  }

  Future<void> toggleListCompletion(ShoppingList list) async {
    if (list.id != null) {
      final success = await _firestoreService.markListAsCompleted(
        list.id!,
        !list.isCompleted,
      );
      
      if (!success) {
        Get.snackbar(
          'Error',
          'No se pudo actualizar la lista',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }
    }
  }

  Future<void> _requestLocationPermission() async {
    try {
      await _locationService.requestLocationPermission();
    } catch (e) {
      print('Error requesting location permission: $e');
    }
  }
}