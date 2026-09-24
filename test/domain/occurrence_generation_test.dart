import 'package:contapaga/features/recurring_bills/domain/civil_date.dart';
import 'package:contapaga/features/recurring_bills/domain/money.dart';
import 'package:contapaga/features/recurring_bills/domain/occurrence_generation.dart';
import 'package:contapaga/features/recurring_bills/domain/recurrence_rule.dart';
import 'package:contapaga/features/recurring_bills/domain/recurring_series.dart';
import 'package:contapaga/features/recurring_bills/domain/series_revision.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('generateOccurrences', () {
    final baseSeries = RecurringSeries(
      id: 's1',
      description: 'Teste',
      type: EntryType.expense,
      autoDebit: false,
      baseAmount: const Money(1000),
      rule: RecurrenceRule(
        frequency: RecurrenceFrequency.monthly,
        startDate: const CivilDate(2026, 9, 10),
      ),
    );

    test('Virada dezembro->janeiro', () {
      final s = baseSeries.copyWithInternal(
        rule: RecurrenceRule(
          frequency: RecurrenceFrequency.monthly,
          startDate: const CivilDate(2026, 12, 31),
        ),
      );

      final ocs = generateOccurrences(
        s,
        desde: const CivilDate(2026, 12, 1),
        ate: const CivilDate(2027, 2, 1),
      );

      expect(ocs.length, 2);
      expect(ocs[0].dueDate, equals(const CivilDate(2026, 12, 31)));
      expect(ocs[1].dueDate, equals(const CivilDate(2027, 1, 31)));
    });

    test('Dia 31 em mês curto e preservação', () {
      final s = baseSeries.copyWithInternal(
        rule: RecurrenceRule(
          frequency: RecurrenceFrequency.monthly,
          startDate: const CivilDate(2026, 1, 31),
        ),
      );

      final ocs = generateOccurrences(
        s,
        desde: const CivilDate(2026, 1, 1),
        ate: const CivilDate(2026, 3, 31),
      );

      expect(ocs.length, 3);
      expect(ocs[0].dueDate, equals(const CivilDate(2026, 1, 31)));
      expect(
        ocs[1].dueDate,
        equals(const CivilDate(2026, 2, 28)),
      ); // 2026 não é bissexto
      expect(
        ocs[2].dueDate,
        equals(const CivilDate(2026, 3, 31)),
      ); // Preserva 31
    });

    test('Anual 29/02', () {
      final s = baseSeries.copyWithInternal(
        rule: RecurrenceRule(
          frequency: RecurrenceFrequency.yearly,
          startDate: const CivilDate(2024, 2, 29),
        ),
      );

      final ocs = generateOccurrences(
        s,
        desde: const CivilDate(2024, 1, 1),
        ate: const CivilDate(2028, 12, 31),
      );

      expect(ocs.length, 5);
      expect(ocs[0].dueDate, equals(const CivilDate(2024, 2, 29)));
      expect(ocs[1].dueDate, equals(const CivilDate(2025, 2, 28)));
      expect(ocs[2].dueDate, equals(const CivilDate(2026, 2, 28)));
      expect(ocs[3].dueDate, equals(const CivilDate(2027, 2, 28)));
      expect(ocs[4].dueDate, equals(const CivilDate(2028, 2, 29)));
    });

    test('Diária finita', () {
      final s = baseSeries.copyWithInternal(
        rule: RecurrenceRule(
          frequency: RecurrenceFrequency.daily,
          startDate: const CivilDate(2026, 9, 30),
          endType: EndConditionType.count,
          endCount: 3,
        ),
      );

      final ocs = generateOccurrences(
        s,
        desde: const CivilDate(2026, 9, 1),
        ate: const CivilDate(2026, 10, 31),
      );

      expect(ocs.length, 3);
      expect(ocs[0].dueDate, equals(const CivilDate(2026, 9, 30)));
      expect(ocs[1].dueDate, equals(const CivilDate(2026, 10, 1)));
      expect(ocs[2].dueDate, equals(const CivilDate(2026, 10, 2)));
    });

    test('Semanal com término por date', () {
      final s = baseSeries.copyWithInternal(
        rule: RecurrenceRule(
          frequency: RecurrenceFrequency.weekly,
          interval: 2,
          weekdays: {1, 3}, // seg, qua
          startDate: const CivilDate(2026, 9, 14), // é uma segunda
          endType: EndConditionType.date,
          endDate: const CivilDate(2026, 9, 28),
        ),
      );

      final ocs = generateOccurrences(
        s,
        desde: const CivilDate(2026, 9, 1),
        ate: const CivilDate(2026, 10, 31),
      );

      expect(ocs.length, 3);
      expect(ocs[0].dueDate, equals(const CivilDate(2026, 9, 14)));
      expect(ocs[1].dueDate, equals(const CivilDate(2026, 9, 16)));
      expect(ocs[2].dueDate, equals(const CivilDate(2026, 9, 28)));
      // 30/09 foi excluído
    });

    test('Semanal com count', () {
      final s = baseSeries.copyWithInternal(
        rule: RecurrenceRule(
          frequency: RecurrenceFrequency.weekly,
          interval: 2,
          weekdays: {1, 3},
          startDate: const CivilDate(2026, 9, 14),
          endType: EndConditionType.count,
          endCount: 4,
        ),
      );

      final ocs = generateOccurrences(
        s,
        desde: const CivilDate(2026, 9, 1),
        ate: const CivilDate(2026, 10, 31),
      );

      expect(ocs.length, 4);
      expect(ocs[0].dueDate, equals(const CivilDate(2026, 9, 14)));
      expect(ocs[1].dueDate, equals(const CivilDate(2026, 9, 16)));
      expect(ocs[2].dueDate, equals(const CivilDate(2026, 9, 28)));
      expect(ocs[3].dueDate, equals(const CivilDate(2026, 9, 30)));
    });

    test('Não gerar antes do início', () {
      final s = baseSeries.copyWithInternal(
        rule: RecurrenceRule(
          frequency: RecurrenceFrequency.monthly,
          startDate: const CivilDate(2026, 12, 1),
        ),
      );

      final ocs = generateOccurrences(
        s,
        desde: const CivilDate(2026, 9, 1),
        ate: const CivilDate(2026, 10, 31),
      );

      expect(ocs, isEmpty);
    });

    test('Idempotência', () {
      final s = baseSeries.copyWithInternal(
        rule: RecurrenceRule(
          frequency: RecurrenceFrequency.daily,
          startDate: const CivilDate(2026, 9, 1),
        ),
      );

      final ocs1 = generateOccurrences(
        s,
        desde: const CivilDate(2026, 9, 10),
        ate: const CivilDate(2026, 9, 15),
      );

      final ocs2 = generateOccurrences(
        s,
        desde: const CivilDate(2026, 9, 10),
        ate: const CivilDate(2026, 9, 15),
      );

      expect(ocs1.length, ocs2.length);
      for (var i = 0; i < ocs1.length; i++) {
        expect(ocs1[i].id, equals(ocs2[i].id));
        expect(ocs1[i].dueDate, equals(ocs2[i].dueDate));
      }
    });

    test('Revisão prospectiva', () {
      // Começa diária, muda para weekly na revisão
      final s = baseSeries.copyWithInternal(
        baseAmount: const Money(100),
        rule: RecurrenceRule(
          frequency: RecurrenceFrequency.daily,
          startDate: const CivilDate(2026, 9, 18),
        ),
        revisions: [
          SeriesRevision(
            effectiveDate: const CivilDate(2026, 9, 20),
            baseAmount: const Money(200),
            rule: RecurrenceRule(
              frequency: RecurrenceFrequency.weekly,
              weekdays: {1}, // segunda-feira (9/21/2026 é seg)
              startDate: const CivilDate(2026, 9, 21),
            ),
          ),
        ],
      );

      final ocs = generateOccurrences(
        s,
        desde: const CivilDate(2026, 9, 1),
        ate: const CivilDate(2026, 9, 30),
      );

      // Esperado:
      // chunk 0 (diario, 100): 18/09, 19/09. (20/09 não entra pois >= effectiveDate)
      // chunk 1 (weekly, 200, seg): 21/09, 28/09
      expect(ocs.length, 4);

      expect(ocs[0].dueDate, equals(const CivilDate(2026, 9, 18)));
      expect(ocs[0].expectedAmount, equals(const Money(100)));

      expect(ocs[1].dueDate, equals(const CivilDate(2026, 9, 19)));
      expect(ocs[1].expectedAmount, equals(const Money(100)));

      expect(ocs[2].dueDate, equals(const CivilDate(2026, 9, 21)));
      expect(ocs[2].expectedAmount, equals(const Money(200)));

      expect(ocs[3].dueDate, equals(const CivilDate(2026, 9, 28)));
      expect(ocs[3].expectedAmount, equals(const Money(200)));

      // Sequência continua globalmente?
      expect(ocs[0].sequenceNumber, 1);
      expect(ocs[1].sequenceNumber, 2);
      expect(ocs[2].sequenceNumber, 3);
      expect(ocs[3].sequenceNumber, 4);
    });

    test('closedAt interrompe a geracao, preservando occurrences '
        'anteriores dentro do interval pedido', () {
      final s = baseSeries.copyWithInternal(
        closedAt: const CivilDate(2026, 11, 10),
      );

      final ocs = generateOccurrences(
        s,
        desde: const CivilDate(2026, 9, 1),
        ate: const CivilDate(2027, 1, 1),
      );

      // Mensal dia 10: set, out, nov (encerra em 10/11 inclusive); sem dez/jan
      expect(ocs.length, 3);
      expect(ocs[0].dueDate, equals(const CivilDate(2026, 9, 10)));
      expect(ocs[1].dueDate, equals(const CivilDate(2026, 10, 10)));
      expect(ocs[2].dueDate, equals(const CivilDate(2026, 11, 10)));
    });

    test('closedAt anterior ao interval pedido gera lista vazia', () {
      final s = baseSeries.copyWithInternal(
        closedAt: const CivilDate(2026, 9, 10),
      );

      final ocs = generateOccurrences(
        s,
        desde: const CivilDate(2026, 10, 1),
        ate: const CivilDate(2026, 12, 1),
      );

      expect(ocs, isEmpty);
    });
  });
}
