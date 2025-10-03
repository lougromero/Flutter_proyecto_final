# Architecture Diagram

## Application Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER INTERFACE                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────┐        ┌──────────────────────────┐  │
│  │     HomeView         │        │  ShoppingListView        │  │
│  │                      │        │                          │  │
│  │  - Search Bar        │        │  - Progress Indicator    │  │
│  │  - List of Lists     │        │  - Item List             │  │
│  │  - Create Button     │        │  - Add Item Button       │  │
│  └──────────────────────┘        └──────────────────────────┘  │
│           │                                 │                   │
│           │ GetX Binding                    │ GetX Binding      │
│           ▼                                 ▼                   │
├─────────────────────────────────────────────────────────────────┤
│                        CONTROLLERS                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────┐        ┌──────────────────────────┐  │
│  │  HomeController      │        │ ShoppingListController   │  │
│  │                      │        │                          │  │
│  │  ✅ searchLists()    │        │  ✅ addItem()            │  │
│  │  - createList()      │        │  ✅ toggleCompleted()    │  │
│  │  - deleteList()      │        │  - removeItem()          │  │
│  │                      │        │                          │  │
│  └──────────────────────┘        └──────────────────────────┘  │
│           │                                 │                   │
│           │                                 │                   │
│           ▼                                 ▼                   │
├─────────────────────────────────────────────────────────────────┤
│                         SERVICES                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│              ┌──────────────────────────────┐                   │
│              │    FirestoreService         │                   │
│              │                             │                   │
│              │  ✅ getShoppingLists()      │                   │
│              │  - createShoppingList()     │                   │
│              │  - updateShoppingList()     │                   │
│              │  - deleteShoppingList()     │                   │
│              └──────────────────────────────┘                   │
│                           │                                     │
│                           │ Real-time Stream                    │
│                           ▼                                     │
├─────────────────────────────────────────────────────────────────┤
│                       DATA MODELS                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────┐        ┌──────────────────────────┐  │
│  │   ShoppingList       │        │    ShoppingItem          │  │
│  │                      │        │                          │  │
│  │  - id                │        │  - id                    │  │
│  │  - name              │        │  - name                  │  │
│  │  - items[]           │        │  - completed             │  │
│  │  - createdAt         │        │                          │  │
│  │                      │        │                          │  │
│  │  ✅ completion%      │        │                          │  │
│  │  - toMap()           │        │  - toMap()               │  │
│  │  - fromMap()         │        │  - fromMap()             │  │
│  └──────────────────────┘        └──────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ Firebase SDK
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    FIREBASE FIRESTORE                           │
│                      (Cloud Database)                           │
│                                                                 │
│  Collection: shopping_lists                                     │
│  ├── doc1: { id, name, items[], createdAt }                     │
│  ├── doc2: { id, name, items[], createdAt }                     │
│  └── doc3: { id, name, items[], createdAt }                     │
│                                                                 │
│  ✅ Real-time synchronization via snapshots()                   │
└─────────────────────────────────────────────────────────────────┘
```

## Feature Implementation Map

### 1️⃣ Real-time Synchronization
```
Firebase Firestore
    ↓ snapshots() stream
FirestoreService.getShoppingLists()
    ↓ Stream<List<ShoppingList>>
HomeController._subscribeToShoppingLists()
    ↓ Updates shoppingLists
HomeView (Obx widget)
    ↓ Automatically rebuilds
User sees updated lists in UI
```

### 2️⃣ Add Items
```
User clicks + button
    ↓
Dialog opens for item name
    ↓
User enters "Milk" and clicks Add
    ↓
ShoppingListController.addItem("Milk")
    ↓
Creates new ShoppingItem
    ↓
Updates list.items
    ↓
FirestoreService.updateShoppingList()
    ↓
Firestore updated
    ↓
Real-time sync triggers
    ↓
All clients receive update
```

### 3️⃣ Toggle Item Completed
```
User clicks checkbox
    ↓
ShoppingListController.toggleItemCompleted(itemId)
    ↓
Finds item in list
    ↓
Toggles item.completed
    ↓
FirestoreService.updateShoppingList()
    ↓
Firestore updated
    ↓
Progress recalculated automatically
    ↓
UI updates (checkbox, strikethrough, progress bar)
```

### 4️⃣ Search
```
User types in search field
    ↓
HomeController.searchLists(query)
    ↓
Filters shoppingLists by name
    ↓
Updates filteredLists
    ↓
HomeView (Obx widget)
    ↓
Shows only matching lists
```

### 5️⃣ Progress Calculation
```
ShoppingList has items[]
    ↓
completionPercentage getter called
    ↓
Counts completed items
    ↓
Divides by total items
    ↓
Returns percentage (0-100)
    ↓
ShoppingListView._buildProgressIndicator()
    ↓
Displays:
  - Percentage text
  - Progress bar (colored)
  - "X of Y items completed"
```

## Data Flow Examples

### Example 1: Creating a Shopping List
```
1. User: Clicks + button in HomeView
2. UI: Shows dialog
3. User: Enters "Weekly Groceries"
4. UI: Calls controller.createShoppingList("Weekly Groceries")
5. Controller: Creates ShoppingList object
6. Controller: Calls service.createShoppingList()
7. Service: Saves to Firestore
8. Firestore: Document created with ID
9. Firestore: Triggers snapshot update
10. Service: Stream emits new list
11. Controller: Updates shoppingLists
12. UI: Automatically shows new list
```

### Example 2: Searching for Lists
```
1. User: Types "grocery" in search bar
2. UI: Calls controller.searchLists("grocery")
3. Controller: Filters shoppingLists
4. Controller: Updates filteredLists
5. UI: Obx rebuilds with filtered results
6. User: Sees only lists containing "grocery"
```

### Example 3: Marking Item as Complete
```
1. User: Checks "Milk" checkbox
2. UI: Calls controller.toggleItemCompleted(milkId)
3. Controller: Finds "Milk" item
4. Controller: Sets completed = true
5. Controller: Calls service.updateShoppingList()
6. Service: Updates Firestore
7. Model: completionPercentage recalculates
8. UI: Updates checkbox ✅
9. UI: Adds strikethrough to text
10. UI: Updates progress bar (33% → 66%)
```

## State Management with GetX

```
Observable State (Reactive)
├── HomeController
│   ├── shoppingLists.obs         ← Updated by stream
│   ├── filteredLists.obs         ← Updated by search
│   ├── searchQuery.obs           ← Updated by TextField
│   └── isLoading.obs             ← Loading indicator
│
└── ShoppingListController
    ├── currentList.obs           ← Current shopping list
    └── isLoading.obs             ← Loading indicator

Obx Widgets (Auto-rebuild on change)
├── HomeView
│   └── Obx(() => ListView(...))  ← Rebuilds when filteredLists changes
│
└── ShoppingListView
    └── Obx(() => Column(...))    ← Rebuilds when currentList changes
```

## Testing Strategy

```
Unit Tests
└── shopping_list_test.dart
    ├── Test: completionPercentage with 0 items
    ├── Test: completionPercentage with 50% complete
    ├── Test: completionPercentage with 100% complete
    └── Test: Serialization (toMap/fromMap)

Integration Tests (Not implemented)
├── Test: Add item updates progress
├── Test: Toggle item updates UI
└── Test: Search filters correctly

E2E Tests (Not implemented)
├── Test: Complete user flow
└── Test: Real-time sync between clients
```

## Technology Stack

```
┌─────────────────────────────────────┐
│         Flutter Framework           │
│  - Material Design 3                │
│  - Dart Language                    │
└─────────────────────────────────────┘
              │
┌─────────────┼─────────────────────────┐
│             │                         │
┌─────────────▼──────────┐  ┌──────────▼──────────┐
│   GetX (State Mgmt)    │  │  Firebase Services  │
│  - Controllers         │  │  - Firestore        │
│  - Navigation          │  │  - Real-time sync   │
│  - Dependency Inject.  │  │  - Cloud storage    │
└────────────────────────┘  └─────────────────────┘
```

## Key Design Patterns

1. **MVC Pattern**: Models, Views, Controllers
2. **Repository Pattern**: FirestoreService abstracts data access
3. **Observer Pattern**: GetX observables and Obx widgets
4. **Stream Pattern**: Real-time data with Firestore snapshots
5. **Singleton Pattern**: FirestoreService instance
6. **Factory Pattern**: fromMap() constructors

## ✅ Requirements Checklist

- [x] 1. Sincronización en Tiempo Real: FirestoreService.getShoppingLists()
- [x] 2. Añadir Artículos: ShoppingListController.addItem()
- [x] 3. Marcar Completados: ShoppingListController.toggleItemCompleted()
- [x] 4. Búsqueda: HomeController.searchLists()
- [x] 5. Progreso: Cálculo de porcentaje completado en ShoppingListView

All requirements implemented and documented! 🎉
