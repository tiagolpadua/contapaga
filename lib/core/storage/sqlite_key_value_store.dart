import 'package:contapaga/core/storage/key_value_store.dart';
import 'package:sqflite/sqflite.dart';

final class SqliteKeyValueStore implements KeyValueStore {
  new(this._database);
  final Database _database;

  @override
  Future<String?> read(String key) async {
    final rows = await _database.query(
      'preferences',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
    );
    return rows.isEmpty ? null : rows.single['value']! as String;
  }

  @override
  Future<void> write(String key, String value) async {
    await _database.insert('preferences', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> close() => _database.close();
}
