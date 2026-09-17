import 'package:contapaga/core/time/clock.dart';
import 'package:contapaga/features/recorrencias/domain/baixa.dart';
import 'package:contapaga/features/recorrencias/domain/casos_uso/prever_valor_ocorrencia.dart';
import 'package:contapaga/features/recorrencias/domain/civil_date.dart';
import 'package:contapaga/features/recorrencias/domain/money.dart';
import 'package:contapaga/features/recorrencias/domain/ocorrencia.dart';
import 'package:contapaga/features/recorrencias/domain/regra_recorrencia.dart';
import 'package:contapaga/features/recorrencias/domain/serie_recorrente.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('preverValorOcorrencia', () {
    final relogio = DateTime(2026, 9, 16);
    
    final serie = SerieRecorrente(
      id: 's1',
      descricao: 'Luz',
      tipo: TipoLancamento.despesa,
      debitoAutomatico: false,
      valorBase: Money(10000), // 100.00
      regra: RegraRecorrencia(frequencia: Frequencia.mensal, dataInicial: CivilDate(2026, 9, 5)),
    );

    test('sem historico retorna valor base', () {
      final prev = preverValorOcorrencia(serie, []);
      expect(prev, equals(Money(10000)));
    });

    test('com uma ocorrencia usa o valor pago dela', () {
      final o1 = Ocorrencia(
        serieId: 's1', id: '1', dataVencimento: CivilDate(2026, 8, 5), valorPrevisto: Money(10000), sequencia: 1,
        baixa: Baixa(valorPago: Money(12000), dataPagamento: CivilDate(2026, 8, 5), registradoEm: relogio),
      );
      final prev = preverValorOcorrencia(serie, [o1]);
      expect(prev, equals(Money(12000)));
    });

    test('com 4 ocorrencias pega a media das 3 ultimas (default)', () {
      final o1 = Ocorrencia(
        serieId: 's1', id: '1', dataVencimento: CivilDate(2026, 5, 5), valorPrevisto: Money(10000), sequencia: 1,
        baixa: Baixa(valorPago: Money(5000), dataPagamento: CivilDate(2026, 5, 5), registradoEm: relogio),
      );
      final o2 = Ocorrencia(
        serieId: 's1', id: '2', dataVencimento: CivilDate(2026, 6, 5), valorPrevisto: Money(10000), sequencia: 2,
        baixa: Baixa(valorPago: Money(10000), dataPagamento: CivilDate(2026, 6, 5), registradoEm: relogio),
      );
      final o3 = Ocorrencia(
        serieId: 's1', id: '3', dataVencimento: CivilDate(2026, 7, 5), valorPrevisto: Money(10000), sequencia: 3,
        baixa: Baixa(valorPago: Money(11000), dataPagamento: CivilDate(2026, 7, 5), registradoEm: relogio),
      );
      final o4 = Ocorrencia(
        serieId: 's1', id: '4', dataVencimento: CivilDate(2026, 8, 5), valorPrevisto: Money(10000), sequencia: 4,
        baixa: Baixa(valorPago: Money(12000), dataPagamento: CivilDate(2026, 8, 5), registradoEm: relogio),
      );

      // Valores das ultimas 3: 10000, 11000, 12000 -> media = 11000
      final prev = preverValorOcorrencia(serie, [o1, o2, o3, o4]);
      expect(prev, equals(Money(11000)));
    });
  });
}
