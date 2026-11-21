import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/reminder_model.dart';

class ReminderNotificationService {
  static ReminderNotificationService? _instance;
  factory ReminderNotificationService() =>
      _instance ??= ReminderNotificationService._internal();
  ReminderNotificationService._internal();

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
  String _deviceTimeZone = 'UTC';
  String get deviceTimeZone => _deviceTimeZone;

  Future<bool> ensureInitialized() async {
    if (_isTestEnv || _isInitialized) return true;
    await init();
    return _isInitialized;
  }

  static const String channelId = 'project_toji_reminders';
  static const String channelName = 'Project Toji Reminders';
  static const String channelDescription = 'Project Toji reminder alerts';

  // Diagnostic logs
  final List<String> _diagnosticLogs = [];
  List<String> get diagnosticLogs => List.unmodifiable(_diagnosticLogs);

  void _log(String message) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    final entry = '[$timestamp] $message';
    _diagnosticLogs.insert(0, entry);
    if (_diagnosticLogs.length > 50) _diagnosticLogs.removeLast();
    debugPrint(entry);
  }

  final _notificationClickController = StreamController<String?>.broadcast();
  Stream<String?> get onNotificationClicked =>
      _notificationClickController.stream;

  bool get _isTestEnv {
    return WidgetsBinding.instance.runtimeType.toString().contains('Test');
  }

  Future<void> init() async {
    if (_isInitialized || _isTestEnv) return;

    try {
      tz.initializeTimeZones();

      // Configure exact local device timezone using flutter_timezone with safety timeout
      try {
        final timeZoneInfo = await FlutterTimezone.getLocalTimezone().timeout(
          const Duration(seconds: 2),
        );
        _deviceTimeZone = timeZoneInfo.identifier;
        tz.setLocalLocation(tz.getLocation(_deviceTimeZone));
        _log('Local timezone configured: $_deviceTimeZone');
      } catch (e) {
        _log(
          'Could not obtain native local timezone ($e), fallback: ${tz.local.name}',
        );
      }

      final p = plugin;
      if (p == null) return;

      // Use dedicated monochrome vector notification icon in drawable/
      const androidSettings = AndroidInitializationSettings(
        'ic_stat_notification',
      );
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
          _log('Notification clicked: payload=${response.payload}');
          _notificationClickController.add(response.payload);
        },
      );

      // Create high-importance Android Notification Channel
      const androidChannel = AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
        showBadge: true,
      );

      final androidPlatform = p
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlatform != null) {
        await androidPlatform.createNotificationChannel(androidChannel);
      }

      _isInitialized = true;
      _log(
        'ReminderNotificationService initialized successfully with channel $channelId',
      );
    } catch (e) {
      _log('ReminderNotificationService init error: $e');
    }
  }

  AndroidFlutterLocalNotificationsPlugin? get _androidPlatform {
    return plugin
        ?.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
  }

  /// Checks if notifications are currently enabled at the system level.
  Future<bool> areNotificationsEnabled() async {
    if (_isTestEnv) return true;
    try {
      final android = _androidPlatform;
      if (android != null) {
        final enabled = await android.areNotificationsEnabled();
        return enabled ?? true;
      }
      return true;
    } catch (e) {
      _log('Error checking notifications enabled: $e');
      return true;
    }
  }

  /// Checks whether exact alarms can be scheduled on Android 12+ (SCHEDULE_EXACT_ALARM).
  Future<bool> canScheduleExactAlarms() async {
    if (_isTestEnv) return true;
    try {
      final android = _androidPlatform;
      if (android != null) {
        final canSchedule = await android.canScheduleExactNotifications();
        return canSchedule ?? true;
      }
      return true;
    } catch (e) {
      _log('Error checking exact alarm permission: $e');
      return true;
    }
  }

  /// Requests notification permission (Android 13+ POST_NOTIFICATIONS, iOS).
  Future<bool> requestNotificationsPermission() async {
    if (_isTestEnv) return true;
    try {
      final android = _androidPlatform;
      if (android != null) {
        final granted = await android.requestNotificationsPermission();
        _log('requestNotificationsPermission result: $granted');
        return granted ?? false;
      }

      final ios = plugin
          ?.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (ios != null) {
        final granted = await ios.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (e) {
      _log('Error requesting notification permissions: $e');
    }
    return false;
  }

  /// Requests exact alarms permission from Android system settings.
  Future<bool> requestExactAlarmsPermission() async {
    if (_isTestEnv) return true;
    try {
      final android = _androidPlatform;
      if (android != null) {
        final granted = await android.requestExactAlarmsPermission();
        _log('requestExactAlarmsPermission opened/result: $granted');
        return granted ?? false;
      }
      return true;
    } catch (e) {
      _log('Error requesting exact alarm permission: $e');
      return false;
    }
  }

  /// Opens the application notification settings page on Android.
  Future<bool> openAppNotificationSettings() async {
    if (_isTestEnv) return true;
    try {
      final android = _androidPlatform;
      if (android != null) {
        final opened = await android.openAppNotificationSettings();
        return opened ?? false;
      }
      return false;
    } catch (e) {
      _log('Error opening notification settings: $e');
      return false;
    }
  }

  /// Alias for backward compatibility
  Future<bool> requestPermissions() => requestNotificationsPermission();

  /// Schedules exactly ONE notification for a reminder at its effective time:
  /// (reminder.advanceDateTime = reminder.dateTime - reminder.advanceMinutes).
  ///
  /// Advance selection options are mutually exclusive and determine this single time.
  /// Stable notification ID: (reminder.id & 0x7FFFFFFF).
  /// Any prior notification for this reminder is cancelled first.
  Future<bool> scheduleReminderNotifications(ReminderModel reminder) async {
    if (_isTestEnv) return true;

    final initialized = await ensureInitialized();
    if (!initialized) {
      _log('Cannot schedule reminder: notification service not initialized');
      return false;
    }

    // If disabled or completed, cancel any existing notifications and return
    if (!reminder.isNotificationEnabled || reminder.isCompleted) {
      await cancelReminderNotifications(reminder.id);
      _log(
        'Reminder #${reminder.id} notification disabled or completed. Cancelled existing notifications.',
      );
      return true;
    }

    final now = DateTime.now();
    // The single effective notification time based on the mutually exclusive advance interval
    final targetTime = reminder.advanceDateTime;

    // Do not schedule notifications for times in the past
    if (!targetTime.isAfter(now)) {
      _log(
        'Reminder target time $targetTime is in the past (now is $now). Skipping schedule.',
      );
      return false;
    }

    // Clear existing notifications for this reminder before scheduling new one
    await cancelReminderNotifications(reminder.id);

    final p = plugin;
    if (p == null) return false;

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_stat_notification',
      color: const Color(0xFFDC143C),
      enableVibration: true,
      playSound: true,
      showWhen: true,
      category: AndroidNotificationCategory.reminder,
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

    // Compose notification title and body
    final String cleanTitle = reminder.title.trim().isNotEmpty
        ? reminder.title.trim()
        : 'Reminder';

    final String body;
    if (reminder.advanceMinutes > 0) {
      if (reminder.description != null &&
          reminder.description!.trim().isNotEmpty) {
        body =
            'Starts in ${reminder.advanceMinutes}m • ${reminder.description!.trim()}';
      } else {
        body =
            'Your scheduled reminder starts in ${reminder.advanceMinutes} minutes.';
      }
    } else {
      if (reminder.description != null &&
          reminder.description!.trim().isNotEmpty) {
        body = reminder.description!.trim();
      } else {
        body = 'Your scheduled reminder is due now.';
      }
    }

    final stableId = reminder.id & 0x7FFFFFFF;
    final tzTarget = tz.TZDateTime.from(targetTime, tz.local);

    // Check exact alarm permission
    final canExact = await canScheduleExactAlarms();
    final scheduleMode = canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    final payload = reminder.noteId != null
        ? 'note:${reminder.noteId}'
        : 'reminder:${reminder.id}';

    try {
      await p.zonedSchedule(
        id: stableId,
        title: '⏰ $cleanTitle',
        body: body,
        scheduledDate: tzTarget,
        notificationDetails: notificationDetails,
        androidScheduleMode: scheduleMode,
        payload: payload,
      );
      _log(
        'Scheduled #$stableId for $tzTarget (${reminder.advanceMinutes}m advance, tz: ${tz.local.name}, exact: $canExact)',
      );
      return canExact;
    } catch (e) {
      _log('Error scheduling notification with $scheduleMode: $e');
      if (canExact) {
        try {
          await p.zonedSchedule(
            id: stableId,
            title: '⏰ $cleanTitle',
            body: body,
            scheduledDate: tzTarget,
            notificationDetails: notificationDetails,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            payload: payload,
          );
          _log('Fell back to inexact notification #$stableId for $tzTarget');
          return false;
        } catch (e2) {
          _log('Fallback inexact notification also failed: $e2');
        }
      }
      return false;
    }
  }

  /// Cancels all scheduled notifications associated with a reminder.
  /// Cancels the stable ID and any legacy multi-notification IDs.
  Future<void> cancelReminderNotifications(int id) async {
    if (_isTestEnv) return;
    try {
      final p = plugin;
      if (p == null) return;

      final stableId = id & 0x7FFFFFFF;
      final exactId = (id * 10) & 0x7FFFFFFF;
      final advanceId = (id * 10 + 1) & 0x7FFFFFFF;

      await p.cancel(id: stableId);
      await p.cancel(id: exactId);
      await p.cancel(id: advanceId);
      _log('Cancelled notification #$stableId');
    } catch (e) {
      _log('Error cancelling reminder notifications: $e');
    }
  }

  /// Sends a test notification after [delaySeconds] (default 10s) to verify device notification delivery.
  Future<bool> sendTestNotification({int delaySeconds = 10}) async {
    if (_isTestEnv) return true;
    final initialized = await ensureInitialized();
    if (!initialized) {
      _log(
        'Cannot send test notification: notification service not initialized',
      );
      return false;
    }

    final p = plugin;
    if (p == null) return false;

    final fireTime = DateTime.now().add(Duration(seconds: delaySeconds));
    final tzTarget = tz.TZDateTime.from(fireTime, tz.local);

    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_stat_notification',
      color: Color(0xFFDC143C),
      enableVibration: true,
      playSound: true,
      showWhen: true,
      category: AndroidNotificationCategory.reminder,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    final canExact = await canScheduleExactAlarms();
    final mode = canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    const testId = 999999;
    try {
      await p.zonedSchedule(
        id: testId,
        title: '⏰ Project Toji Test Alert',
        body: 'Alert confirmed! Notification delivery is working properly.',
        scheduledDate: tzTarget,
        notificationDetails: notificationDetails,
        androidScheduleMode: mode,
        payload: 'test_alert',
      );
      _log(
        'Test alert #$testId scheduled for $tzTarget (${delaySeconds}s, exact: $canExact)',
      );
      return true;
    } catch (e) {
      _log('Failed to schedule test alert: $e');
      return false;
    }
  }

  /// Returns list of all currently pending notifications from the plugin.
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (_isTestEnv) return [];
    try {
      final p = plugin;
      if (p == null) return [];
      return await p.pendingNotificationRequests();
    } catch (e) {
      _log('Error fetching pending notifications: $e');
      return [];
    }
  }
}
