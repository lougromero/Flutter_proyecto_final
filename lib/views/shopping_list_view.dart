import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/shopping_list_controller.dart';
import '../models/shopping_list.dart';

class ShoppingListView extends StatelessWidget {
  final ShoppingList shoppingList;

  const ShoppingListView({super.key, required this.shoppingList});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ShoppingListController());
    controller.currentList.value = shoppingList;

    return Scaffold(
      appBar: AppBar(
        title: Text(shoppingList.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final currentList = controller.currentList.value;
        if (currentList == null) {
          return const Center(child: Text('No shopping list found'));
        }

        return Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(currentList),
            
            // Items list
            Expanded(
              child: currentList.items.isEmpty
                  ? const Center(
                      child: Text('No items yet. Add some items!'),
                    )
                  : ListView.builder(
                      itemCount: currentList.items.length,
                      itemBuilder: (context, index) {
                        final item = currentList.items[index];
                        return ListTile(
                          leading: Checkbox(
                            value: item.completed,
                            onChanged: (_) {
                              controller.toggleItemCompleted(item.id);
                            },
                          ),
                          title: Text(
                            item.name,
                            style: TextStyle(
                              decoration: item.completed
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              controller.removeItem(item.id);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context, controller),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Build progress indicator widget
  Widget _buildProgressIndicator(ShoppingList list) {
    final percentage = list.completionPercentage;
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.blue.shade50,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage == 100 ? Colors.green : Colors.blue,
            ),
            minHeight: 10,
          ),
          const SizedBox(height: 8),
          Text(
            '${list.items.where((item) => item.completed).length} of ${list.items.length} items completed',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // Show dialog to add new item
  void _showAddItemDialog(BuildContext context, ShoppingListController controller) {
    final textController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Item'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'Enter item name',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  controller.addItem(textController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
