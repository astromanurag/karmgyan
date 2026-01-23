// Stub for Flutter Local Notifications on web
class FlutterLocalNotificationsPlugin {
  Future<bool> initialize(dynamic initSettings, {Function? onDidReceiveNotificationResponse}) => Future.value(false);
  Future<void> show(int id, String? title, String? body, dynamic details) => Future.value();
  Future<void> requestNotificationsPermission() => Future.value();
  Future<void> requestPermissions({bool? alert, bool? badge, bool? sound}) => Future.value();
  T? resolvePlatformSpecificImplementation<T>() => null;
}

// Platform-specific plugin stubs
class AndroidFlutterLocalNotificationsPlugin {
  Future<void> requestNotificationsPermission() => Future.value();
}

class IOSFlutterLocalNotificationsPlugin {
  Future<void> requestPermissions({bool? alert, bool? badge, bool? sound}) => Future.value();
}

class AndroidInitializationSettings {
  const AndroidInitializationSettings(String icon);
}

class DarwinInitializationSettings {
  const DarwinInitializationSettings({bool? requestAlertPermission, bool? requestBadgePermission, bool? requestSoundPermission});
}

class InitializationSettings {
  const InitializationSettings({dynamic android, dynamic iOS});
}

class AndroidNotificationDetails {
  const AndroidNotificationDetails(String channelId, String channelName, {String? channelDescription, dynamic importance, dynamic priority});
}

class DarwinNotificationDetails {
  const DarwinNotificationDetails();
}

class NotificationDetails {
  const NotificationDetails({dynamic android, dynamic iOS});
}

class NotificationResponse {
  final String? payload;
  NotificationResponse({this.payload});
}

enum Importance { high }
enum Priority { high }

