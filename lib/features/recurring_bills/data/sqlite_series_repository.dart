import 'package:contapaga/features/recurring_bills/domain/civil_date.dart';
import 'package:contapaga/features/recurring_bills/domain/money.dart';
import 'package:contapaga/features/recurring_bills/domain/recurrence_rule.dart';
import 'package:contapaga/features/recurring_bills/domain/recurring_series.dart';
import 'package:contapaga/features/recurring_bills/domain/repositories/series_repository.dart';
import 'package:contapaga/features/recurring_bills/domain/series_revision.dart';
import 'package:sqflite/sqflite.dart';

class SqliteSeriesRepository implements SeriesRepository {
  new(this._database);
  final Database _database;

  @override
  Future<List<RecurringSeries>> listActive() async {
    final rows = await _database.query('series', where: 'closed_at IS NULL');
    final results = <RecurringSeries>[];
    for (final row in rows) {
      results.add(await _mapRowToSeries(row));
    }
    return results;
  }

  @override
  Future<List<RecurringSeries>> listAll() async {
    final rows = await _database.query('series');
    final results = <RecurringSeries>[];
    for (final row in rows) {
      results.add(await _mapRowToSeries(row));
    }
    return results;
  }

  @override
  Future<RecurringSeries?> findById(String id) async {
    final rows = await _database.query(
      'series',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return await _mapRowToSeries(rows.first);
  }

  @override
  Future<void> save(RecurringSeries series) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _database.transaction((txn) async {
      final existing = await txn.query(
        'series',
        where: 'id = ?',
        whereArgs: [series.id],
      );
      final map = _seriesToMap(series);
      if (existing.isEmpty) {
        await txn.insert('series', {
          ...map,
          'created_at': now,
          'updated_at': now,
        });
      } else {
        await txn.update(
          'series',
          {...map, 'updated_at': now},
          where: 'id = ?',
          whereArgs: [series.id],
        );
      }

      for (final revision in series.revisions) {
        await txn.insert(
          'series_revisions',
          _revisionToMap(series.id, revision),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    });
  }

  @override
  Future<void> close(String id, CivilDate closedAt) async {
    await _database.update(
      'series',
      {
        'closed_at': closedAt.toString(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<RecurringSeries> _mapRowToSeries(Map<String, dynamic> row) async {
    final id = row['id'] as String;
    final revisionRows = await _database.query(
      'series_revisions',
      where: 'series_id = ?',
      whereArgs: [id],
      orderBy: 'effective_date ASC',
    );

    final revisions = revisionRows
        .map(
          (r) => SeriesRevision(
            effectiveDate: CivilDate.fromString(r['effective_date']! as String),
            baseAmount: Money(r['base_amount_cents']! as int),
            rule: _mapRowToRule(r),
          ),
        )
        .toList();

    return RecurringSeries(
      id: id,
      description: row['description'] as String,
      type: EntryType.values.firstWhere((e) => e.name == row['type'] as String),
      counterparty: row['counterparty'] as String?,
      autoDebit: (row['auto_debit'] as int) == 1,
      baseAmount: Money(row['base_amount_cents'] as int),
      rule: _mapRowToRule(row),
      revisions: revisions,
      closedAt: row['closed_at'] != null
          ? CivilDate.fromString(row['closed_at'] as String)
          : null,
    );
  }

  RecurrenceRule _mapRowToRule(Map<String, dynamic> row) {
    return RecurrenceRule(
      frequency: RecurrenceFrequency.values.firstWhere(
        (e) => e.name == row['rule_frequency'] as String,
      ),
      interval: row['rule_interval'] as int,
      weekdays: (row['rule_weekdays'] as String).isEmpty
          ? {}
          : (row['rule_weekdays'] as String).split(',').map(int.parse).toSet(),
      startDate: CivilDate.fromString(row['rule_start_date'] as String),
      endType: EndConditionType.values.firstWhere(
        (e) => e.name == row['rule_end_type'] as String,
      ),
      endDate: row['rule_end_date'] != null
          ? CivilDate.fromString(row['rule_end_date'] as String)
          : null,
      endCount: row['rule_end_count'] as int?,
    );
  }

  Map<String, dynamic> _seriesToMap(RecurringSeries series) {
    return {
      'id': series.id,
      'description': series.description,
      'type': series.type.name,
      'counterparty': series.counterparty,
      'auto_debit': series.autoDebit ? 1 : 0,
      'base_amount_cents': series.baseAmount.cents,
      'rule_frequency': series.rule.frequency.name,
      'rule_interval': series.rule.interval,
      'rule_weekdays': series.rule.weekdays.join(','),
      'rule_start_date': series.rule.startDate.toString(),
      'rule_end_type': series.rule.endType.name,
      'rule_end_date': series.rule.endDate?.toString(),
      'rule_end_count': series.rule.endCount,
      'closed_at': series.closedAt?.toString(),
    };
  }

  Map<String, dynamic> _revisionToMap(
    String seriesId,
    SeriesRevision revision,
  ) {
    return {
      'series_id': seriesId,
      'effective_date': revision.effectiveDate.toString(),
      'base_amount_cents': revision.baseAmount.cents,
      'rule_frequency': revision.rule.frequency.name,
      'rule_interval': revision.rule.interval,
      'rule_weekdays': revision.rule.weekdays.join(','),
      'rule_start_date': revision.rule.startDate.toString(),
      'rule_end_type': revision.rule.endType.name,
      'rule_end_date': revision.rule.endDate?.toString(),
      'rule_end_count': revision.rule.endCount,
    };
  }
}
