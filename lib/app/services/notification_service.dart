import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Configuración para Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Configuración para iOS
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Manejar cuando el usuario toca la notificación
        print('Notificación tocada: ${response.payload}');
      },
    );

    // Solicitar permisos
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Solicitar permiso de notificaciones
    await Permission.notification.request();
    
    // Para Android 13+ (API 33+)
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> showLocationReminder({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'location_reminders',
      'Recordatorios de Ubicación',
      channelDescription: 'Notificaciones cuando estés cerca de una tienda',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> showShoppingReminder({
    required String listName,
    required int pendingItems,
  }) async {
    await showLocationReminder(
      title: '🛒 Lista de Compras',
      body: '$listName tiene $pendingItems elementos pendientes',
      payload: 'shopping_reminder',
    );
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}