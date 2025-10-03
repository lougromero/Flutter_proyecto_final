# Implementation Details

## Architecture Overview

This Flutter shopping list application follows the MVC (Model-View-Controller) pattern with GetX for state management.

### Component Breakdown

#### 1. Real-time Synchronization - FirestoreService.getShoppingLists()

**Location:** `lib/services/firestore_service.dart`

**Implementation:**
```dart
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
```

**How it works:**
- Uses Firestore's `.snapshots()` method to create a real-time stream
- Automatically emits new data whenever the database changes
- Maps Firestore documents to ShoppingList objects
- Orders lists by creation date (newest first)

**Usage in HomeController:**
```dart
void _subscribeToShoppingLists() {
  _firestoreService.getShoppingLists().listen(
    (lists) {
      shoppingLists.value = lists;
      _applySearch();
    },
  );
}
```

---

#### 2. Add Items - ShoppingListController.addItem()

**Location:** `lib/controllers/shopping_list_controller.dart`

**Implementation:**
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

**How it works:**
- Creates a new ShoppingItem with a unique timestamp-based ID
- Adds it to the existing items list
- Updates the shopping list in Firestore
- Updates the local state for immediate UI feedback
- Shows success/error messages to the user

---

#### 3. Mark Items as Completed - ShoppingListController.toggleItemCompleted()

**Location:** `lib/controllers/shopping_list_controller.dart`

**Implementation:**
```dart
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
```

**How it works:**
- Finds the item by ID and toggles its completed status
- Creates a new list with the updated item
- Persists the change to Firestore
- Updates the local state for immediate UI update
- This triggers the progress calculation to update automatically

---

#### 4. Search Functionality - HomeController.searchLists()

**Location:** `lib/controllers/home_controller.dart`

**Implementation:**
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
          .contains(searchQuery.value.toLowerCase());
    }).toList();
  }
}
```

**How it works:**
- Takes a search query string
- Filters the shopping lists by name using case-insensitive matching
- Updates the filteredLists observable
- UI automatically updates to show only matching lists
- If query is empty, shows all lists

**UI Integration:**
```dart
TextField(
  decoration: InputDecoration(
    hintText: 'Search shopping lists...',
    prefixIcon: const Icon(Icons.search),
  ),
  onChanged: (query) => controller.searchLists(query),
)
```

---

#### 5. Progress Calculation - ShoppingList.completionPercentage

**Location:** `lib/models/shopping_list.dart`

**Implementation:**
```dart
double get completionPercentage {
  if (items.isEmpty) return 0.0;
  final completedCount = items.where((item) => item.completed).length;
  return (completedCount / items.length) * 100;
}
```

**How it works:**
- Calculates percentage of completed items
- Returns 0.0 if list is empty
- Counts items where `completed == true`
- Divides by total items and multiplies by 100 for percentage

**UI Display in ShoppingListView:**
```dart
Widget _buildProgressIndicator(ShoppingList list) {
  final percentage = list.completionPercentage;
  
  return Container(
    padding: const EdgeInsets.all(16.0),
    color: Colors.blue.shade50,
    child: Column(
      children: [
        // Percentage text
        Text('${percentage.toStringAsFixed(1)}%'),
        
        // Progress bar
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(
            percentage == 100 ? Colors.green : Colors.blue,
          ),
        ),
        
        // Completed count
        Text('${completed} of ${total} items completed'),
      ],
    ),
  );
}
```

**Visual Features:**
- Shows percentage as text (e.g., "75.0%")
- Displays linear progress bar
- Changes color to green when 100% complete
- Shows count of completed vs. total items

---

## Data Flow

1. **App Initialization:**
   - Firebase is initialized in `main.dart`
   - HomeController subscribes to real-time updates
   - Shopping lists are fetched from Firestore

2. **Real-time Updates:**
   - Firestore sends updates via the stream
   - HomeController receives and processes updates
   - UI automatically reflects changes

3. **User Actions:**
   - User adds/toggles/removes items
   - Controller updates Firestore
   - Firestore triggers real-time update
   - All connected clients receive the update

4. **Search:**
   - User types in search field
   - Controller filters lists locally
   - UI shows filtered results immediately

5. **Progress Display:**
   - Progress is calculated on-demand
   - Updates whenever items are toggled
   - Shows visual feedback in the UI

## Testing

Unit tests are provided for the progress calculation logic:

**Location:** `test/models/shopping_list_test.dart`

Tests cover:
- Empty list (0% progress)
- Partial completion (50% progress)
- Full completion (100% progress)
- Serialization/deserialization

Run tests with:
```bash
flutter test
```

## State Management

The app uses GetX for state management:
- **Reactive State:** `Rx<T>` and `.obs` for observable values
- **Automatic UI Updates:** `Obx()` widget rebuilds when observables change
- **Dependency Injection:** `Get.put()` for controller lifecycle
- **Navigation:** `Get.to()` for screen transitions
- **Snackbars:** `Get.snackbar()` for user feedback

## Firebase Configuration

To run this app, you need to:
1. Create a Firebase project
2. Add your app to the project
3. Download configuration files:
   - `google-services.json` for Android
   - `GoogleService-Info.plist` for iOS
4. Enable Firestore in your Firebase console
5. Set up security rules as needed

Example Firestore rules for development:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /shopping_lists/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```
