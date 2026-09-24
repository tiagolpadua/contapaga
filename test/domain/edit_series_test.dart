import 'package:contapaga/features/recurring_bills/domain/civil_date.dart';
import 'package:contapaga/features/recurring_bills/domain/money.dart';
import 'package:contapaga/features/recurring_bills/domain/occurrence.dart';
import 'package:contapaga/features/recurring_bills/domain/recurrence_rule.dart';
import 'package:contapaga/features/recurring_bills/domain/recurring_series.dart';
import 'package:contapaga/features/recurring_bills/domain/settlement.dart';
import 'package:contapaga/features/recurring_bills/domain/use_cases/edit_series.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('editar_serie', () {
    final initialSeries = RecurringSeries(
      id: 's1',
      description: 'Assinatura',
      type: EntryType.expense,
      autoDebit: false,
      baseAmount: const Money(5000), // 50.00
      rule: RecurrenceRule(
        frequency: RecurrenceFrequency.monthly,
        startDate: const CivilDate(2026, 1, 10),
      ),
    );

    test('addRevision', () {
      final revisedSeries = addRevision(
        initialSeries,
        effectiveDate: const CivilDate(2026, 6, 10),
        novoValorBase: const Money(6000), // aumentou pra 60
        novaRegra: RecurrenceRule(
          frequency: RecurrenceFrequency.monthly,
          startDate: const CivilDate(2026, 6, 15), // mudou date base também
        ),
        existingOccurrences: const [],
      );

      expect(revisedSeries.revisions.length, 1);
      final rev = revisedSeries.revisions.first;
      expect(rev.effectiveDate, equals(const CivilDate(2026, 6, 10)));
      expect(rev.baseAmount, equals(const Money(6000)));
      expect(rev.rule.frequency, RecurrenceFrequency.monthly);
      expect(rev.rule.startDate, equals(const CivilDate(2026, 6, 15)));
    });

    test('bloqueia date de efeito anterior à date inicial', () {
      expect(
        () => addRevision(
          initialSeries,
          effectiveDate: const CivilDate(2025, 1, 1),
          novoValorBase: const Money(6000),
          novaRegra: RecurrenceRule(
            frequency: RecurrenceFrequency.monthly,
            startDate: const CivilDate(2025, 1, 1),
          ),
          existingOccurrences: const [],
        ),
        throwsArgumentError,
      );
    });

    test('bloqueia date de efeito anterior à ultima revisão', () {
      final s1 = addRevision(
        initialSeries,
        effectiveDate: const CivilDate(2026, 6, 10),
        novoValorBase: const Money(6000),
        novaRegra: RecurrenceRule(
          frequency: RecurrenceFrequency.monthly,
          startDate: const CivilDate(2026, 6, 15),
        ),
        existingOccurrences: const [],
      );

      expect(
        () => addRevision(
          s1,
          effectiveDate: const CivilDate(2026, 5, 1),
          novoValorBase: const Money(7000),
          novaRegra: RecurrenceRule(
            frequency: RecurrenceFrequency.monthly,
            startDate: const CivilDate(2026, 5, 1),
          ),
          existingOccurrences: const [],
        ),
        throwsArgumentError,
      );
    });

    test(
      'bloqueia edição que eliminaria ocorrência já settled '
      '(exemplo da fase 0: efeito em 20/09 preserva settlement de 21/09)',
      () {
        // Série monthly dia 21; a settlement de 21/09 é preservada, mas a nova
        // rule (dia 25) faria a ocorrência de setembro deixar de existir
        // em 21/09 -> a settlement correspondente seria eliminada.
        final monthlySeriesDay21 = RecurringSeries(
          id: 's2',
          description: 'Internet',
          type: EntryType.expense,
          autoDebit: false,
          baseAmount: const Money(9000),
          rule: RecurrenceRule(
            frequency: RecurrenceFrequency.monthly,
            startDate: const CivilDate(2026, 1, 21),
          ),
        );

        final settledOccurrenceSep21 = Occurrence(
          seriesId: 's2',
          id: 's2#2026-09-21#9',
          dueDate: const CivilDate(2026, 9, 21),
          expectedAmount: const Money(9000),
          sequenceNumber: 9,
          settlement: Settlement(
            paidAmount: const Money(9000),
            paymentDate: const CivilDate(2026, 9, 21),
            recordedAt: DateTime(2026, 9, 21),
          ),
        );

        expect(
          () => addRevision(
            monthlySeriesDay21,
            effectiveDate: const CivilDate(2026, 9, 20),
            novoValorBase: const Money(9000),
            novaRegra: RecurrenceRule(
              frequency: RecurrenceFrequency.monthly,
              startDate: const CivilDate(2026, 9, 25),
            ),
            existingOccurrences: [settledOccurrenceSep21],
          ),
          throwsA(isA<EditBlockedException>()),
        );
      },
    );

    test('permite edição que preserva a ocorrência já settled '
        '(mesmo dia de vencimento, só o valor muda)', () {
      final monthlySeriesDay21 = RecurringSeries(
        id: 's2',
        description: 'Internet',
        type: EntryType.expense,
        autoDebit: false,
        baseAmount: const Money(9000),
        rule: RecurrenceRule(
          frequency: RecurrenceFrequency.monthly,
          startDate: const CivilDate(2026, 1, 21),
        ),
      );

      final settledOccurrenceSep21 = Occurrence(
        seriesId: 's2',
        id: 's2#2026-09-21#9',
        dueDate: const CivilDate(2026, 9, 21),
        expectedAmount: const Money(9000),
        sequenceNumber: 9,
        settlement: Settlement(
          paidAmount: const Money(9000),
          paymentDate: const CivilDate(2026, 9, 21),
          recordedAt: DateTime(2026, 9, 21),
        ),
      );

      final revisada = addRevision(
        monthlySeriesDay21,
        effectiveDate: const CivilDate(2026, 9, 20),
        novoValorBase: const Money(9500),
        novaRegra: RecurrenceRule(
          frequency: RecurrenceFrequency.monthly,
          startDate: const CivilDate(2026, 9, 21),
        ),
        existingOccurrences: [settledOccurrenceSep21],
      );

      expect(revisada.revisions.single.baseAmount, equals(const Money(9500)));
    });

    test('bloqueia redução de endCount abaixo da count já '
        'preservada a partir da date de efeito', () {
      final seriesWithEnd = RecurringSeries(
        id: 's3',
        description: 'Curso',
        type: EntryType.expense,
        autoDebit: false,
        baseAmount: const Money(20000),
        rule: RecurrenceRule(
          frequency: RecurrenceFrequency.monthly,
          startDate: const CivilDate(2026, 1, 10),
          endType: EndConditionType.count,
          endCount: 12,
        ),
      );

      // 3 ocorrências já preservadas a partir da date de efeito (abertas).
      final abertas = List.generate(
        3,
        (i) => Occurrence(
          seriesId: 's3',
          id: 's3#occ$i',
          dueDate: CivilDate(2026, 9 + i, 10),
          expectedAmount: const Money(20000),
          sequenceNumber: 9 + i,
        ),
      );

      expect(
        () => addRevision(
          seriesWithEnd,
          effectiveDate: const CivilDate(2026, 9, 1),
          novoValorBase: const Money(20000),
          novaRegra: RecurrenceRule(
            frequency: RecurrenceFrequency.monthly,
            startDate: const CivilDate(2026, 9, 10),
            endType: EndConditionType.count,
            endCount: 2, // menor que as 3 já preservadas
          ),
          existingOccurrences: abertas,
        ),
        throwsA(isA<EditBlockedException>()),
      );
    });
  });
}
