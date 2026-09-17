import 'package:contapaga/core/storage/key_value_store.dart';
import 'package:contapaga/features/mes/domain/month_repository.dart';

final class LocalMonthRepository implements MonthRepository {
  const new(this.store);
  final KeyValueStore store;
  static const _key = 'selected_month';

  @override
  Future<DateTime?> loadSelectedMonth() async {
    final value = await store.read(_key);
    if (value == null) return null;
    final parts = value.split('-');
    if (parts.length != 2) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    if (year == null ||
        year < 1 ||
        year > 9999 ||
        month == null ||
        month < 1 ||
        month > 12) {
      return null;
    }
    return DateTime(year, month);
  }

  @override
  Future<void> saveSelectedMonth(DateTime month) =>
      store.write(_key, '${month.year}-${month.month}');
}
