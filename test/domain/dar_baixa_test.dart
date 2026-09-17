import 'package:contapaga/core/time/clock.dart';
import 'package:contapaga/features/recorrencias/domain/casos_uso/calcular_resumo_mensal.dart';
import 'package:contapaga/features/recorrencias/domain/casos_uso/dar_baixa.dart';
import 'package:contapaga/features/recorrencias/domain/civil_date.dart';
import 'package:contapaga/features/recorrencias/domain/competencia.dart';
import 'package:contapaga/features/recorrencias/domain/money.dart';
import 'package:contapaga/features/recorrencias/domain/ocorrencia.dart';
import 'package:contapaga/features/recorrencias/domain/regra_recorrencia.dart';
import 'package:contapaga/features/recorrencias/domain/serie_recorrente.dart';
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

    final o = Ocorrencia(
      serieId: 's1',
      id: 's1#1',
      dataVencimento: const CivilDate(2026, 9, 10),
      valorPrevisto: const Money(100),
      sequencia: 1,
    );

    test('baixa com sucesso', () {
      final baixada = darBaixa(
        o,
        valorPago: const Money(120),
        dataPagamento: const CivilDate(2026, 9, 11),
        clock: clock,
      );

      expect(baixada.baixa, isNotNull);
      expect(baixada.baixa!.valorPago, equals(const Money(120)));
      expect(
        baixada.baixa!.dataPagamento,
        equals(const CivilDate(2026, 9, 11)),
      );
      expect(baixada.status(clock), equals(StatusOcorrencia.baixada));
      // Verifica que o ID original foi mantido
      expect(baixada.id, equals(o.id));
    });

    test('reverter baixa', () {
      final baixada = darBaixa(
        o,
        valorPago: const Money(120),
        dataPagamento: const CivilDate(2026, 9, 11),
        clock: clock,
      );

      final revertida = reverterBaixa(baixada);
      expect(revertida.baixa, isNull);
      expect(
        revertida.status(clock),
        equals(StatusOcorrencia.atrasada),
      ); // 10/09 < 16/09
      expect(revertida.id, equals(o.id));
    });

    test('bloqueia baixa em ocorrencia já baixada', () {
      final baixada = darBaixa(
        o,
        valorPago: const Money(120),
        dataPagamento: const CivilDate(2026, 9, 11),
        clock: clock,
      );

      expect(
        () => darBaixa(
          baixada,
          valorPago: const Money(10),
          dataPagamento: const CivilDate(2026, 9, 11),
          clock: clock,
        ),
        throwsStateError,
      );
    });

    test('bloqueia data de pagamento no futuro', () {
      expect(
        () => darBaixa(
          o,
          valorPago: const Money(10),
          dataPagamento: const CivilDate(2026, 9, 17),
          clock: clock,
        ),
        throwsArgumentError,
      );
    });

    test('bloqueia valor pago zero ou negativo', () {
      expect(
        () => darBaixa(
          o,
          valorPago: const Money(0),
          dataPagamento: const CivilDate(2026, 9, 16),
          clock: clock,
        ),
        throwsArgumentError,
      );
      expect(
        () => darBaixa(
          o,
          valorPago: const Money(-10),
          dataPagamento: const CivilDate(2026, 9, 16),
          clock: clock,
        ),
        throwsArgumentError,
      );
    });

    test('reverter ocorrencia não baixada falha', () {
      expect(() => reverterBaixa(o), throwsStateError);
    });

    test(
      'saldoPrevisto usa o valor efetivamente pago (nao o previsto) para '
      'ocorrencias baixadas, e reversao restaura o estado anterior (fase 0)',
      () {
        const competencia = Competencia(2026, 9);
        final serieReceita = SerieRecorrente(
          id: 'receita',
          descricao: 'Salário',
          tipo: TipoLancamento.receita,
          debitoAutomatico: false,
          valorBase: const Money(300000),
          regra: RegraRecorrencia(
            frequencia: Frequencia.mensal,
            dataInicial: const CivilDate(2026, 9, 5),
          ),
        );
        final serieDespesa = SerieRecorrente(
          id: 'despesa',
          descricao: 'Aluguel',
          tipo: TipoLancamento.despesa,
          debitoAutomatico: false,
          valorBase: const Money(20000),
          regra: RegraRecorrencia(
            frequencia: Frequencia.mensal,
            dataInicial: const CivilDate(2026, 9, 10),
          ),
        );
        final seriesPorId = {'receita': serieReceita, 'despesa': serieDespesa};

        final receitaAberta = Ocorrencia(
          serieId: 'receita',
          id: 'receita#1',
          dataVencimento: const CivilDate(2026, 9, 5),
          valorPrevisto: const Money(300000),
          sequencia: 1,
        );
        final despesaAberta = Ocorrencia(
          serieId: 'despesa',
          id: 'despesa#1',
          dataVencimento: const CivilDate(2026, 9, 10),
          valorPrevisto: const Money(20000),
          sequencia: 1,
        );

        // Estado inicial: receita 3000, despesa aberta 200 -> saldo 2800.
        final resumoInicial = calcularResumoMensal(competencia, [
          receitaAberta,
          despesaAberta,
        ], seriesPorId);
        expect(resumoInicial.despesasPrevistas, equals(const Money(20000)));
        expect(resumoInicial.saldoPrevisto, equals(const Money(280000)));

        // Baixa a despesa por R$220 -> saldo previsto passa a usar o valor
        // efetivamente pago (220), não mais o previsto (200): 3000-220=2780.
        final despesaBaixada = darBaixa(
          despesaAberta,
          valorPago: const Money(22000),
          dataPagamento: const CivilDate(2026, 9, 10),
          clock: clock,
        );
        final resumoAposBaixa = calcularResumoMensal(competencia, [
          receitaAberta,
          despesaBaixada,
        ], seriesPorId);
        expect(resumoAposBaixa.despesasPrevistas, equals(const Money(20000)));
        expect(resumoAposBaixa.despesasPagas, equals(const Money(22000)));
        expect(resumoAposBaixa.saldoPrevisto, equals(const Money(278000)));

        // Confirma a reversão -> volta ao estado inicial (saldo 2800),
        // reabrindo exatamente a mesma ocorrência.
        final despesaRevertida = reverterBaixa(despesaBaixada);
        expect(despesaRevertida.id, equals(despesaAberta.id));
        expect(despesaRevertida.baixa, isNull);
        final resumoAposReversao = calcularResumoMensal(competencia, [
          receitaAberta,
          despesaRevertida,
        ], seriesPorId);
        expect(
          resumoAposReversao.despesasPrevistas,
          equals(const Money(20000)),
        );
        expect(resumoAposReversao.despesasPagas, equals(const Money(0)));
        expect(resumoAposReversao.saldoPrevisto, equals(const Money(280000)));
      },
    );
  });
}
