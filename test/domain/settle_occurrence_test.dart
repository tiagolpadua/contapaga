import 'package:contapaga/core/time/clock.dart';
import 'package:contapaga/features/recurring_bills/domain/civil_date.dart';
import 'package:contapaga/features/recurring_bills/domain/competency_period.dart';
import 'package:contapaga/features/recurring_bills/domain/money.dart';
import 'package:contapaga/features/recurring_bills/domain/occurrence.dart';
import 'package:contapaga/features/recurring_bills/domain/recurrence_rule.dart';
import 'package:contapaga/features/recurring_bills/domain/recurring_series.dart';
import 'package:contapaga/features/recurring_bills/domain/use_cases/calculate_monthly_summary.dart';
import 'package:contapaga/features/recurring_bills/domain/use_cases/settle_occurrence.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeClock implements Clock {
  const new(this._now);
  final DateTime _now;

  @override
  DateTime now() => _now;
}

void main() {
  group('dar_baixa e reverter_baixa', () {
    final clock = FakeClock(DateTime(2026, 9, 16, 12));

    final o = Occurrence(
      seriesId: 's1',
      id: 's1#1',
      dueDate: const CivilDate(2026, 9, 10),
      expectedAmount: const Money(100),
      sequenceNumber: 1,
    );

    test('settlement com sucesso', () {
      final settled = settleOccurrence(
        o,
        paidAmount: const Money(120),
        paymentDate: const CivilDate(2026, 9, 11),
        clock: clock,
      );

      expect(settled.settlement, isNotNull);
      expect(settled.settlement!.paidAmount, equals(const Money(120)));
      expect(
        settled.settlement!.paymentDate,
        equals(const CivilDate(2026, 9, 11)),
      );
      expect(settled.status(clock), equals(OccurrenceStatus.settled));
      // Verifica que o ID original foi mantido
      expect(settled.id, equals(o.id));
    });

    test('reverter settlement', () {
      final settled = settleOccurrence(
        o,
        paidAmount: const Money(120),
        paymentDate: const CivilDate(2026, 9, 11),
        clock: clock,
      );

      final revertida = revertSettlement(settled);
      expect(revertida.settlement, isNull);
      expect(
        revertida.status(clock),
        equals(OccurrenceStatus.overdue),
      ); // 10/09 < 16/09
      expect(revertida.id, equals(o.id));
    });

    test('bloqueia settlement em ocorrencia já settled', () {
      final settled = settleOccurrence(
        o,
        paidAmount: const Money(120),
        paymentDate: const CivilDate(2026, 9, 11),
        clock: clock,
      );

      expect(
        () => settleOccurrence(
          settled,
          paidAmount: const Money(10),
          paymentDate: const CivilDate(2026, 9, 11),
          clock: clock,
        ),
        throwsStateError,
      );
    });

    test('bloqueia date de pagamento no futuro', () {
      expect(
        () => settleOccurrence(
          o,
          paidAmount: const Money(10),
          paymentDate: const CivilDate(2026, 9, 17),
          clock: clock,
        ),
        throwsArgumentError,
      );
    });

    test('bloqueia valor pago zero ou negativo', () {
      expect(
        () => settleOccurrence(
          o,
          paidAmount: const Money(0),
          paymentDate: const CivilDate(2026, 9, 16),
          clock: clock,
        ),
        throwsArgumentError,
      );
      expect(
        () => settleOccurrence(
          o,
          paidAmount: const Money(-10),
          paymentDate: const CivilDate(2026, 9, 16),
          clock: clock,
        ),
        throwsArgumentError,
      );
    });

    test('reverter ocorrencia não settled falha', () {
      expect(() => revertSettlement(o), throwsStateError);
    });

    test(
      'expectedBalance usa o valor efetivamente pago (nao o previsto) para '
      'occurrences baixadas, e reversao restaura o estado anterior (fase 0)',
      () {
        const competencyPeriod = CompetencyPeriod(2026, 9);
        final incomeSeries = RecurringSeries(
          id: 'income',
          description: 'Salário',
          type: EntryType.income,
          autoDebit: false,
          baseAmount: const Money(300000),
          rule: RecurrenceRule(
            frequency: RecurrenceFrequency.monthly,
            startDate: const CivilDate(2026, 9, 5),
          ),
        );
        final expenseSeries = RecurringSeries(
          id: 'expense',
          description: 'Aluguel',
          type: EntryType.expense,
          autoDebit: false,
          baseAmount: const Money(20000),
          rule: RecurrenceRule(
            frequency: RecurrenceFrequency.monthly,
            startDate: const CivilDate(2026, 9, 10),
          ),
        );
        final seriesById = {'income': incomeSeries, 'expense': expenseSeries};

        final receitaAberta = Occurrence(
          seriesId: 'income',
          id: 'income#1',
          dueDate: const CivilDate(2026, 9, 5),
          expectedAmount: const Money(300000),
          sequenceNumber: 1,
        );
        final despesaAberta = Occurrence(
          seriesId: 'expense',
          id: 'expense#1',
          dueDate: const CivilDate(2026, 9, 10),
          expectedAmount: const Money(20000),
          sequenceNumber: 1,
        );

        // Estado inicial: income 3000, expense open 200 -> saldo 2800.
        final resumoInicial = calculateMonthlySummary(competencyPeriod, [
          receitaAberta,
          despesaAberta,
        ], seriesById);
        expect(resumoInicial.expectedExpenses, equals(const Money(20000)));
        expect(resumoInicial.expectedBalance, equals(const Money(280000)));

        // Settlement a expense por R$220 -> saldo previsto passa a usar o valor
        // efetivamente pago (220), não mais o previsto (200): 3000-220=2780.
        final settledExpense = settleOccurrence(
          despesaAberta,
          paidAmount: const Money(22000),
          paymentDate: const CivilDate(2026, 9, 10),
          clock: clock,
        );
        final summaryAfterSettlement = calculateMonthlySummary(
          competencyPeriod,
          [receitaAberta, settledExpense],
          seriesById,
        );
        expect(
          summaryAfterSettlement.expectedExpenses,
          equals(const Money(20000)),
        );
        expect(summaryAfterSettlement.paidExpenses, equals(const Money(22000)));
        expect(
          summaryAfterSettlement.expectedBalance,
          equals(const Money(278000)),
        );

        // Confirma a reversão -> volta ao estado inicial (saldo 2800),
        // reabrindo exatamente a mesma ocorrência.
        final revertedExpense = revertSettlement(settledExpense);
        expect(revertedExpense.id, equals(despesaAberta.id));
        expect(revertedExpense.settlement, isNull);
        final resumoAposReversao = calculateMonthlySummary(competencyPeriod, [
          receitaAberta,
          revertedExpense,
        ], seriesById);
        expect(resumoAposReversao.expectedExpenses, equals(const Money(20000)));
        expect(resumoAposReversao.paidExpenses, equals(const Money(0)));
        expect(resumoAposReversao.expectedBalance, equals(const Money(280000)));
      },
    );
  });
}
