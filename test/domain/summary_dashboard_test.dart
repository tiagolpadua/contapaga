import 'package:contapaga/core/time/clock.dart';
import 'package:contapaga/features/recurring_bills/domain/civil_date.dart';
import 'package:contapaga/features/recurring_bills/domain/competency_period.dart';
import 'package:contapaga/features/recurring_bills/domain/money.dart';
import 'package:contapaga/features/recurring_bills/domain/occurrence.dart';
import 'package:contapaga/features/recurring_bills/domain/recurrence_rule.dart';
import 'package:contapaga/features/recurring_bills/domain/recurring_series.dart';
import 'package:contapaga/features/recurring_bills/domain/settlement.dart';
import 'package:contapaga/features/recurring_bills/domain/use_cases/calculate_dashboard.dart';
import 'package:contapaga/features/recurring_bills/domain/use_cases/calculate_monthly_summary.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeClock implements Clock {
  const new(this._now);
  final DateTime _now;

  @override
  DateTime now() => _now;
}

void main() {
  group('Casos de Uso de Leitura (Painel e Resumo)', () {
    final relogio = FakeClock(DateTime(2026, 9, 16, 12)); // Hoje é 16/09/2026

    final incomeSeries = RecurringSeries(
      id: 's1',
      description: 'Salário',
      type: EntryType.income,
      autoDebit: false,
      baseAmount: const Money(500000), // 5000.00
      rule: RecurrenceRule(
        frequency: RecurrenceFrequency.monthly,
        startDate: const CivilDate(2026, 9, 5),
      ),
    );

    final expenseSeries = RecurringSeries(
      id: 's2',
      description: 'Aluguel',
      type: EntryType.expense,
      autoDebit: false,
      baseAmount: const Money(150000), // 1500.00
      rule: RecurrenceRule(
        frequency: RecurrenceFrequency.monthly,
        startDate: const CivilDate(2026, 9, 15),
      ),
    );

    final seriesMap = {'s1': incomeSeries, 's2': expenseSeries};

    test('calculateMonthlySummary', () {
      final o1 = Occurrence(
        seriesId: 's1',
        id: 'o1',
        dueDate: const CivilDate(2026, 9, 5),
        expectedAmount: const Money(500000),
        sequenceNumber: 1,
        settlement: Settlement(
          paidAmount: const Money(500000),
          paymentDate: const CivilDate(2026, 9, 5),
          recordedAt: relogio.now(),
        ),
      );

      final o2 = Occurrence(
        seriesId: 's2',
        id: 'o2',
        dueDate: const CivilDate(2026, 9, 15),
        expectedAmount: const Money(150000),
        sequenceNumber: 1,
        // não baixado
      );

      final resumo = calculateMonthlySummary(const CompetencyPeriod(2026, 9), [
        o1,
        o2,
      ], seriesMap);

      expect(resumo.expectedIncome, equals(const Money(500000)));
      expect(resumo.paidIncome, equals(const Money(500000)));
      expect(resumo.expectedExpenses, equals(const Money(150000)));
      expect(resumo.paidExpenses, equals(const Money(0)));
      expect(resumo.expectedBalance, equals(const Money(350000)));
      expect(resumo.settledBalance, equals(const Money(500000)));
    });

    test(
      'exemplo exato da fase 0: income open 3000, expense open 200, '
      'expense settled por 110 -> a receber 3000, a pagar 200, saldo 2690',
      () {
        final receitaAberta = Occurrence(
          seriesId: 's1',
          id: 'income-open',
          dueDate: const CivilDate(2026, 9, 5),
          expectedAmount: const Money(300000),
          sequenceNumber: 1,
        );
        final despesaAberta = Occurrence(
          seriesId: 's2',
          id: 'expense-open',
          dueDate: const CivilDate(2026, 9, 15),
          expectedAmount: const Money(20000),
          sequenceNumber: 1,
        );
        // Valor previsto (base) difere do valor pago para deixar explícito
        // que o saldo usa o valor efetivo, não o previsto, quando settled.
        final settledExpense = Occurrence(
          seriesId: 's2',
          id: 'expense-settled',
          dueDate: const CivilDate(2026, 9, 20),
          expectedAmount: const Money(9999),
          sequenceNumber: 2,
          settlement: Settlement(
            paidAmount: const Money(11000),
            paymentDate: const CivilDate(2026, 9, 20),
            recordedAt: relogio.now(),
          ),
        );

        final resumo = calculateMonthlySummary(
          const CompetencyPeriod(2026, 9),
          [receitaAberta, despesaAberta, settledExpense],
          seriesMap,
        );

        expect(resumo.expectedIncome, equals(const Money(300000)));
        expect(resumo.paidExpenses, equals(const Money(11000)));
        // saldo = income prevista (300000) - [expense open prevista
        // (20000) + expense settled paga (11000)] = 269000 (fase 0).
        expect(resumo.expectedBalance, equals(const Money(269000)));
      },
    );

    test('calculateDashboard', () {
      final oAtrasada = Occurrence(
        seriesId: 's2',
        id: '1',
        dueDate: const CivilDate(2026, 9, 10),
        expectedAmount: const Money(100),
        sequenceNumber: 1,
      );
      final oHoje = Occurrence(
        seriesId: 's2',
        id: '2',
        dueDate: const CivilDate(2026, 9, 16),
        expectedAmount: const Money(100),
        sequenceNumber: 2,
      );
      final oBreve = Occurrence(
        seriesId: 's2',
        id: '3',
        dueDate: const CivilDate(2026, 9, 20),
        expectedAmount: const Money(100),
        sequenceNumber: 3,
      );
      final oLonge = Occurrence(
        seriesId: 's2',
        id: '4',
        dueDate: const CivilDate(2026, 9, 25),
        expectedAmount: const Money(100),
        sequenceNumber: 4,
      );
      final settledOcc = Occurrence(
        seriesId: 's2',
        id: '5',
        dueDate: const CivilDate(2026, 9, 10),
        expectedAmount: const Money(100),
        sequenceNumber: 5,
        settlement: Settlement(
          paidAmount: const Money(100),
          paymentDate: const CivilDate(2026, 9, 10),
          recordedAt: relogio.now(),
        ),
      );

      final painel = calculateDashboard([
        oAtrasada,
        oHoje,
        oBreve,
        oLonge,
        settledOcc,
      ], clock: relogio);

      expect(painel.atrasadas.length, 1);
      expect(painel.atrasadas.first.id, '1');

      expect(painel.vencendoHoje.length, 1);
      expect(painel.vencendoHoje.first.id, '2');

      expect(painel.vencendoEmBreve.length, 1);
      expect(painel.vencendoEmBreve.first.id, '3'); // 25 > 16 + 7 (23)
    });
  });
}
