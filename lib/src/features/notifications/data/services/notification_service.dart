import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_10y.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // 1. Timezone initialization
    tz.initializeTimeZones();
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
    } catch (e) {
      tz.setLocalLocation(tz.UTC);
    }

    // 2. Initialize local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap if needed
      },
    );

    _isInitialized = true;
  }

  /// Request OS permission for notifications (Used for first launch)
  Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      final iosImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (iosImplementation != null) {
        final granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } else if (Platform.isAndroid) {
      final granted = await Permission.notification.request();
      return granted.isGranted;
    }
    return false;
  }

  /// Check if notification permission is currently granted
  Future<bool> isPermissionGranted() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  /// Schedule daily notification at the specified local time
  Future<void> scheduleDailyNotification(int hour, int minute) async {
    await initialize();

    // Cancel existing scheduled notifications to avoid duplicates
    await cancelNotifications();

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the scheduled time is in the past today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_training_channel',
      'Daily Training Reminder',
      channelDescription: 'Reminds you to practice IT English drills and roleplay daily.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id: 0,
      title: '学習の時間です！',
      body: '今日もIT英語のDrillsやAIロールプレイに挑戦して、英語力を磨きましょう！',
      scheduledDate: scheduledDate,
      notificationDetails: platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Schedules daily
    );
  }

  /// Cancel all scheduled notifications
  Future<void> cancelNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Open iOS/Android App System Settings
  Future<void> openSettings() async {
    await openAppSettings();
  }
}
