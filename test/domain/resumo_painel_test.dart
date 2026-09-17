import 'package:contapaga/core/time/clock.dart';
import 'package:contapaga/features/recorrencias/domain/baixa.dart';
import 'package:contapaga/features/recorrencias/domain/casos_uso/calcular_painel.dart';
import 'package:contapaga/features/recorrencias/domain/casos_uso/calcular_resumo_mensal.dart';
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
  group('Casos de Uso de Leitura (Painel e Resumo)', () {
    final relogio = FakeClock(
      DateTime(2026, 9, 16, 12),
    ); // Hoje é 16/09/2026

    final serieRec = SerieRecorrente(
      id: 's1',
      descricao: 'Salário',
      tipo: TipoLancamento.receita,
      debitoAutomatico: false,
      valorBase: const Money(500000), // 5000.00
      regra: RegraRecorrencia(
        frequencia: Frequencia.mensal,
        dataInicial: const CivilDate(2026, 9, 5),
      ),
    );

    final serieDesp = SerieRecorrente(
      id: 's2',
      descricao: 'Aluguel',
      tipo: TipoLancamento.despesa,
      debitoAutomatico: false,
      valorBase: const Money(150000), // 1500.00
      regra: RegraRecorrencia(
        frequencia: Frequencia.mensal,
        dataInicial: const CivilDate(2026, 9, 15),
      ),
    );

    final mapSeries = {'s1': serieRec, 's2': serieDesp};

    test('calcularResumoMensal', () {
      final o1 = Ocorrencia(
        serieId: 's1',
        id: 'o1',
        dataVencimento: const CivilDate(2026, 9, 5),
        valorPrevisto: const Money(500000),
        sequencia: 1,
        baixa: Baixa(
          valorPago: const Money(500000),
          dataPagamento: const CivilDate(2026, 9, 5),
          registradoEm: relogio.now(),
        ),
      );

      final o2 = Ocorrencia(
        serieId: 's2',
        id: 'o2',
        dataVencimento: const CivilDate(2026, 9, 15),
        valorPrevisto: const Money(150000),
        sequencia: 1,
        // não baixado
      );

      final resumo = calcularResumoMensal(const Competencia(2026, 9), [
        o1,
        o2,
      ], mapSeries);

      expect(resumo.receitasPrevistas, equals(const Money(500000)));
      expect(resumo.receitasPagas, equals(const Money(500000)));
      expect(resumo.despesasPrevistas, equals(const Money(150000)));
      expect(resumo.despesasPagas, equals(const Money(0)));
      expect(resumo.saldoPrevisto, equals(const Money(350000)));
      expect(resumo.saldoRealizado, equals(const Money(500000)));
    });

    test('calcularPainel', () {
      final oAtrasada = Ocorrencia(
        serieId: 's2',
        id: '1',
        dataVencimento: const CivilDate(2026, 9, 10),
        valorPrevisto: const Money(100),
        sequencia: 1,
      );
      final oHoje = Ocorrencia(
        serieId: 's2',
        id: '2',
        dataVencimento: const CivilDate(2026, 9, 16),
        valorPrevisto: const Money(100),
        sequencia: 2,
      );
      final oBreve = Ocorrencia(
        serieId: 's2',
        id: '3',
        dataVencimento: const CivilDate(2026, 9, 20),
        valorPrevisto: const Money(100),
        sequencia: 3,
      );
      final oLonge = Ocorrencia(
        serieId: 's2',
        id: '4',
        dataVencimento: const CivilDate(2026, 9, 25),
        valorPrevisto: const Money(100),
        sequencia: 4,
      );
      final oBaixada = Ocorrencia(
        serieId: 's2',
        id: '5',
        dataVencimento: const CivilDate(2026, 9, 10),
        valorPrevisto: const Money(100),
        sequencia: 5,
        baixa: Baixa(
          valorPago: const Money(100),
          dataPagamento: const CivilDate(2026, 9, 10),
          registradoEm: relogio.now(),
        ),
      );

      final painel = calcularPainel([
        oAtrasada,
        oHoje,
        oBreve,
        oLonge,
        oBaixada,
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
