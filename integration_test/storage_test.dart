import 'package:contapaga/core/storage/sqlite_key_value_store.dart';
import 'package:contapaga/features/mes/data/local_month_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('SQLite preserves selection after closing and reopening', (
    _,
  ) async {
    const file = 'contapaga_integration_test.db';
    final location = path.join(await getDatabasesPath(), file);
    await deleteDatabase(location);
    final first = await SqliteKeyValueStore.open(file);
    await LocalMonthRepository(first).saveSelectedMonth(DateTime(2027));
    await first.close();
    final second = await SqliteKeyValueStore.open(file);
    try {
      expect(
        await LocalMonthRepository(second).loadSelectedMonth(),
        DateTime(2027),
      );
    } finally {
      await second.close();
      await deleteDatabase(location);
    }
  });
}
