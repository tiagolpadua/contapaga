import 'package:contapaga/core/storage/sqlite_key_value_store.dart';
import 'package:contapaga/features/recurring_bills/data/sqlite_backup_service.dart';
import 'package:contapaga/features/recurring_bills/data/sqlite_database.dart';
import 'package:contapaga/features/recurring_bills/data/sqlite_notification_preferences_repository.dart';
import 'package:contapaga/features/recurring_bills/data/sqlite_occurrence_repository.dart';
import 'package:contapaga/features/recurring_bills/data/sqlite_series_repository.dart';
import 'package:contapaga/features/recurring_bills/domain/civil_date.dart';
import 'package:contapaga/features/recurring_bills/domain/competency_period.dart';
import 'package:contapaga/features/recurring_bills/domain/money.dart';
import 'package:contapaga/features/recurring_bills/domain/notification_preferences.dart';
import 'package:contapaga/features/recurring_bills/domain/recurrence_rule.dart';
import 'package:contapaga/features/recurring_bills/domain/recurring_series.dart';
import 'package:contapaga/features/recurring_bills/domain/series_revision.dart';
import 'package:contapaga/features/recurring_bills/domain/settlement.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const file = 'contapaga_integration_test_recurring_bills.db';

  Future<String> databaseLocation() async =>
      path.join(await getDatabasesPath(), file);

  setUp(() async {
    await deleteDatabase(await databaseLocation());
  });

  tearDown(() async {
    await deleteDatabase(await databaseLocation());
  });

  testWidgets('onCreate cria o schema financeiro em uma instalação nova', (
    _,
  ) async {
    final db = await openContaPagaDatabase(file);
    try {
      final tables = await db.query(
        'sqlite_master',
        where: "type = 'table'",
        columns: ['name'],
      );
      final names = tables.map((r) => r['name']! as String).toSet();
      expect(
        names.containsAll({
          'preferences',
          'series',
          'series_revisions',
          'occurrences',
          'materialized_series',
        }),
        isTrue,
      );

      // Primeira instalação: nenhum dado fictício.
      final seriesRepository = SqliteSeriesRepository(db);
      expect(await seriesRepository.listAll(), isEmpty);
    } finally {
      await db.close();
    }
  });

  testWidgets(
    'onUpgrade de v1 para v2 cria as tabelas financeiras preservando preferences',
    (_) async {
      // Simula uma instalação existente no schema v1 (só preferences).
      final v1 = await openDatabase(
        await databaseLocation(),
        version: 1,
        onCreate: (db, version) => db.execute(
          'CREATE TABLE preferences (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
        ),
      );
      await v1.insert('preferences', {
        'key': 'selected_month',
        'value': '2027-1',
      });
      await v1.close();

      final upgraded = await openContaPagaDatabase(file);
      try {
        final store = SqliteKeyValueStore(upgraded);
        expect(await store.read('selected_month'), equals('2027-1'));

        final tables = await upgraded.query(
          'sqlite_master',
          where: "type = 'table'",
          columns: ['name'],
        );
        final names = tables.map((r) => r['name']! as String).toSet();
        expect(names.contains('series'), isTrue);
        expect(names.contains('occurrences'), isTrue);
      } finally {
        await upgraded.close();
      }
    },
  );

  testWidgets('SeriesRepository persiste série e revisões via upsert', (
    _,
  ) async {
    final db = await openContaPagaDatabase(file);
    try {
      final repository = SqliteSeriesRepository(db);
      final series = RecurringSeries(
        id: 's1',
        description: 'Internet',
        type: EntryType.expense,
        autoDebit: true,
        baseAmount: const Money(9000),
        rule: RecurrenceRule(
          frequency: RecurrenceFrequency.monthly,
          startDate: const CivilDate(2026, 1, 21),
        ),
      );

      await repository.save(series);
      final loaded = await repository.findById('s1');
      expect(loaded, isNotNull);
      expect(loaded!.description, equals('Internet'));
      expect(loaded.autoDebit, isTrue);
      expect(loaded.baseAmount, equals(const Money(9000)));
      expect(loaded.revisions, isEmpty);

      // Upsert: editar a descrição não duplica a linha.
      final renamed = RecurringSeries(
        id: 's1',
        description: 'Internet fibra',
        type: EntryType.expense,
        autoDebit: true,
        baseAmount: const Money(9000),
        rule: series.rule,
      );
      await repository.save(renamed);
      expect(await repository.listAll(), hasLength(1));
      expect(
        (await repository.findById('s1'))!.description,
        equals('Internet fibra'),
      );

      // Fechar (close) marca closed_at e sai de listActive.
      await repository.close('s1', const CivilDate(2026, 12, 31));
      expect(await repository.listActive(), isEmpty);
      expect(await repository.listAll(), hasLength(1));
    } finally {
      await db.close();
    }
  });

  testWidgets(
    'OccurrenceRepository.ensureMaterializedThrough é idempotente e incremental',
    (_) async {
      final db = await openContaPagaDatabase(file);
      try {
        final seriesRepository = SqliteSeriesRepository(db);
        final occurrenceRepository = SqliteOccurrenceRepository(
          db,
          seriesRepository,
        );

        final series = RecurringSeries(
          id: 's1',
          description: 'Assinatura',
          type: EntryType.expense,
          autoDebit: false,
          baseAmount: const Money(5000),
          rule: RecurrenceRule(
            frequency: RecurrenceFrequency.monthly,
            startDate: const CivilDate(2026, 1, 10),
          ),
        );
        await seriesRepository.save(series);

        await occurrenceRepository.ensureMaterializedThrough(
          's1',
          const CivilDate(2026, 6, 10),
        );
        final afterFirst = await occurrenceRepository.listByCompetencyPeriod(
          const CompetencyPeriod(2026, 3),
        );
        expect(afterFirst, hasLength(1));

        // Chamar de novo com a mesma data (ou anterior) não duplica nada.
        await occurrenceRepository.ensureMaterializedThrough(
          's1',
          const CivilDate(2026, 6, 10),
        );
        final afterRepeat = await occurrenceRepository.listBySeries('s1');
        expect(afterRepeat, hasLength(6)); // jan..jun

        // Avançar a janela gera só o trecho novo (idempotência incremental).
        await occurrenceRepository.ensureMaterializedThrough(
          's1',
          const CivilDate(2026, 8, 10),
        );
        final afterExtend = await occurrenceRepository.listBySeries('s1');
        expect(afterExtend, hasLength(8)); // jan..ago
      } finally {
        await db.close();
      }
    },
  );

  testWidgets(
    'settleOccurrence e revertSettlement persistem e bloqueiam duplicidade',
    (_) async {
      final db = await openContaPagaDatabase(file);
      try {
        final seriesRepository = SqliteSeriesRepository(db);
        final occurrenceRepository = SqliteOccurrenceRepository(
          db,
          seriesRepository,
        );

        final series = RecurringSeries(
          id: 's1',
          description: 'Aluguel',
          type: EntryType.expense,
          autoDebit: false,
          baseAmount: const Money(150000),
          rule: RecurrenceRule(
            frequency: RecurrenceFrequency.monthly,
            startDate: const CivilDate(2026, 1, 5),
          ),
        );
        await seriesRepository.save(series);
        await occurrenceRepository.ensureMaterializedThrough(
          's1',
          const CivilDate(2026, 1, 5),
        );
        final occurrence = (await occurrenceRepository.listBySeries('s1'))
            .single;

        final settlement = Settlement(
          paidAmount: const Money(150000),
          paymentDate: const CivilDate(2026, 1, 5),
          recordedAt: DateTime.utc(2026, 1, 5),
        );
        await occurrenceRepository.settleOccurrence(occurrence.id, settlement);

        final settled = (await occurrenceRepository.listBySeries('s1')).single;
        expect(settled.settlement, isNotNull);
        expect(settled.settlement!.paidAmount, equals(const Money(150000)));

        // Tentativa duplicada de baixa deve falhar, não silenciar.
        await expectLater(
          () =>
              occurrenceRepository.settleOccurrence(occurrence.id, settlement),
          throwsStateError,
        );

        await occurrenceRepository.revertSettlement(occurrence.id);
        final reverted = (await occurrenceRepository.listBySeries('s1')).single;
        expect(reverted.settlement, isNull);
      } finally {
        await db.close();
      }
    },
  );

  testWidgets(
    'resyncFromRevision descarta ocorrências futuras não settled e preserva as settled',
    (_) async {
      final db = await openContaPagaDatabase(file);
      try {
        final seriesRepository = SqliteSeriesRepository(db);
        final occurrenceRepository = SqliteOccurrenceRepository(
          db,
          seriesRepository,
        );

        final series = RecurringSeries(
          id: 's1',
          description: 'Internet',
          type: EntryType.expense,
          autoDebit: false,
          baseAmount: const Money(9000),
          rule: RecurrenceRule(
            frequency: RecurrenceFrequency.monthly,
            startDate: const CivilDate(2026, 1, 21),
          ),
        );
        await seriesRepository.save(series);
        await occurrenceRepository.ensureMaterializedThrough(
          's1',
          const CivilDate(2026, 12, 21),
        );

        // Settle a ocorrência de setembro antes de editar a série.
        final september = (await occurrenceRepository.listByCompetencyPeriod(
          const CompetencyPeriod(2026, 9),
        )).single;
        await occurrenceRepository.settleOccurrence(
          september.id,
          Settlement(
            paidAmount: const Money(9000),
            paymentDate: const CivilDate(2026, 9, 21),
            recordedAt: DateTime.utc(2026, 9, 21),
          ),
        );

        // Nova revisão a partir de outubro, mudando o dia de vencimento.
        final revisedSeries = RecurringSeries(
          id: 's1',
          description: 'Internet',
          type: EntryType.expense,
          autoDebit: false,
          baseAmount: const Money(9500),
          rule: series.rule,
          revisions: [
            SeriesRevision(
              effectiveDate: const CivilDate(2026, 10, 1),
              rule: RecurrenceRule(
                frequency: RecurrenceFrequency.monthly,
                startDate: const CivilDate(2026, 10, 25),
              ),
              baseAmount: const Money(9500),
            ),
          ],
        );
        await seriesRepository.save(revisedSeries);
        await occurrenceRepository.resyncFromRevision(
          's1',
          const CivilDate(2026, 10, 1),
        );

        final all = await occurrenceRepository.listBySeries('s1');
        // Setembro (settled) preservada.
        expect(
          all.any(
            (o) =>
                o.dueDate == const CivilDate(2026, 9, 21) &&
                o.settlement != null,
          ),
          isTrue,
        );
        // Outubro em diante agora vence dia 25, não mais dia 21.
        expect(
          all.any((o) => o.dueDate.day == 21 && o.dueDate.month >= 10),
          isFalse,
        );
        expect(all.any((o) => o.dueDate.day == 25), isTrue);
      } finally {
        await db.close();
      }
    },
  );

  testWidgets('SqliteBackupService exporta e reimporta os dados financeiros', (
    _,
  ) async {
    final db = await openContaPagaDatabase(file);
    try {
      final seriesRepository = SqliteSeriesRepository(db);
      final occurrenceRepository = SqliteOccurrenceRepository(
        db,
        seriesRepository,
      );
      final store = SqliteKeyValueStore(db);
      final preferencesRepository = SqliteNotificationPreferencesRepository(
        store,
      );
      final backupService = SqliteBackupService(
        db,
        seriesRepository,
        occurrenceRepository,
        preferencesRepository,
      );

      final series = RecurringSeries(
        id: 's1',
        description: 'Salário',
        type: EntryType.income,
        autoDebit: false,
        baseAmount: const Money(300000),
        rule: RecurrenceRule(
          frequency: RecurrenceFrequency.monthly,
          startDate: const CivilDate(2026, 1, 5),
        ),
      );
      await seriesRepository.save(series);
      await occurrenceRepository.ensureMaterializedThrough(
        's1',
        const CivilDate(2026, 3, 5),
      );
      await preferencesRepository.save(
        NotificationPreferences(hour: 8, minute: 30, leadDays: 5),
      );

      final backupJson = await backupService.export();

      final preview = backupService.preview(backupJson);
      expect(preview.seriesCount, equals(1));
      expect(preview.occurrenceCount, equals(3));

      // Simula perda de dados e restauração a partir do backup.
      await db.delete('occurrences');
      await db.delete('series_revisions');
      await db.delete('series');
      await db.delete('materialized_series');

      await backupService.import(backupJson);

      final restoredSeries = await seriesRepository.listAll();
      expect(restoredSeries, hasLength(1));
      expect(restoredSeries.single.description, equals('Salário'));

      final restoredOccurrences = await occurrenceRepository.listBySeries('s1');
      expect(restoredOccurrences, hasLength(3));

      final restoredPrefs = await preferencesRepository.load();
      expect(restoredPrefs.hour, equals(8));
      expect(restoredPrefs.leadDays, equals(5));
    } finally {
      await db.close();
    }
  });

  testWidgets(
    'SqliteBackupService.import rejeita versão desconhecida sem tocar no banco',
    (_) async {
      final db = await openContaPagaDatabase(file);
      try {
        final seriesRepository = SqliteSeriesRepository(db);
        final occurrenceRepository = SqliteOccurrenceRepository(
          db,
          seriesRepository,
        );
        final store = SqliteKeyValueStore(db);
        final preferencesRepository = SqliteNotificationPreferencesRepository(
          store,
        );
        final backupService = SqliteBackupService(
          db,
          seriesRepository,
          occurrenceRepository,
          preferencesRepository,
        );

        final series = RecurringSeries(
          id: 's1',
          description: 'Salário',
          type: EntryType.income,
          autoDebit: false,
          baseAmount: const Money(300000),
          rule: RecurrenceRule(
            frequency: RecurrenceFrequency.monthly,
            startDate: const CivilDate(2026, 1, 5),
          ),
        );
        await seriesRepository.save(series);

        await expectLater(
          () => backupService.import('{"backupVersion": 999}'),
          throwsA(isA<InvalidBackupException>()),
        );
        await expectLater(
          () => backupService.import('not even json'),
          throwsA(isA<InvalidBackupException>()),
        );

        // Nada foi tocado: a série original continua lá.
        expect(await seriesRepository.listAll(), hasLength(1));
      } finally {
        await db.close();
      }
    },
  );
}
