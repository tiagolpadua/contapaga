import 'package:contapaga/core/storage/sqlite_key_value_store.dart';
import 'package:contapaga/features/month/data/local_month_repository.dart';
import 'package:contapaga/features/recurring_bills/data/sqlite_database.dart';
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

    final db1 = await openContaPagaDatabase(file);
    final first = SqliteKeyValueStore(db1);
    await LocalMonthRepository(first).saveSelectedMonth(DateTime(2027));
    await db1.close();

    final db2 = await openContaPagaDatabase(file);
    final second = SqliteKeyValueStore(db2);
    try {
      expect(
        await LocalMonthRepository(second).loadSelectedMonth(),
        DateTime(2027),
      );
    } finally {
      await db2.close();
      await deleteDatabase(location);
    }
  });
}
