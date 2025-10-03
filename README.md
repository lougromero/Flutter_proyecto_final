# Flutter Proyecto Final - Shopping List App

A Flutter application for managing shopping lists with real-time synchronization using Firebase Firestore.

## Features Implemented

### 1. Real-time Synchronization (FirestoreService.getShoppingLists())
- The `FirestoreService.getShoppingLists()` method returns a Stream that automatically updates when data changes in Firestore
- Located in: `lib/services/firestore_service.dart`
- Implementation: Uses `snapshots()` to listen to real-time changes from Firestore

### 2. Add Items (ShoppingListController.addItem())
- The `ShoppingListController.addItem()` method adds new items to a shopping list
- Located in: `lib/controllers/shopping_list_controller.dart`
- Implementation: Creates a new ShoppingItem and updates the list in Firestore

### 3. Mark Items as Completed (ShoppingListController.toggleItemCompleted())
- The `ShoppingListController.toggleItemCompleted()` method toggles the completion status of items
- Located in: `lib/controllers/shopping_list_controller.dart`
- Implementation: Updates the item's completed status and persists to Firestore

### 4. Search Functionality (HomeController.searchLists())
- The `HomeController.searchLists()` method filters shopping lists by name
- Located in: `lib/controllers/home_controller.dart`
- Implementation: Filters lists based on search query using case-insensitive matching

### 5. Progress Calculation (ShoppingListView)
- The completion percentage is calculated in the ShoppingList model
- Located in: `lib/models/shopping_list.dart` and `lib/views/shopping_list_view.dart`
- Implementation: Calculates percentage based on completed items vs total items
- Visual representation with progress bar in the UI

## Project Structure

```
lib/
├── models/
│   ├── shopping_item.dart      # Shopping item model
│   └── shopping_list.dart      # Shopping list model with completion calculation
├── services/
│   └── firestore_service.dart  # Firestore integration with real-time sync
├── controllers/
│   ├── home_controller.dart    # Home view controller with search
│   └── shopping_list_controller.dart  # Shopping list controller
├── views/
│   ├── home_view.dart          # Home screen with list of shopping lists
│   └── shopping_list_view.dart # Shopping list detail view with progress
└── main.dart                   # App entry point

test/
└── models/
    └── shopping_list_test.dart # Tests for progress calculation
```

## Dependencies

- `flutter`: SDK for building the UI
- `cloud_firestore`: For real-time database synchronization
- `get`: State management and navigation
- `firebase_core`: Firebase initialization

## Setup Instructions

1. Install Flutter SDK
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. Set up Firebase project and add configuration files
5. Run `flutter run` to start the app

## Testing

Run tests with:
```bash
flutter test
```

## Key Implementation Details

### Real-time Synchronization
The `getShoppingLists()` method uses Firestore's `snapshots()` to create a real-time stream:
```dart
Stream<List<ShoppingList>> getShoppingLists() {
  return _firestore
      .collection(_collectionName)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => /* convert to ShoppingList objects */);
}
```

### Progress Calculation
The completion percentage is calculated in the ShoppingList model:
```dart
double get completionPercentage {
  if (items.isEmpty) return 0.0;
  final completedCount = items.where((item) => item.completed).length;
  return (completedCount / items.length) * 100;
}
```

### Search Implementation
The search filters lists by name using case-insensitive matching:
```dart
void searchLists(String query) {
  searchQuery.value = query;
  filteredLists.value = shoppingLists.where((list) {
    return list.name.toLowerCase().contains(query.toLowerCase());
  }).toList();
}
```