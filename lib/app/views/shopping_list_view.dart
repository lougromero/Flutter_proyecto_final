import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/shopping_list_controller.dart';
import '../models/shopping_item.dart';

class ShoppingListView extends GetView<ShoppingListController> {
  const ShoppingListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          controller.shoppingList?.name ?? 'Lista de Compras',
        )),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () => _showLocationDialog(context),
            tooltip: 'Configurar recordatorio de ubicación',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        final list = controller.shoppingList;
        if (list == null) {
          return const Center(
            child: Text('Lista no encontrada'),
          );
        }

        final pendingItems = controller.pendingItems;
        final completedItems = controller.completedItems;

        return Column(
          children: [
            // Información de la lista
            if (list.description.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      list.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),

            // Progreso
            if (list.items.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Progreso',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: completedItems.length / list.items.length,
                                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${completedItems.length} de ${list.items.length} completados',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        if (list.locationName != null) ...[
                          const SizedBox(width: 16),
                          Column(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              Text(
                                list.locationName!,
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

            // Lista de elementos
            Expanded(
              child: pendingItems.isEmpty && completedItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_shopping_cart,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '¡Agrega tu primer artículo!',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Toca el botón + para comenzar',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        // Elementos pendientes
                        if (pendingItems.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Pendientes (${pendingItems.length})',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...pendingItems.map((item) => _ItemCard(
                            item: item,
                            onToggle: () => controller.toggleItemCompletion(item),
                            onDelete: () => _showDeleteItemConfirmation(context, item),
                            onEdit: (updatedItem) => controller.updateItem(updatedItem),
                          )),
                        ],

                        // Elementos completados
                        if (completedItems.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Completados (${completedItems.length})',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                          ...completedItems.map((item) => _ItemCard(
                            item: item,
                            onToggle: () => controller.toggleItemCompletion(item),
                            onDelete: () => _showDeleteItemConfirmation(context, item),
                            onEdit: (updatedItem) => controller.updateItem(updatedItem),
                          )),
                        ],

                        const SizedBox(height: 80), // Espacio para el FAB
                      ],
                    ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        child: const Icon(Icons.add),
        tooltip: 'Agregar artículo',
      ),
    );
  }

  void _showLocationDialog(BuildContext context) {
    final controller = Get.find<ShoppingListController>();
    final locationController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Recordatorio de ubicación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Cómo quieres llamar a este lugar?'),
            const SizedBox(height: 16),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Nombre del lugar',
                hintText: 'Ej: Supermercado Central',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.setLocationReminder('Tienda');
            },
            child: const Text('Usar "Tienda"'),
          ),
          ElevatedButton(
            onPressed: () {
              if (locationController.text.trim().isNotEmpty) {
                Get.back();
                controller.setLocationReminder(locationController.text.trim());
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final controller = Get.find<ShoppingListController>();
    final nameController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final notesController = TextEditingController();
    final priceController = TextEditingController();
    final selectedCategory = 'General'.obs;

    final categories = [
      'General',
      'Frutas y Verduras',
      'Carnes',
      'Lácteos',
      'Panadería',
      'Limpieza',
      'Cuidado Personal',
      'Bebidas',
      'Congelados',
      'Otros',
    ];

    Get.dialog(
      AlertDialog(
        title: const Text('Agregar Artículo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del artículo*',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Cantidad',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Obx(() => DropdownButtonFormField<String>(
                      value: selectedCategory.value,
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(),
                      ),
                      items: categories.map((category) => 
                        DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      ).toList(),
                      onChanged: (value) {
                        if (value != null) selectedCategory.value = value;
                      },
                    )),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Precio (opcional)',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                final quantity = int.tryParse(quantityController.text) ?? 1;
                final price = double.tryParse(priceController.text);
                
                Get.back();
                controller.addItem(
                  name: nameController.text.trim(),
                  quantity: quantity,
                  category: selectedCategory.value,
                  notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                  price: price,
                );
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteItemConfirmation(BuildContext context, ShoppingItem item) {
    final controller = Get.find<ShoppingListController>();
    
    Get.dialog(
      AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Eliminar "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.removeItem(item);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final ShoppingItem item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final Function(ShoppingItem) onEdit;

  const _ItemCard({
    required this.item,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        leading: Checkbox(
          value: item.isCompleted,
          onChanged: (_) => onToggle(),
        ),
        title: Text(
          item.name,
          style: TextStyle(
            decoration: item.isCompleted ? TextDecoration.lineThrough : null,
            color: item.isCompleted 
                ? Theme.of(context).colorScheme.outline 
                : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (item.quantity > 1) ...[
                  Icon(
                    Icons.numbers,
                    size: 14,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text('${item.quantity}x'),
                  const SizedBox(width: 12),
                ],
                Icon(
                  Icons.category,
                  size: 14,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 4),
                Text(item.category),
                if (item.price != null) ...[
                  const SizedBox(width: 12),
                  Icon(
                    Icons.attach_money,
                    size: 14,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  Text('\$${item.price!.toStringAsFixed(2)}'),
                ],
              ],
            ),
            if (item.notes != null && item.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                item.notes!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditDialog(context);
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Eliminar', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final nameController = TextEditingController(text: item.name);
    final quantityController = TextEditingController(text: item.quantity.toString());
    final notesController = TextEditingController(text: item.notes ?? '');
    final priceController = TextEditingController(
        text: item.price?.toString() ?? '');
    final selectedCategory = item.category.obs;

    final categories = [
      'General',
      'Frutas y Verduras',
      'Carnes',
      'Lácteos',
      'Panadería',
      'Limpieza',
      'Cuidado Personal',
      'Bebidas',
      'Congelados',
      'Otros',
    ];

    Get.dialog(
      AlertDialog(
        title: const Text('Editar Artículo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del artículo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Cantidad',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Obx(() => DropdownButtonFormField<String>(
                      value: selectedCategory.value,
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(),
                      ),
                      items: categories.map((category) => 
                        DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      ).toList(),
                      onChanged: (value) {
                        if (value != null) selectedCategory.value = value;
                      },
                    )),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                final updatedItem = item.copyWith(
                  name: nameController.text.trim(),
                  quantity: int.tryParse(quantityController.text) ?? 1,
                  category: selectedCategory.value,
                  notes: notesController.text.trim().isEmpty 
                      ? null 
                      : notesController.text.trim(),
                  price: priceController.text.trim().isEmpty
                      ? null 
                      : double.tryParse(priceController.text),
                );
                
                onEdit(updatedItem);
                Get.back();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}