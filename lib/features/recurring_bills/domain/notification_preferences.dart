class NotificationPreferences {
  new({
    required this.hour,
    required this.minute,
    this.enabled = true,
    this.leadDays = 3,
  }) {
    if (hour < 0 || hour > 23) {
      throw ArgumentError('Hora deve ser entre 0 e 23.');
    }
    if (minute < 0 || minute > 59) {
      throw ArgumentError('Minuto deve ser entre 0 e 59.');
    }
    if (leadDays < 1 || leadDays > 10) {
      throw ArgumentError('Antecedência deve ser entre 1 e 10 dias.');
    }
  }
  final int hour;
  final int minute;
  final bool enabled;
  final int leadDays;
}
