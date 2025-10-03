# Usage Examples

## Creating a Shopping List

```dart
// In HomeView, tap the floating action button
// A dialog will appear
final controller = Get.find<HomeController>();
await controller.createShoppingList('Grocery Shopping');
```

## Adding Items to a List

```dart
// In ShoppingListView, tap the floating action button
// A dialog will appear to enter the item name
final controller = Get.find<ShoppingListController>();
await controller.addItem('Milk');
await controller.addItem('Eggs');
await controller.addItem('Bread');
```

## Marking Items as Complete

```dart
// Tap the checkbox next to an item
final controller = Get.find<ShoppingListController>();
await controller.toggleItemCompleted(itemId);
```

## Searching for Lists

```dart
// Type in the search bar at the top of HomeView
final controller = Get.find<HomeController>();
controller.searchLists('grocery');
```

## Viewing Progress

The progress is automatically calculated and displayed:
- At the top of ShoppingListView
- In the list preview on HomeView

```dart
// Progress calculation happens automatically
final list = ShoppingList(...);
print('Progress: ${list.completionPercentage}%');
```

## Complete User Flow

### 1. Launch App
- App initializes Firebase
- HomeController subscribes to Firestore updates
- Shopping lists are loaded and displayed

### 2. Create a New List
1. User taps the + button on HomeView
2. Dialog appears asking for list name
3. User enters "Weekly Groceries"
4. User taps "Create"
5. New list is saved to Firestore
6. Real-time sync updates all clients
7. List appears on HomeView

### 3. Add Items to List
1. User taps on "Weekly Groceries" list
2. ShoppingListView opens
3. Progress shows 0% (no items yet)
4. User taps + button
5. Dialog appears asking for item name
6. User enters "Milk" and taps "Add"
7. Item is added to Firestore
8. Item appears in the list
9. Progress remains 0% (0/1 completed)

### 4. Mark Items as Complete
1. User buys milk
2. User taps checkbox next to "Milk"
3. Item is marked as complete in Firestore
4. Checkbox is checked
5. Item text gets strikethrough
6. Progress updates to 100% (1/1 completed)
7. Progress bar turns green

### 5. Search for Lists
1. User has multiple shopping lists
2. User types "grocery" in search bar
3. Only lists with "grocery" in name are shown
4. User clears search
5. All lists are shown again

## Code Examples

### Creating a Shopping List Programmatically

```dart
import 'package:flutter_proyecto_final/models/shopping_list.dart';
import 'package:flutter_proyecto_final/models/shopping_item.dart';
import 'package:flutter_proyecto_final/services/firestore_service.dart';

final service = FirestoreService();

// Create a new list
final shoppingList = ShoppingList(
  id: '',
  name: 'Weekly Groceries',
  items: [
    ShoppingItem(id: '1', name: 'Milk', completed: false),
    ShoppingItem(id: '2', name: 'Eggs', completed: false),
    ShoppingItem(id: '3', name: 'Bread', completed: true),
  ],
  createdAt: DateTime.now(),
);

// Save to Firestore
final id = await service.createShoppingList(shoppingList);
print('Created list with ID: $id');

// Calculate progress
print('Progress: ${shoppingList.completionPercentage}%'); // 33.3%
```

### Listening to Real-time Updates

```dart
import 'package:flutter_proyecto_final/services/firestore_service.dart';

final service = FirestoreService();

// Subscribe to updates
service.getShoppingLists().listen((lists) {
  print('Received ${lists.length} shopping lists');
  for (final list in lists) {
    print('${list.name}: ${list.completionPercentage}% complete');
  }
});
```

### Working with Shopping List Controller

```dart
import 'package:get/get.dart';
import 'package:flutter_proyecto_final/controllers/shopping_list_controller.dart';

// Get the controller
final controller = Get.find<ShoppingListController>();

// Load a list
await controller.loadShoppingList('list-id-123');

// Add items
await controller.addItem('Apples');
await controller.addItem('Oranges');
await controller.addItem('Bananas');

// Toggle completion
final firstItemId = controller.currentList.value!.items[0].id;
await controller.toggleItemCompleted(firstItemId);

// Remove an item
await controller.removeItem(firstItemId);
```

### Working with Home Controller

```dart
import 'package:get/get.dart';
import 'package:flutter_proyecto_final/controllers/home_controller.dart';

// Get the controller
final controller = Get.find<HomeController>();

// Create a new list
await controller.createShoppingList('Weekend Shopping');

// Search lists
controller.searchLists('weekend');

// Access filtered results
print('Found ${controller.filteredLists.length} lists');

// Delete a list
await controller.deleteShoppingList('list-id-123');
```

## UI Screenshots

Since this is a text-based documentation, here's what the UI looks like:

### HomeView
```
┌─────────────────────────────────┐
│      Shopping Lists         [+] │
├─────────────────────────────────┤
│ 🔍 Search shopping lists...     │
├─────────────────────────────────┤
│ Weekly Groceries           [🗑] │
│ 3 items                         │
│ ▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░ 66.7%     │
├─────────────────────────────────┤
│ Weekend Shopping           [🗑] │
│ 5 items                         │
│ ▓▓▓▓▓░░░░░░░░░░░░░░░ 20.0%     │
└─────────────────────────────────┘
```

### ShoppingListView
```
┌─────────────────────────────────┐
│  ← Weekly Groceries         [+] │
├─────────────────────────────────┤
│ Progress:              66.7%    │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░         │
│ 2 of 3 items completed          │
├─────────────────────────────────┤
│ ☑ Milk                     [🗑] │
│ ☑ Eggs                     [🗑] │
│ ☐ Bread                    [🗑] │
└─────────────────────────────────┘
```
