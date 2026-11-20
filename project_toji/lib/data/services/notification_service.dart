import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/reminder_model.dart';

class NotificationService {
  static NotificationService? _instance;
  factory NotificationService() => _instance ??= NotificationService._internal();
  NotificationService._internal();

  FlutterLocalNotificationsPlugin? _notificationsPlugin;
  FlutterLocalNotificationsPlugin? get plugin {
    if (_notificationsPlugin != null) return _notificationsPlugin;
    try {
      _notificationsPlugin = FlutterLocalNotificationsPlugin();
      return _notificationsPlugin;
    } catch (_) {
      return null;
    }
  }

  bool _isInitialized = false;

  static const String channelId = 'project_toji_reminders';
  static const String channelName = 'Reminders';
  static const String channelDescription = 'Project Toji reminder alerts';

  bool get _isTestEnv {
    return WidgetsBinding.instance.runtimeType.toString().contains('Test');
  }

  Future<void> init() async {
    if (_isInitialized || _isTestEnv) return;

    try {
      tz.initializeTimeZones();

      final p = plugin;
      if (p == null) return;

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const linuxSettings = LinuxInitializationSettings(
        defaultActionName: 'Open notification',
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
        linux: linuxSettings,
      );

      await p.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );

      // Create Android Notification Channel
      const androidChannel = AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      );

      final androidPlatform = p
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlatform != null) {
        await androidPlatform.createNotificationChannel(androidChannel);
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  Future<bool> requestPermissions() async {
    try {
      final p = plugin;
      if (p == null) return false;

      final androidPlatform = p
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlatform != null) {
        final granted =
            await androidPlatform.requestNotificationsPermission();
        return granted ?? false;
      }

      final iosPlatform = p
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosPlatform != null) {
        final granted = await iosPlatform.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
    return false;
  }

  Future<void> scheduleReminderNotification(ReminderModel reminder) async {
    if (_isTestEnv) return;
    if (!_isInitialized) {
      await init();
    }

    if (reminder.isCompleted) {
      await cancelNotification(reminder.id);
      return;
    }

    if (reminder.dateTime.isBefore(DateTime.now())) {
      // Do not schedule past reminders
      return;
    }

    try {
      final p = plugin;
      if (p == null) return;

      final tzDateTime = tz.TZDateTime.from(reminder.dateTime, tz.local);

      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFFDC143C),
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );

      await p.zonedSchedule(
        id: reminder.id,
        title: '⏰ ${reminder.title}',
        body: reminder.description?.isNotEmpty == true
            ? reminder.description!
            : 'Reminder from Project Toji',
        scheduledDate: tzDateTime,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint('Scheduled notification #${reminder.id} for $tzDateTime');
    } catch (e) {
      debugPrint('Failed to schedule exact notification: $e. Falling back to inexact.');
      try {
        final p = plugin;
        if (p == null) return;

        final tzDateTime = tz.TZDateTime.from(reminder.dateTime, tz.local);
        final androidDetails = AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFFDC143C),
        );
        await p.zonedSchedule(
          id: reminder.id,
          title: '⏰ ${reminder.title}',
          body: reminder.description?.isNotEmpty == true
              ? reminder.description!
              : 'Reminder from Project Toji',
          scheduledDate: tzDateTime,
          notificationDetails: NotificationDetails(android: androidDetails),
          androidScheduleMode: AndroidScheduleMode.inexact,
        );
      } catch (err) {
        debugPrint('Failed fallback inexact notification: $err');
      }
    }
  }

  Future<void> cancelNotification(int id) async {
    if (_isTestEnv) return;
    try {
      final p = plugin;
      if (p == null) return;
      await p.cancel(id: id);
      debugPrint('Cancelled notification #$id');
    } catch (e) {
      debugPrint('Error cancelling notification: $e');
    }
  }
}
