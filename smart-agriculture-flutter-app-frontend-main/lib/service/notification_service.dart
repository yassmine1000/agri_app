import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init() async {
    await AwesomeNotifications().initialize(
      'resource://mipmap/launcher_icon',
      [
        NotificationChannel(
          channelKey: 'agriscan_reminders',
          channelName: 'AgriScan Reminders',
          channelDescription: 'Irrigation and fertilizer reminders',
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          ledColor: Colors.green,
          defaultColor: Colors.green,
        ),
      ],
      debug: false,
    );
  }

  Future<bool> requestPermissions() async {
    return await AwesomeNotifications().requestPermissionToSendNotifications(
      permissions: [
        NotificationPermission.Alert,
        NotificationPermission.Sound,
        NotificationPermission.Badge,
        NotificationPermission.Vibration,
        NotificationPermission.Light,
        NotificationPermission.FullScreenIntent,
        NotificationPermission.CriticalAlert,
        NotificationPermission.PreciseAlarms,
      ],
    );
  }

  Future<void> scheduleIrrigationReminder({
    required int planningId,
    required DateTime scheduledDate,
    required String cropName,
    required String lang,
  }) async {
    final title = lang == 'AR'
        ? '💧 تذكير بالري'
        : lang == 'FR'
            ? "💧 Rappel d'irrigation"
            : '💧 Irrigation Reminder';

    final body = lang == 'AR'
        ? 'حان وقت ري محصول $cropName'
        : lang == 'FR'
            ? "Il est temps d'irriguer votre culture de $cropName"
            : 'Time to irrigate your $cropName crop';

    await _scheduleNotification(
      id: planningId * 10 + 1,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
    );
  }

  Future<void> scheduleFertilizerReminder({
    required int planningId,
    required DateTime scheduledDate,
    required String cropName,
    required String lang,
  }) async {
    final title = lang == 'AR'
        ? '🌿 تذكير بالتسميد'
        : lang == 'FR'
            ? "🌿 Rappel d'engrais"
            : '🌿 Fertilizer Reminder';

    final body = lang == 'AR'
        ? 'حان وقت تسميد محصول $cropName'
        : lang == 'FR'
            ? "Il est temps de fertiliser votre culture de $cropName"
            : 'Time to fertilize your $cropName crop';

    await _scheduleNotification(
      id: planningId * 10 + 2,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
    );
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'agriscan_reminders',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.BigText,
        wakeUpScreen: true,
        fullScreenIntent: true,
        criticalAlert: true,
        category: NotificationCategory.Reminder,
      ),
      schedule: NotificationCalendar(
        year: scheduledDate.year,
        month: scheduledDate.month,
        day: scheduledDate.day,
        hour: scheduledDate.hour,
        minute: scheduledDate.minute,
        second: 0,
        millisecond: 0,
        repeats: false,
        preciseAlarm: true,
        allowWhileIdle: true,
      ),
    );
  }

  Future<void> cancelPlanningReminders(int planningId) async {
    await AwesomeNotifications().cancel(planningId * 10 + 1);
    await AwesomeNotifications().cancel(planningId * 10 + 2);
  }

  Future<void> cancelAll() async {
    await AwesomeNotifications().cancelAll();
  }

  Future<void> showTestNotification() async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 1,
      channelKey: 'agriscan_reminders',
      title: 'Test AgriScan 🌱',
      body: 'Les notifications fonctionnent!',
      notificationLayout: NotificationLayout.Default,
      wakeUpScreen: true,
      icon: 'resource://mipmap/launcher_icon',
    ),
  );
}
}