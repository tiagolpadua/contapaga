import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as zones;
import 'package:timezone/timezone.dart' as tz;

import 'notification_scheduler.dart';

final class AndroidNotificationScheduler implements NotificationScheduler {
  AndroidNotificationScheduler(this.plugin);
  final FlutterLocalNotificationsPlugin plugin;

  Future<void> initialize() async {
    zones.initializeTimeZones();
    await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
      ),
    );
  }

  AndroidFlutterLocalNotificationsPlugin get _android => plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()!;

  @override
  Future<bool> isEnabled() async =>
      await _android.areNotificationsEnabled() ?? false;
  @override
  Future<bool> requestPermission() async =>
      await _android.requestNotificationsPermission() ?? false;
  @override
  Future<bool> schedule(ScheduledReminder reminder) async {
    if (!await isEnabled()) return false;
    await plugin.zonedSchedule(
      id: reminder.id,
      title: reminder.title,
      body: reminder.body,
      scheduledDate: tz.TZDateTime.from(reminder.at, tz.UTC),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_summary',
          'Resumo de contas',
          channelDescription: 'Vencimentos e pendências das suas contas',
        ),
      ),
    );
    return true;
  }

  @override
  Future<void> cancel(int id) => plugin.cancel(id: id);
}
