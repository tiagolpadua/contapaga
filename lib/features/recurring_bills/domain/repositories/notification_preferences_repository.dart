import 'package:contapaga/features/recurring_bills/domain/notification_preferences.dart';

abstract interface class NotificationPreferencesRepository {
  Future<NotificationPreferences> load();
  Future<void> save(NotificationPreferences preferences);
}
