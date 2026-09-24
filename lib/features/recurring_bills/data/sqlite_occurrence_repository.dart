import 'package:contapaga/features/recurring_bills/domain/civil_date.dart';
import 'package:contapaga/features/recurring_bills/domain/competency_period.dart';
import 'package:contapaga/features/recurring_bills/domain/money.dart';
import 'package:contapaga/features/recurring_bills/domain/occurrence.dart';
import 'package:contapaga/features/recurring_bills/domain/occurrence_generation.dart';
import 'package:contapaga/features/recurring_bills/domain/repositories/occurrence_repository.dart';
import 'package:contapaga/features/recurring_bills/domain/repositories/series_repository.dart';
import 'package:contapaga/features/recurring_bills/domain/settlement.dart';
import 'package:sqflite/sqflite.dart';

class SqliteOccurrenceRepository implements OccurrenceRepository {
  new(this._database, this._seriesRepository);
  final Database _database;
  final SeriesRepository _seriesRepository;

  @override
  Future<List<Occurrence>> listByCompetencyPeriod(
    CompetencyPeriod competencyPeriod,
  ) async {
    final rows = await _database.query(
      'occurrences',
      where: 'competency_period = ?',
      whereArgs: [competencyPeriod.toString()],
      orderBy: 'due_date ASC',
    );
    return rows.map(_mapRowToOccurrence).toList();
  }

  @override
  Future<List<Occurrence>> listBySeries(
    String seriesId, {
    CivilDate? from,
    CivilDate? through,
  }) async {
    var where = 'series_id = ?';
    final whereArgs = <Object?>[seriesId];
    if (from != null) {
      where += ' AND due_date >= ?';
      whereArgs.add(from.toString());
    }
    if (through != null) {
      where += ' AND due_date <= ?';
      whereArgs.add(through.toString());
    }
    final rows = await _database.query(
      'occurrences',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'due_date ASC',
    );
    return rows.map(_mapRowToOccurrence).toList();
  }

  @override
  Future<void> settleOccurrence(
    String occurrenceId,
    Settlement settlement,
  ) async {
    await _database.transaction((txn) async {
      final rows = await txn.query(
        'occurrences',
        where: 'id = ?',
        whereArgs: [occurrenceId],
      );
      if (rows.isEmpty) {
        throw StateError('Ocorrência não encontrada: $occurrenceId');
      }
      if (rows.first['settlement_paid_amount_cents'] != null) {
        throw StateError('Ocorrência já possui settlement: $occurrenceId');
      }

      await txn.update(
        'occurrences',
        {
          'settlement_paid_amount_cents': settlement.paidAmount.cents,
          'settlement_payment_date': settlement.paymentDate.toString(),
          'settlement_recorded_at': settlement.recordedAt
              .toUtc()
              .toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [occurrenceId],
      );
    });
  }

  @override
  Future<void> revertSettlement(String occurrenceId) async {
    await _database.transaction((txn) async {
      final rows = await txn.query(
        'occurrences',
        where: 'id = ?',
        whereArgs: [occurrenceId],
      );
      if (rows.isEmpty) {
        throw StateError('Ocorrência não encontrada: $occurrenceId');
      }
      if (rows.first['settlement_paid_amount_cents'] == null) {
        throw StateError('Ocorrência não possui settlement: $occurrenceId');
      }

      await txn.update(
        'occurrences',
        {
          'settlement_paid_amount_cents': null,
          'settlement_payment_date': null,
          'settlement_recorded_at': null,
        },
        where: 'id = ?',
        whereArgs: [occurrenceId],
      );
    });
  }

  @override
  Future<void> ensureMaterializedThrough(
    String seriesId,
    CivilDate through,
  ) async {
    // Lida fora da transação: _seriesRepository usa a conexão principal
    // (_database), não `txn` — chamá-la dentro de `transaction()` trava o
    // SQLite (a mesma conexão não pode abrir uma segunda operação enquanto a
    // transação está aberta). A série não muda durante esta operação.
    final series = await _seriesRepository.findById(seriesId);
    if (series == null) return;

    await _database.transaction((txn) async {
      final rows = await txn.query(
        'materialized_series',
        where: 'series_id = ?',
        whereArgs: [seriesId],
      );
      CivilDate? materializedThrough;
      if (rows.isNotEmpty) {
        materializedThrough = CivilDate.fromString(
          rows.first['materialized_through']! as String,
        );
      }

      if (materializedThrough != null &&
          materializedThrough.isSameOrAfter(through)) {
        return; // Já está materializado até essa data.
      }

      final from = materializedThrough != null
          ? materializedThrough.addDays(1)
          : series.rule.startDate;

      final newOccurrences = generateOccurrences(
        series,
        desde: from,
        ate: through,
      );

      for (final occurrence in newOccurrences) {
        await txn.insert(
          'occurrences',
          _occurrenceToMap(occurrence),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      final materializedMap = {
        'series_id': seriesId,
        'materialized_through': through.toString(),
      };

      if (rows.isEmpty) {
        await txn.insert('materialized_series', materializedMap);
      } else {
        await txn.update(
          'materialized_series',
          materializedMap,
          where: 'series_id = ?',
          whereArgs: [seriesId],
        );
      }
    });
  }

  @override
  Future<void> resyncFromRevision(
    String seriesId,
    CivilDate effectiveDate,
  ) async {
    // Lida fora da transação pelo mesmo motivo de ensureMaterializedThrough:
    // _seriesRepository usa a conexão principal, não `txn`.
    final series = await _seriesRepository.findById(seriesId);
    if (series == null) return;

    await _database.transaction((txn) async {
      final materializedRows = await txn.query(
        'materialized_series',
        where: 'series_id = ?',
        whereArgs: [seriesId],
      );
      if (materializedRows.isEmpty) {
        return; // Nada materializado ainda: a próxima leitura materializa direto com a nova regra.
      }
      final materializedThrough = CivilDate.fromString(
        materializedRows.first['materialized_through']! as String,
      );
      if (materializedThrough.isBefore(effectiveDate)) {
        return; // Nada materializado a partir da data de efeito.
      }

      await txn.delete(
        'occurrences',
        where: 'series_id = ? AND due_date >= ? AND settlement_paid_amount_cents IS NULL',
        whereArgs: [seriesId, effectiveDate.toString()],
      );

      final newOccurrences = generateOccurrences(
        series,
        desde: effectiveDate,
        ate: materializedThrough,
      );

      for (final occurrence in newOccurrences) {
        await txn.insert(
          'occurrences',
          _occurrenceToMap(occurrence),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Occurrence _mapRowToOccurrence(Map<String, dynamic> row) {
    Settlement? settlement;
    if (row['settlement_paid_amount_cents'] != null) {
      settlement = Settlement(
        paidAmount: Money(row['settlement_paid_amount_cents'] as int),
        paymentDate: CivilDate.fromString(
          row['settlement_payment_date'] as String,
        ),
        recordedAt: DateTime.parse(row['settlement_recorded_at'] as String)
            .toLocal(),
      );
    }
    return Occurrence(
      id: row['id'] as String,
      seriesId: row['series_id'] as String,
      dueDate: CivilDate.fromString(row['due_date'] as String),
      sequenceNumber: row['sequence_number'] as int,
      expectedAmount: Money(row['expected_amount_cents'] as int),
      autoDebit: (row['auto_debit'] as int) == 1,
      settlement: settlement,
    );
  }

  Map<String, dynamic> _occurrenceToMap(Occurrence occurrence) {
    return {
      'id': occurrence.id,
      'series_id': occurrence.seriesId,
      'due_date': occurrence.dueDate.toString(),
      'competency_period': occurrence.competencyPeriod.toString(),
      'sequence_number': occurrence.sequenceNumber,
      'expected_amount_cents': occurrence.expectedAmount.cents,
      'auto_debit': occurrence.autoDebit ? 1 : 0,
      'settlement_paid_amount_cents': occurrence.settlement?.paidAmount.cents,
      'settlement_payment_date': occurrence.settlement?.paymentDate.toString(),
      'settlement_recorded_at': occurrence.settlement?.recordedAt
          .toUtc()
          .toIso8601String(),
    };
  }
}
