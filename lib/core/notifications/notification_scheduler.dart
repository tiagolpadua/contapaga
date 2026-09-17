class ScheduledReminder {
  const new({
    required this.id,
    required this.at,
    required this.title,
    required this.body,
  });
  final int id;

  /// Instant of delivery; the domain converts civil date + device timezone.
  final DateTime at;
  final String title;
  final String body;
}

abstract interface class NotificationScheduler {
  Future<bool> isEnabled();
  Future<bool> requestPermission();
  Future<bool> schedule(ScheduledReminder reminder);
  Future<void> cancel(int id);
}
