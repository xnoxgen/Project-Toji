import '../models/reminder_model.dart';
import 'reminder_notification_service.dart';

// Backward compatibility alias
class NotificationService {
  static NotificationService? _instance;
  factory NotificationService() =>
      _instance ??= NotificationService._internal();
  NotificationService._internal();

  final ReminderNotificationService _service = ReminderNotificationService();

  Future<void> init() => _service.init();
  Future<bool> requestPermissions() => _service.requestPermissions();
  Future<void> scheduleReminderNotification(ReminderModel reminder) =>
      _service.scheduleReminderNotifications(reminder);
  Future<void> cancelNotification(int id) =>
      _service.cancelReminderNotifications(id);
}
