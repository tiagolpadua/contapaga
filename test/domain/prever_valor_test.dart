import 'package:contapaga/features/recorrencias/domain/baixa.dart';
import 'package:contapaga/features/recorrencias/domain/casos_uso/prever_valor_ocorrencia.dart';
import 'package:contapaga/features/recorrencias/domain/civil_date.dart';
import 'package:contapaga/features/recorrencias/domain/competencia.dart';
import 'package:contapaga/features/recorrencias/domain/money.dart';
import 'package:contapaga/features/recorrencias/domain/ocorrencia.dart';
import 'package:contapaga/features/recorrencias/domain/regra_recorrencia.dart';
import 'package:contapaga/features/recorrencias/domain/serie_recorrente.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('preverValorOcorrencia', () {
    final relogio = DateTime(2026, 9, 16);
    const setembro2026 = Competencia(2026, 9);

    final serie = SerieRecorrente(
      id: 's1',
      descricao: 'Luz',
      tipo: TipoLancamento.despesa,
      debitoAutomatico: false,
      valorBase: const Money(10000), // 100.00
      regra: RegraRecorrencia(
        frequencia: Frequencia.mensal,
        dataInicial: const CivilDate(2026, 9, 5),
      ),
    );

    Ocorrencia baixadaEm(int ano, int mes, int valorPago) {
      return Ocorrencia(
        serieId: 's1',
        id: '$ano-$mes',
        dataVencimento: CivilDate(ano, mes, 5),
        valorPrevisto: const Money(10000),
        sequencia: mes,
        baixa: Baixa(
          valorPago: Money(valorPago),
          dataPagamento: CivilDate(ano, mes, 5),
          registradoEm: relogio,
        ),
      );
    }

    test('sem historico retorna valor base', () {
      final prev = preverValorOcorrencia(serie, setembro2026, []);
      expect(prev, equals(const Money(10000)));
    });

    test('com uma ocorrencia na janela usa o valor pago dela', () {
      final o1 = baixadaEm(2026, 8, 12000);
      final prev = preverValorOcorrencia(serie, setembro2026, [o1]);
      expect(prev, equals(const Money(12000)));
    });

    test('exemplo da fase 0: abr 100, jun 120, ago 110 -> previsao set = 110,'
        ' meses sem baixa nao contam como zero', () {
      final historico = [
        baixadaEm(2026, 4, 10000),
        baixadaEm(2026, 6, 12000),
        baixadaEm(2026, 8, 11000),
      ];
      final prev = preverValorOcorrencia(serie, setembro2026, historico);
      expect(prev, equals(const Money(11000)));
    });

    test('ignora baixas fora da janela de 6 competencias anteriores, mesmo que'
        ' isso deixe poucos valores para a media', () {
      final historico = [
        baixadaEm(2025, 1, 1000), // fora da janela (bem anterior a mar/26)
        baixadaEm(2025, 2, 2000), // fora da janela
        baixadaEm(2026, 8, 11000), // unica dentro da janela mar-ago/2026
      ];
      final prev = preverValorOcorrencia(serie, setembro2026, historico);
      expect(prev, equals(const Money(11000)));
    });

    test('ignora baixa da propria competencia alvo (mes corrente)', () {
      final historico = [
        baixadaEm(2026, 8, 11000),
        baixadaEm(2026, 9, 99900), // competencia alvo, deve ser ignorada
      ];
      final prev = preverValorOcorrencia(serie, setembro2026, historico);
      expect(prev, equals(const Money(11000)));
    });
  });
}
