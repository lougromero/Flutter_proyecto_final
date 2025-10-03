# Code Reference Guide

Quick reference to locate each required feature in the codebase.

## 1. Sincronización en Tiempo Real

### FirestoreService.getShoppingLists()

**File:** `lib/services/firestore_service.dart`  
**Lines:** 9-21

```dart
Stream<List<ShoppingList>> getShoppingLists() {
  return _firestore
      .collection(_collectionName)
      .orderBy('createdAt', descending: true)
      .snapshots()  // <-- Real-time synchronization here
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return ShoppingList.fromMap(data);
    }).toList();
  });
}
```

**Usage:** `lib/controllers/home_controller.dart:23-31`

---

## 2. Añadir Artículos

### ShoppingListController.addItem()

**File:** `lib/controllers/shopping_list_controller.dart`  
**Lines:** 26-46

```dart
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
```

**UI:** `lib/views/shopping_list_view.dart:133-159`

---

## 3. Marcar Completados

### ShoppingListController.toggleItemCompleted()

**File:** `lib/controllers/shopping_list_controller.dart`  
**Lines:** 49-66

```dart
Future<void> toggleItemCompleted(String itemId) async {
  if (currentList.value == null) return;
  
  try {
    final updatedItems = currentList.value!.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(completed: !item.completed);  // <-- Toggle here
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
```

**UI:** `lib/views/shopping_list_view.dart:50-55`

---

## 4. Búsqueda

### HomeController.searchLists()

**File:** `lib/controllers/home_controller.dart`  
**Lines:** 33-48

```dart
void searchLists(String query) {
  searchQuery.value = query;
  _applySearch();
}

void _applySearch() {
  if (searchQuery.value.isEmpty) {
    filteredLists.value = shoppingLists;
  } else {
    filteredLists.value = shoppingLists.where((list) {
      return list.name
          .toLowerCase()
          .contains(searchQuery.value.toLowerCase());  // <-- Search logic
    }).toList();
  }
}
```

**UI:** `lib/views/home_view.dart:18-28`

---

## 5. Progreso

### Calculation: ShoppingList.completionPercentage

**File:** `lib/models/shopping_list.dart`  
**Lines:** 54-58

```dart
double get completionPercentage {
  if (items.isEmpty) return 0.0;
  final completedCount = items.where((item) => item.completed).length;
  return (completedCount / items.length) * 100;  // <-- Calculation
}
```

### Display: ShoppingListView._buildProgressIndicator()

**File:** `lib/views/shopping_list_view.dart`  
**Lines:** 82-127

```dart
Widget _buildProgressIndicator(ShoppingList list) {
  final percentage = list.completionPercentage;  // <-- Use calculation
  
  return Container(
    padding: const EdgeInsets.all(16.0),
    color: Colors.blue.shade50,
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Progress:', ...),
            Text('${percentage.toStringAsFixed(1)}%', ...),  // <-- Display %
          ],
        ),
        LinearProgressIndicator(
          value: percentage / 100,  // <-- Progress bar
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(
            percentage == 100 ? Colors.green : Colors.blue,
          ),
        ),
        Text('${completed} of ${total} items completed', ...),  // <-- Count
      ],
    ),
  );
}
```

---

## File Structure Overview

```
lib/
├── models/
│   ├── shopping_item.dart           # Item data model
│   └── shopping_list.dart           # List data model + REQUIREMENT 5 (calculation)
├── services/
│   └── firestore_service.dart       # REQUIREMENT 1 (real-time sync)
├── controllers/
│   ├── home_controller.dart         # REQUIREMENT 4 (search)
│   └── shopping_list_controller.dart # REQUIREMENTS 2 & 3 (add, toggle)
├── views/
│   ├── home_view.dart               # Home screen UI
│   └── shopping_list_view.dart      # List detail UI + REQUIREMENT 5 (display)
└── main.dart                        # App entry point

test/
└── models/
    └── shopping_list_test.dart      # Tests for REQUIREMENT 5
```

---

## Quick Navigation

### Want to see how real-time sync works?
→ Go to: `lib/services/firestore_service.dart:9-21`

### Want to understand how items are added?
→ Go to: `lib/controllers/shopping_list_controller.dart:26-46`

### Want to see how completion is toggled?
→ Go to: `lib/controllers/shopping_list_controller.dart:49-66`

### Want to understand the search feature?
→ Go to: `lib/controllers/home_controller.dart:33-48`

### Want to see progress calculation?
→ Go to: `lib/models/shopping_list.dart:54-58`

### Want to see progress UI?
→ Go to: `lib/views/shopping_list_view.dart:82-127`

---

## Key Dependencies

- **cloud_firestore**: Real-time database synchronization
- **get**: State management, navigation, snackbars
- **firebase_core**: Firebase initialization

---

## Testing

Run tests:
```bash
flutter test test/models/shopping_list_test.dart
```

Test coverage:
- ✅ Progress with 0 items
- ✅ Progress with partial completion
- ✅ Progress with full completion
- ✅ Serialization/deserialization
