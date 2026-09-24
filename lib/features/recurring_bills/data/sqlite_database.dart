import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

Future<Database> openContaPagaDatabase(String fileName) async {
  return await openDatabase(
    path.join(await getDatabasesPath(), fileName),
    version: 2,
    onConfigure: (db) async {
      await db.execute('PRAGMA foreign_keys = ON');
    },
    onCreate: (db, version) async {
      await db.execute(
        'CREATE TABLE preferences (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
      );
      await _createV2Tables(db);
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        await _createV2Tables(db);
      }
    },
  );
}

Future<void> _createV2Tables(Database db) async {
  await db.execute('''
    CREATE TABLE series (
      id TEXT PRIMARY KEY,
      description TEXT NOT NULL,
      type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
      counterparty TEXT,
      auto_debit INTEGER NOT NULL CHECK (auto_debit IN (0, 1)),
      base_amount_cents INTEGER NOT NULL,
      rule_frequency TEXT NOT NULL CHECK (rule_frequency IN ('daily', 'weekly', 'monthly', 'yearly')),
      rule_interval INTEGER NOT NULL,
      rule_weekdays TEXT NOT NULL DEFAULT '',
      rule_start_date TEXT NOT NULL,
      rule_end_type TEXT NOT NULL CHECK (rule_end_type IN ('never', 'date', 'count')),
      rule_end_date TEXT,
      rule_end_count INTEGER,
      closed_at TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE series_revisions (
      series_id TEXT NOT NULL REFERENCES series(id) ON DELETE CASCADE,
      effective_date TEXT NOT NULL,
      base_amount_cents INTEGER NOT NULL,
      rule_frequency TEXT NOT NULL CHECK (rule_frequency IN ('daily', 'weekly', 'monthly', 'yearly')),
      rule_interval INTEGER NOT NULL,
      rule_weekdays TEXT NOT NULL DEFAULT '',
      rule_start_date TEXT NOT NULL,
      rule_end_type TEXT NOT NULL CHECK (rule_end_type IN ('never', 'date', 'count')),
      rule_end_date TEXT,
      rule_end_count INTEGER,
      PRIMARY KEY (series_id, effective_date)
    )
  ''');

  await db.execute('''
    CREATE TABLE occurrences (
      id TEXT PRIMARY KEY,
      series_id TEXT NOT NULL REFERENCES series(id) ON DELETE CASCADE,
      due_date TEXT NOT NULL,
      competency_period TEXT NOT NULL,
      sequence_number INTEGER NOT NULL,
      expected_amount_cents INTEGER NOT NULL,
      auto_debit INTEGER NOT NULL CHECK (auto_debit IN (0, 1)),
      settlement_paid_amount_cents INTEGER,
      settlement_payment_date TEXT,
      settlement_recorded_at TEXT
    )
  ''');

  await db.execute(
    'CREATE INDEX idx_occurrences_competency ON occurrences(competency_period)',
  );
  await db.execute(
    'CREATE INDEX idx_occurrences_series ON occurrences(series_id)',
  );
  await db.execute(
    'CREATE INDEX idx_occurrences_due_date ON occurrences(due_date)',
  );

  await db.execute('''
    CREATE TABLE materialized_series (
      series_id TEXT PRIMARY KEY REFERENCES series(id) ON DELETE CASCADE,
      materialized_through TEXT NOT NULL
    )
  ''');
}
