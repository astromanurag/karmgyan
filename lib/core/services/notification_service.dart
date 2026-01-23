import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart' if (dart.library.html) 'package:karmgyan/core/services/firebase_messaging_stub.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' if (dart.library.html) 'package:karmgyan/core/services/flutter_local_notifications_stub.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Skip Firebase on web if not configured
    if (kIsWeb) {
      debugPrint('Skipping Firebase initialization on web');
      return;
    }

    try {
      // Initialize local notifications
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Request permissions
      await _requestPermission();

      // Get FCM token
      final token = await _messaging.getToken();
      debugPrint('FCM Token: $token');
    } catch (e) {
      debugPrint('Notification initialization error: $e');
    }
  }

  static Future<void> _requestPermission() async {
    if (kIsWeb) return;

    // Request permissions separately for Android and iOS
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  static Future<String?> getToken() async {
    if (kIsWeb) return null;
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;

    const android = AndroidNotificationDetails(
      'karmgyan_channel',
      'karmgyan Notifications',
      channelDescription: 'Notifications for karmgyan app',
      importance: Importance.high,
      priority: Priority.high,
    );

    const ios = DarwinNotificationDetails();
    const details = NotificationDetails(android: android, iOS: ios);

    await _notifications.show(id, title, body, details);
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (kIsWeb) return;

    const android = AndroidNotificationDetails(
      'karmgyan_channel',
      'karmgyan Notifications',
      channelDescription: 'Notifications for karmgyan app',
      importance: Importance.high,
      priority: Priority.high,
    );

    const ios = DarwinNotificationDetails();
    const details = NotificationDetails(android: android, iOS: ios);

    // Show notification immediately for now (can be enhanced with timezone package later)
    await _notifications.show(id, title, body, details);
  }

  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }
}
