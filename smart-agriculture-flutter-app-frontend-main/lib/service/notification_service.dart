import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId   = 'agriscan_reminders';
  static const _channelName = 'AgriScan Reminders';
  static const _channelDesc = 'Irrigation and fertilizer reminders';

  Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/launcher_icon');
    const ios     = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    // Create notification channel for Android
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDesc,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ));
  }

  Future<bool> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final ios     = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

    bool granted = false;
    if (android != null) {
      granted = await android.requestNotificationsPermission() ?? false;
      await android.requestExactAlarmsPermission();
    }
    if (ios != null) {
      granted = await ios.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    }
    return granted;
  }

  /// Schedule an irrigation reminder
  Future<void> scheduleIrrigationReminder({
    required int planningId,
    required DateTime scheduledDate,
    required String cropName,
    required String lang,
  }) async {
    final title = lang == 'AR'
        ? '💧 تذكير بالري'
        : lang == 'FR'
            ? '💧 Rappel d\'irrigation'
            : '💧 Irrigation Reminder';

    final body = lang == 'AR'
        ? 'حان وقت ري محصول $cropName'
        : lang == 'FR'
            ? 'Il est temps d\'irriguer votre culture de $cropName'
            : 'Time to irrigate your $cropName crop';

    await _scheduleNotification(
      id: planningId * 10 + 1, // unique id: planningId*10+1 for irrigation
      title: title,
      body: body,
      scheduledDate: scheduledDate,
    );
  }

  /// Schedule a fertilizer reminder
  Future<void> scheduleFertilizerReminder({
    required int planningId,
    required DateTime scheduledDate,
    required String cropName,
    required String lang,
  }) async {
    final title = lang == 'AR'
        ? '🌿 تذكير بالتسميد'
        : lang == 'FR'
            ? '🌿 Rappel d\'engrais'
            : '🌿 Fertilizer Reminder';

    final body = lang == 'AR'
        ? 'حان وقت تسميد محصول $cropName'
        : lang == 'FR'
            ? 'Il est temps de fertiliser votre culture de $cropName'
            : 'Time to fertilize your $cropName crop';

    await _scheduleNotification(
      id: planningId * 10 + 2, // unique id: planningId*10+2 for fertilizer
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
    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel reminders for a specific planning
  Future<void> cancelPlanningReminders(int planningId) async {
    await _plugin.cancel(planningId * 10 + 1);
    await _plugin.cancel(planningId * 10 + 2);
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}