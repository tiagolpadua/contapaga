import 'dart:convert';

import 'package:contapaga/core/storage/key_value_store.dart';
import 'package:contapaga/features/recurring_bills/domain/notification_preferences.dart';
import 'package:contapaga/features/recurring_bills/domain/repositories/notification_preferences_repository.dart';

class SqliteNotificationPreferencesRepository
    implements NotificationPreferencesRepository {
  new(this._store);
  final KeyValueStore _store;

  static const _key = 'notification_preferences';

  @override
  Future<NotificationPreferences> load() async {
    final str = await _store.read(_key);
    if (str == null) return NotificationPreferences(hour: 9, minute: 0);

    try {
      final map = jsonDecode(str) as Map<String, dynamic>;
      return NotificationPreferences(
        hour: map['hour'] as int,
        minute: map['minute'] as int,
        enabled: map['enabled'] as bool,
        leadDays: map['leadDays'] as int,
      );
    } catch (_) {
      return NotificationPreferences(hour: 9, minute: 0);
    }
  }

  @override
  Future<void> save(NotificationPreferences preferences) async {
    final str = jsonEncode({
      'hour': preferences.hour,
      'minute': preferences.minute,
      'enabled': preferences.enabled,
      'leadDays': preferences.leadDays,
    });
    await _store.write(_key, str);
  }
}
