import 'package:contapaga/features/recurring_bills/domain/civil_date.dart';
import 'package:contapaga/features/recurring_bills/domain/competency_period.dart';
import 'package:contapaga/features/recurring_bills/domain/money.dart';
import 'package:contapaga/features/recurring_bills/domain/occurrence.dart';
import 'package:contapaga/features/recurring_bills/domain/recurrence_rule.dart';
import 'package:contapaga/features/recurring_bills/domain/recurring_series.dart';
import 'package:contapaga/features/recurring_bills/domain/settlement.dart';
import 'package:contapaga/features/recurring_bills/domain/use_cases/forecast_occurrence_value.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('forecastOccurrenceValue', () {
    final relogio = DateTime(2026, 9, 16);
    const setembro2026 = CompetencyPeriod(2026, 9);

    final series = RecurringSeries(
      id: 's1',
      description: 'Luz',
      type: EntryType.expense,
      autoDebit: false,
      baseAmount: const Money(10000), // 100.00
      rule: RecurrenceRule(
        frequency: RecurrenceFrequency.monthly,
        startDate: const CivilDate(2026, 9, 5),
      ),
    );

    Occurrence settledAt(int year, int month, int paidAmount) {
      return Occurrence(
        seriesId: 's1',
        id: '$year-$month',
        dueDate: CivilDate(year, month, 5),
        expectedAmount: const Money(10000),
        sequenceNumber: month,
        settlement: Settlement(
          paidAmount: Money(paidAmount),
          paymentDate: CivilDate(year, month, 5),
          recordedAt: relogio,
        ),
      );
    }

    test('sem historico retorna valor base', () {
      final prev = forecastOccurrenceValue(series, setembro2026, []);
      expect(prev, equals(const Money(10000)));
    });

    test('com uma ocorrencia na janela usa o valor pago dela', () {
      final o1 = settledAt(2026, 8, 12000);
      final prev = forecastOccurrenceValue(series, setembro2026, [o1]);
      expect(prev, equals(const Money(12000)));
    });

    test('exemplo da fase 0: abr 100, jun 120, ago 110 -> previsao set = 110,'
        ' meses sem settlement nao contam como zero', () {
      final historico = [
        settledAt(2026, 4, 10000),
        settledAt(2026, 6, 12000),
        settledAt(2026, 8, 11000),
      ];
      final prev = forecastOccurrenceValue(series, setembro2026, historico);
      expect(prev, equals(const Money(11000)));
    });

    test('ignora baixas fora da janela de 6 competencias anteriores, mesmo que'
        ' isso deixe poucos valores para a media', () {
      final historico = [
        settledAt(2025, 1, 1000), // fora da janela (bem anterior a mar/26)
        settledAt(2025, 2, 2000), // fora da janela
        settledAt(2026, 8, 11000), // unica dentro da janela mar-ago/2026
      ];
      final prev = forecastOccurrenceValue(series, setembro2026, historico);
      expect(prev, equals(const Money(11000)));
    });

    test(
      'ignora settlement da propria competencyPeriod alvo (month corrente)',
      () {
        final historico = [
          settledAt(2026, 8, 11000),
          settledAt(2026, 9, 99900), // competencyPeriod alvo, deve ser ignorada
        ];
        final prev = forecastOccurrenceValue(series, setembro2026, historico);
        expect(prev, equals(const Money(11000)));
      },
    );
  });
}
