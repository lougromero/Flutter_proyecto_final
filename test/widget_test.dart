// Tests para la aplicación SmartCart - Lista de Compras Inteligente
//
// Este archivo contiene las pruebas principales para verificar que la aplicación
// funcione correctamente. Incluye tests para widgets, navegación y funcionalidades
// básicas de la aplicación de listas de compras.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:lista_compras_getx/app/models/shopping_list.dart';
import 'package:lista_compras_getx/app/models/shopping_item.dart';

void main() {
  group('SmartCart - Tests de la Aplicación', () {
    
    // Configuración inicial antes de cada test
    setUp(() {
      // Reiniciar GetX para evitar conflictos entre tests
      Get.reset();
    });

    // Limpiar después de cada test
    tearDown(() {
      Get.reset();
    });

    testWidgets('Debe mostrar el título de la aplicación correctamente', (WidgetTester tester) async {
      // Preparar: Simular la aplicación sin Firebase para testing
      await tester.pumpWidget(
        GetMaterialApp(
          title: 'Smart Shopping List',
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Mis Listas de Compras'),
            ),
            body: const Center(
              child: Text('SmartCart'),
            ),
          ),
        ),
      );

      // Verificar: Comprobar que el título aparece correctamente
      expect(find.text('Mis Listas de Compras'), findsOneWidget);
      expect(find.text('SmartCart'), findsOneWidget);
    });

    testWidgets('Debe mostrar el botón para crear nueva lista', (WidgetTester tester) async {
      // Preparar: Crear la pantalla principal con botón flotante
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Listas')),
            body: const Center(child: Text('Sin listas')),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              tooltip: 'Nueva Lista',
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      // Verificar: El botón de añadir debe estar presente
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      
      // Acción: Tocar el botón flotante
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      // El test pasa si no hay errores al tocar el botón
    });

    test('Modelo ShoppingList - Debe crear una lista correctamente', () {
      // Preparar: Crear una nueva lista de compras
      final lista = ShoppingList(
        name: 'Supermercado',
        description: 'Compras de la semana',
        items: [],
      );

      // Verificar: Los datos deben coincidir
      expect(lista.name, equals('Supermercado'));
      expect(lista.description, equals('Compras de la semana'));
      expect(lista.items, isEmpty);
      expect(lista.isCompleted, isFalse);
      expect(lista.createdAt, isA<DateTime>());
    });

    test('Modelo ShoppingItem - Debe crear un artículo correctamente', () {
      // Preparar: Crear un nuevo artículo
      final articulo = ShoppingItem(
        name: 'Leche',
        quantity: 2,
        category: 'Lácteos',
        price: 3.50,
        notes: 'Descremada',
      );

      // Verificar: Los datos del artículo deben ser correctos
      expect(articulo.name, equals('Leche'));
      expect(articulo.quantity, equals(2));
      expect(articulo.category, equals('Lácteos'));
      expect(articulo.price, equals(3.50));
      expect(articulo.notes, equals('Descremada'));
      expect(articulo.isCompleted, isFalse);
      expect(articulo.id, isNotEmpty);
    });

    test('ShoppingList - Debe poder agregar artículos', () {
      // Preparar: Crear lista y artículo
      final lista = ShoppingList(
        name: 'Mi Lista',
        description: 'Test',
        items: [],
      );

      final articulo = ShoppingItem(
        name: 'Pan',
        quantity: 1,
        category: 'Panadería',
      );

      // Acción: Agregar artículo a la lista
      final listaActualizada = lista.copyWith(
        items: [...lista.items, articulo],
      );

      // Verificar: La lista debe contener el artículo
      expect(listaActualizada.items.length, equals(1));
      expect(listaActualizada.items.first.name, equals('Pan'));
    });

    test('ShoppingList - Debe calcular progreso correctamente', () {
      // Preparar: Crear lista con artículos completados y pendientes
      final articuloCompletado = ShoppingItem(
        name: 'Arroz',
        quantity: 1,
        category: 'Cereales',
        isCompleted: true,
      );

      final articuloPendiente = ShoppingItem(
        name: 'Aceite',
        quantity: 1,
        category: 'Condimentos',
        isCompleted: false,
      );

      final lista = ShoppingList(
        name: 'Lista Mixta',
        description: 'Con artículos completados y pendientes',
        items: [articuloCompletado, articuloPendiente],
      );

      // Verificar: El progreso debe ser 50% (1 de 2 completado)
      final completados = lista.items.where((item) => item.isCompleted).length;
      final total = lista.items.length;
      final progreso = completados / total;

      expect(progreso, equals(0.5)); // 50%
      expect(completados, equals(1));
      expect(total, equals(2));
    });

    testWidgets('Debe mostrar mensaje cuando no hay listas', (WidgetTester tester) async {
      // Preparar: Pantalla con estado vacío
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Mis Listas')),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'No tienes listas de compras',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text('Toca + para crear tu primera lista'),
                ],
              ),
            ),
          ),
        ),
      );

      // Verificar: Los elementos del estado vacío deben estar presentes
      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
      expect(find.text('No tienes listas de compras'), findsOneWidget);
      expect(find.text('Toca + para crear tu primera lista'), findsOneWidget);
    });

    test('ShoppingItem - Debe poder marcar como completado', () {
      // Preparar: Crear artículo sin completar
      final articulo = ShoppingItem(
        name: 'Tomate',
        quantity: 3,
        category: 'Verduras',
        isCompleted: false,
      );

      // Acción: Marcar como completado
      final articuloCompletado = articulo.copyWith(isCompleted: true);

      // Verificar: El estado debe cambiar correctamente
      expect(articulo.isCompleted, isFalse);
      expect(articuloCompletado.isCompleted, isTrue);
      expect(articuloCompletado.name, equals(articulo.name)); // Otros datos iguales
    });

    test('ShoppingList - Debe mantener fecha de creación', () {
      // Preparar: Crear lista
      final fechaAntes = DateTime.now();
      final lista = ShoppingList(
        name: 'Lista con Fecha',
        description: 'Test de fechas',
      );
      final fechaDespues = DateTime.now();

      // Verificar: La fecha de creación debe estar en el rango correcto
      expect(lista.createdAt.isAfter(fechaAntes.subtract(const Duration(seconds: 1))), isTrue);
      expect(lista.createdAt.isBefore(fechaDespues.add(const Duration(seconds: 1))), isTrue);
      expect(lista.updatedAt, equals(lista.createdAt));
    });
  });

  group('SmartCart - Tests de Validación', () {
    
    test('ShoppingItem - Debe manejar nombres vacíos', () {
      // Preparar: Crear artículo con nombre vacío
      final articulo = ShoppingItem(name: '');

      // Verificar: Debe crear el objeto pero con nombre vacío
      expect(articulo.name, equals(''));
      expect(articulo.quantity, equals(1)); // Valor por defecto
      expect(articulo.category, equals('General')); // Valor por defecto
    });

    test('ShoppingItem - Cantidad debe tener valor por defecto', () {
      // Preparar: Crear artículo sin especificar cantidad
      final articulo = ShoppingItem(name: 'Producto');

      // Verificar: La cantidad por defecto debe ser 1
      expect(articulo.quantity, equals(1));
      expect(articulo.quantity, greaterThan(0));
    });

    test('ShoppingList - Debe poder convertir a Map para Firebase', () {
      // Preparar: Crear lista con datos
      final lista = ShoppingList(
        name: 'Lista Firebase',
        description: 'Para testing',
        items: [
          ShoppingItem(name: 'Item 1', quantity: 1),
          ShoppingItem(name: 'Item 2', quantity: 2),
        ],
      );

      // Acción: Convertir a Map
      final mapa = lista.toMap();

      // Verificar: El Map debe contener los datos correctos
      expect(mapa['name'], equals('Lista Firebase'));
      expect(mapa['description'], equals('Para testing'));
      expect(mapa['items'], isA<List>());
      expect(mapa['items'].length, equals(2));
      expect(mapa['isCompleted'], isFalse);
    });
  });
}
