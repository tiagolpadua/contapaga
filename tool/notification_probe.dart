// Dedicated development entry point. Never used by lib/main.dart or release CI.
import 'package:contapaga/core/notifications/android_notification_scheduler.dart';
import 'package:contapaga/core/notifications/notification_scheduler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kReleaseMode) throw StateError('Notification probe is debug-only');
  final plugin = FlutterLocalNotificationsPlugin();
  final scheduler = AndroidNotificationScheduler(plugin);
  await scheduler.initialize();
  await scheduler.cancel(900001);
  final enabled = await scheduler.isEnabled();
  if (enabled) {
    for (var day = 0; day < 30; day++) {
      await scheduler.schedule(
        ScheduledReminder(
          id: 901000 + day,
          at: DateTime.now().add(Duration(days: day + 1)),
          title: 'Diagnóstico da janela',
          body: 'Resumo sintético',
        ),
      );
    }
    final window = await plugin.pendingNotificationRequests();
    debugPrint('NOTIFICATION_WINDOW count=${window.length}');
    for (var day = 0; day < 30; day++) {
      await scheduler.cancel(901000 + day);
    }
  }
  final scheduled = await scheduler.schedule(
    ScheduledReminder(
      id: 900001,
      at: DateTime.now().add(const Duration(seconds: 20)),
      title: 'Conta Paga — diagnóstico',
      body: 'Agendamento local com app fechado.',
    ),
  );
  if (scheduled) {
    await scheduler.schedule(
      ScheduledReminder(
        id: 900001,
        at: DateTime.now().add(const Duration(seconds: 20)),
        title: 'Conta Paga — diagnóstico',
        body: 'Agendamento local com app fechado.',
      ),
    );
  }
  final pending = await plugin.pendingNotificationRequests();
  debugPrint(
    'NOTIFICATION_PROBE enabled=$enabled scheduled=$scheduled pending=${pending.length}',
  );
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Permissão: $enabled\nAgendado: $scheduled\nPendentes: ${pending.length}',
          ),
        ),
      ),
    ),
  );
}
