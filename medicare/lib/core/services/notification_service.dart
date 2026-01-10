import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/care_plan/domain/entities/care_plan_entity.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> requestPermissions() async {
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  Future<void> setNotificationEnabled(String planId, bool isEnabled) async {
    await _prefs?.setBool('notification_$planId', isEnabled);
  }

  bool isNotificationEnabled(String planId) {
    // Default to true (Opt-out)
    return _prefs?.getBool('notification_$planId') ?? true;
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancelForPlan(String planId) async {
    for (int i = 0; i < 20; i++) {
      final notificationId = planId.hashCode + i;
      await flutterLocalNotificationsPlugin.cancel(notificationId);
    }
  }

  Future<void> scheduleFromPlan(CarePlanEntity plan) async {
    if (!isNotificationEnabled(plan.id)) {
      return;
    }

    final frequencyRegex = RegExp(
      r'(\d+)\s*(?:em|/|-)\s*(\d+)\s*[hH]',
      caseSensitive: false,
    );
    final match = frequencyRegex.firstMatch(plan.description);

    if (match != null) {
      final intervalHours = int.parse(match.group(2)!);

      // Fast forward logic
      DateTime nextTime = plan.startDate;
      final now = DateTime.now();

      // If startDate is in the future, wait for it.
      // If in past, find the next occurrence in future.
      if (nextTime.isBefore(now)) {
        final diffHours = now.difference(nextTime).inHours;
        final intervalsPassed = (diffHours / intervalHours).ceil();
        nextTime = nextTime.add(
          Duration(hours: intervalsPassed * intervalHours),
        );
      }

      // Schedule for next 24h
      // Max 24 hours / intervalHours times
      int occurrencesToSchedule = (24 / intervalHours).ceil();

      for (int i = 0; i < occurrencesToSchedule; i++) {
        final scheduledDate = nextTime.add(Duration(hours: i * intervalHours));

        // Generate unique ID
        final notificationId = plan.id.hashCode + i;

        try {
          await flutterLocalNotificationsPlugin.zonedSchedule(
            notificationId,
            'Hora do Medicamento',
            'Lembre-se de tomar seu medicamento: ${plan.title}',
            tz.TZDateTime.from(scheduledDate, tz.local),
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'medication_channel',
                'Lembretes de Medicamentos',
                channelDescription: 'Canal para lembretes de medicamentos',
                importance: Importance.max,
                priority: Priority.high,
              ),
              iOS: DarwinNotificationDetails(),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
          debugPrint(
            'Scheduled notification for ${plan.title} at $scheduledDate (ID: $notificationId)',
          );
        } catch (e) {
          debugPrint('Error scheduling notification: $e');
        }
      }
    }
  }
}
