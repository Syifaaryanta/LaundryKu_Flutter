import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

/// Service untuk mengelola notifikasi lokal
class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Android settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS settings  
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Combined settings
      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize
      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _initialized = true;
      debugPrint('Notification service initialized');
    } catch (e) {
      debugPrint('Failed to initialize notifications: $e');
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // TODO: Navigate to order detail based on payload
  }

  /// Show notification when order is ready for pickup
  Future<void> showPickupReadyNotification({
    required int orderId,
    required String customerName,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'pickup_channel', // Channel ID
        'Pickup Ready', // Channel name
        channelDescription: 'Notifikasi saat pesanan siap diambil',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        orderId, // Notification ID
        'Pesanan Siap Diambil!',
        'Pesanan atas nama $customerName sudah selesai dan siap diambil.',
        details,
        payload: 'order_$orderId',
      );

      debugPrint('Pickup notification sent for order #$orderId');
    } catch (e) {
      debugPrint('Failed to show notification: $e');
    }
  }

  /// Request notification permission (for Android 13+)
  Future<bool> requestPermission() async {
    if (!_initialized) {
      await initialize();
    }

    try {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        return await androidPlugin.requestNotificationsPermission() ?? false;
      }
      return true;
    } catch (e) {
      debugPrint('Failed to request permission: $e');
      return false;
    }
  }

  /// Cancel notification
  Future<void> cancelNotification(int orderId) async {
    await _notifications.cancel(orderId);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
