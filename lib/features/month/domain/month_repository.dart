/// Remembers the selected month; never stores financial occurrences.
abstract interface class MonthRepository {
  Future<DateTime?> loadSelectedMonth();
  Future<void> saveSelectedMonth(DateTime month);
}
