import 'package:contapaga/features/recorrencias/domain/civil_date.dart';
import 'package:contapaga/features/recorrencias/domain/geracao_ocorrencias.dart';
import 'package:contapaga/features/recorrencias/domain/money.dart';
import 'package:contapaga/features/recorrencias/domain/regra_recorrencia.dart';
import 'package:contapaga/features/recorrencias/domain/revisao_serie.dart';
import 'package:contapaga/features/recorrencias/domain/serie_recorrente.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('gerarOcorrencias', () {
    final baseSerie = SerieRecorrente(
      id: 's1',
      descricao: 'Teste',
      tipo: TipoLancamento.despesa,
      debitoAutomatico: false,
      valorBase: const Money(1000),
      regra: RegraRecorrencia(
        frequencia: Frequencia.mensal,
        dataInicial: const CivilDate(2026, 9, 10),
      ),
    );

    test('Virada dezembro->janeiro', () {
      final s = baseSerie.copyWithInternal(
        regra: RegraRecorrencia(
          frequencia: Frequencia.mensal,
          dataInicial: const CivilDate(2026, 12, 31),
        ),
      );

      final ocs = gerarOcorrencias(
        s,
        desde: const CivilDate(2026, 12, 1),
        ate: const CivilDate(2027, 2, 1),
      );

      expect(ocs.length, 2);
      expect(ocs[0].dataVencimento, equals(const CivilDate(2026, 12, 31)));
      expect(ocs[1].dataVencimento, equals(const CivilDate(2027, 1, 31)));
    });

    test('Dia 31 em mês curto e preservação', () {
      final s = baseSerie.copyWithInternal(
        regra: RegraRecorrencia(
          frequencia: Frequencia.mensal,
          dataInicial: const CivilDate(2026, 1, 31),
        ),
      );

      final ocs = gerarOcorrencias(
        s,
        desde: const CivilDate(2026, 1, 1),
        ate: const CivilDate(2026, 3, 31),
      );

      expect(ocs.length, 3);
      expect(ocs[0].dataVencimento, equals(const CivilDate(2026, 1, 31)));
      expect(
        ocs[1].dataVencimento,
        equals(const CivilDate(2026, 2, 28)),
      ); // 2026 não é bissexto
      expect(
        ocs[2].dataVencimento,
        equals(const CivilDate(2026, 3, 31)),
      ); // Preserva 31
    });

    test('Anual 29/02', () {
      final s = baseSerie.copyWithInternal(
        regra: RegraRecorrencia(
          frequencia: Frequencia.anual,
          dataInicial: const CivilDate(2024, 2, 29),
        ),
      );

      final ocs = gerarOcorrencias(
        s,
        desde: const CivilDate(2024, 1, 1),
        ate: const CivilDate(2028, 12, 31),
      );

      expect(ocs.length, 5);
      expect(ocs[0].dataVencimento, equals(const CivilDate(2024, 2, 29)));
      expect(ocs[1].dataVencimento, equals(const CivilDate(2025, 2, 28)));
      expect(ocs[2].dataVencimento, equals(const CivilDate(2026, 2, 28)));
      expect(ocs[3].dataVencimento, equals(const CivilDate(2027, 2, 28)));
      expect(ocs[4].dataVencimento, equals(const CivilDate(2028, 2, 29)));
    });

    test('Diária finita', () {
      final s = baseSerie.copyWithInternal(
        regra: RegraRecorrencia(
          frequencia: Frequencia.diaria,
          dataInicial: const CivilDate(2026, 9, 30),
          terminoTipo: TerminoTipo.quantidade,
          terminoQuantidade: 3,
        ),
      );

      final ocs = gerarOcorrencias(
        s,
        desde: const CivilDate(2026, 9, 1),
        ate: const CivilDate(2026, 10, 31),
      );

      expect(ocs.length, 3);
      expect(ocs[0].dataVencimento, equals(const CivilDate(2026, 9, 30)));
      expect(ocs[1].dataVencimento, equals(const CivilDate(2026, 10, 1)));
      expect(ocs[2].dataVencimento, equals(const CivilDate(2026, 10, 2)));
    });

    test('Semanal com término por data', () {
      final s = baseSerie.copyWithInternal(
        regra: RegraRecorrencia(
          frequencia: Frequencia.semanal,
          intervalo: 2,
          diasSemana: {1, 3}, // seg, qua
          dataInicial: const CivilDate(2026, 9, 14), // é uma segunda
          terminoTipo: TerminoTipo.data,
          terminoData: const CivilDate(2026, 9, 28),
        ),
      );

      final ocs = gerarOcorrencias(
        s,
        desde: const CivilDate(2026, 9, 1),
        ate: const CivilDate(2026, 10, 31),
      );

      expect(ocs.length, 3);
      expect(ocs[0].dataVencimento, equals(const CivilDate(2026, 9, 14)));
      expect(ocs[1].dataVencimento, equals(const CivilDate(2026, 9, 16)));
      expect(ocs[2].dataVencimento, equals(const CivilDate(2026, 9, 28)));
      // 30/09 foi excluído
    });

    test('Semanal com quantidade', () {
      final s = baseSerie.copyWithInternal(
        regra: RegraRecorrencia(
          frequencia: Frequencia.semanal,
          intervalo: 2,
          diasSemana: {1, 3},
          dataInicial: const CivilDate(2026, 9, 14),
          terminoTipo: TerminoTipo.quantidade,
          terminoQuantidade: 4,
        ),
      );

      final ocs = gerarOcorrencias(
        s,
        desde: const CivilDate(2026, 9, 1),
        ate: const CivilDate(2026, 10, 31),
      );

      expect(ocs.length, 4);
      expect(ocs[0].dataVencimento, equals(const CivilDate(2026, 9, 14)));
      expect(ocs[1].dataVencimento, equals(const CivilDate(2026, 9, 16)));
      expect(ocs[2].dataVencimento, equals(const CivilDate(2026, 9, 28)));
      expect(ocs[3].dataVencimento, equals(const CivilDate(2026, 9, 30)));
    });

    test('Não gerar antes do início', () {
      final s = baseSerie.copyWithInternal(
        regra: RegraRecorrencia(
          frequencia: Frequencia.mensal,
          dataInicial: const CivilDate(2026, 12, 1),
        ),
      );

      final ocs = gerarOcorrencias(
        s,
        desde: const CivilDate(2026, 9, 1),
        ate: const CivilDate(2026, 10, 31),
      );

      expect(ocs, isEmpty);
    });

    test('Idempotência', () {
      final s = baseSerie.copyWithInternal(
        regra: RegraRecorrencia(
          frequencia: Frequencia.diaria,
          dataInicial: const CivilDate(2026, 9, 1),
        ),
      );

      final ocs1 = gerarOcorrencias(
        s,
        desde: const CivilDate(2026, 9, 10),
        ate: const CivilDate(2026, 9, 15),
      );

      final ocs2 = gerarOcorrencias(
        s,
        desde: const CivilDate(2026, 9, 10),
        ate: const CivilDate(2026, 9, 15),
      );

      expect(ocs1.length, ocs2.length);
      for (var i = 0; i < ocs1.length; i++) {
        expect(ocs1[i].id, equals(ocs2[i].id));
        expect(ocs1[i].dataVencimento, equals(ocs2[i].dataVencimento));
      }
    });

    test('Revisão prospectiva', () {
      // Começa diária, muda para semanal na revisão
      final s = baseSerie.copyWithInternal(
        valorBase: const Money(100),
        regra: RegraRecorrencia(
          frequencia: Frequencia.diaria,
          dataInicial: const CivilDate(2026, 9, 18),
        ),
        revisoes: [
          RevisaoSerie(
            dataEfeito: const CivilDate(2026, 9, 20),
            valorBase: const Money(200),
            regra: RegraRecorrencia(
              frequencia: Frequencia.semanal,
              diasSemana: {1}, // segunda-feira (9/21/2026 é seg)
              dataInicial: const CivilDate(2026, 9, 21),
            ),
          ),
        ],
      );

      final ocs = gerarOcorrencias(
        s,
        desde: const CivilDate(2026, 9, 1),
        ate: const CivilDate(2026, 9, 30),
      );

      // Esperado:
      // chunk 0 (diario, 100): 18/09, 19/09. (20/09 não entra pois >= dataEfeito)
      // chunk 1 (semanal, 200, seg): 21/09, 28/09
      expect(ocs.length, 4);

      expect(ocs[0].dataVencimento, equals(const CivilDate(2026, 9, 18)));
      expect(ocs[0].valorPrevisto, equals(const Money(100)));

      expect(ocs[1].dataVencimento, equals(const CivilDate(2026, 9, 19)));
      expect(ocs[1].valorPrevisto, equals(const Money(100)));

      expect(ocs[2].dataVencimento, equals(const CivilDate(2026, 9, 21)));
      expect(ocs[2].valorPrevisto, equals(const Money(200)));

      expect(ocs[3].dataVencimento, equals(const CivilDate(2026, 9, 28)));
      expect(ocs[3].valorPrevisto, equals(const Money(200)));

      // Sequência continua globalmente?
      expect(ocs[0].sequencia, 1);
      expect(ocs[1].sequencia, 2);
      expect(ocs[2].sequencia, 3);
      expect(ocs[3].sequencia, 4);
    });

    test('dataEncerramento interrompe a geracao, preservando ocorrencias '
        'anteriores dentro do intervalo pedido', () {
      final s = baseSerie.copyWithInternal(
        dataEncerramento: const CivilDate(2026, 11, 10),
      );

      final ocs = gerarOcorrencias(
        s,
        desde: const CivilDate(2026, 9, 1),
        ate: const CivilDate(2027, 1, 1),
      );

      // Mensal dia 10: set, out, nov (encerra em 10/11 inclusive); sem dez/jan
      expect(ocs.length, 3);
      expect(ocs[0].dataVencimento, equals(const CivilDate(2026, 9, 10)));
      expect(ocs[1].dataVencimento, equals(const CivilDate(2026, 10, 10)));
      expect(ocs[2].dataVencimento, equals(const CivilDate(2026, 11, 10)));
    });

    test('dataEncerramento anterior ao intervalo pedido gera lista vazia', () {
      final s = baseSerie.copyWithInternal(
        dataEncerramento: const CivilDate(2026, 9, 10),
      );

      final ocs = gerarOcorrencias(
        s,
        desde: const CivilDate(2026, 10, 1),
        ate: const CivilDate(2026, 12, 1),
      );

      expect(ocs, isEmpty);
    });
  });
}
