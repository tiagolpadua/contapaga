import 'package:contapaga/features/recorrencias/domain/baixa.dart';
import 'package:contapaga/features/recorrencias/domain/casos_uso/editar_serie.dart';
import 'package:contapaga/features/recorrencias/domain/civil_date.dart';
import 'package:contapaga/features/recorrencias/domain/money.dart';
import 'package:contapaga/features/recorrencias/domain/ocorrencia.dart';
import 'package:contapaga/features/recorrencias/domain/regra_recorrencia.dart';
import 'package:contapaga/features/recorrencias/domain/serie_recorrente.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('editar_serie', () {
    final serieInicial = SerieRecorrente(
      id: 's1',
      descricao: 'Assinatura',
      tipo: TipoLancamento.despesa,
      debitoAutomatico: false,
      valorBase: const Money(5000), // 50.00
      regra: RegraRecorrencia(
        frequencia: Frequencia.mensal,
        dataInicial: const CivilDate(2026, 1, 10),
      ),
    );

    test('adicionarRevisao', () {
      final serieRevisada = adicionarRevisao(
        serieInicial,
        dataEfeito: const CivilDate(2026, 6, 10),
        novoValorBase: const Money(6000), // aumentou pra 60
        novaRegra: RegraRecorrencia(
          frequencia: Frequencia.mensal,
          dataInicial: const CivilDate(2026, 6, 15), // mudou data base também
        ),
        ocorrenciasExistentes: const [],
      );

      expect(serieRevisada.revisoes.length, 1);
      final rev = serieRevisada.revisoes.first;
      expect(rev.dataEfeito, equals(const CivilDate(2026, 6, 10)));
      expect(rev.valorBase, equals(const Money(6000)));
      expect(rev.regra.frequencia, Frequencia.mensal);
      expect(rev.regra.dataInicial, equals(const CivilDate(2026, 6, 15)));
    });

    test('bloqueia data de efeito anterior à data inicial', () {
      expect(
        () => adicionarRevisao(
          serieInicial,
          dataEfeito: const CivilDate(2025, 1, 1),
          novoValorBase: const Money(6000),
          novaRegra: RegraRecorrencia(
            frequencia: Frequencia.mensal,
            dataInicial: const CivilDate(2025, 1, 1),
          ),
          ocorrenciasExistentes: const [],
        ),
        throwsArgumentError,
      );
    });

    test('bloqueia data de efeito anterior à ultima revisão', () {
      final s1 = adicionarRevisao(
        serieInicial,
        dataEfeito: const CivilDate(2026, 6, 10),
        novoValorBase: const Money(6000),
        novaRegra: RegraRecorrencia(
          frequencia: Frequencia.mensal,
          dataInicial: const CivilDate(2026, 6, 15),
        ),
        ocorrenciasExistentes: const [],
      );

      expect(
        () => adicionarRevisao(
          s1,
          dataEfeito: const CivilDate(2026, 5, 1),
          novoValorBase: const Money(7000),
          novaRegra: RegraRecorrencia(
            frequencia: Frequencia.mensal,
            dataInicial: const CivilDate(2026, 5, 1),
          ),
          ocorrenciasExistentes: const [],
        ),
        throwsArgumentError,
      );
    });

    test('bloqueia edição que eliminaria ocorrência já baixada '
        '(exemplo da fase 0: efeito em 20/09 preserva baixa de 21/09)', () {
      // Série mensal dia 21; a baixa de 21/09 é preservada, mas a nova
      // regra (dia 25) faria a ocorrência de setembro deixar de existir
      // em 21/09 -> a baixa correspondente seria eliminada.
      final serieMensalDia21 = SerieRecorrente(
        id: 's2',
        descricao: 'Internet',
        tipo: TipoLancamento.despesa,
        debitoAutomatico: false,
        valorBase: const Money(9000),
        regra: RegraRecorrencia(
          frequencia: Frequencia.mensal,
          dataInicial: const CivilDate(2026, 1, 21),
        ),
      );

      final ocorrenciaBaixada21Set = Ocorrencia(
        serieId: 's2',
        id: 's2#2026-09-21#9',
        dataVencimento: const CivilDate(2026, 9, 21),
        valorPrevisto: const Money(9000),
        sequencia: 9,
        baixa: Baixa(
          valorPago: const Money(9000),
          dataPagamento: const CivilDate(2026, 9, 21),
          registradoEm: DateTime(2026, 9, 21),
        ),
      );

      expect(
        () => adicionarRevisao(
          serieMensalDia21,
          dataEfeito: const CivilDate(2026, 9, 20),
          novoValorBase: const Money(9000),
          novaRegra: RegraRecorrencia(
            frequencia: Frequencia.mensal,
            dataInicial: const CivilDate(2026, 9, 25),
          ),
          ocorrenciasExistentes: [ocorrenciaBaixada21Set],
        ),
        throwsA(isA<EdicaoBloqueadaException>()),
      );
    });

    test('permite edição que preserva a ocorrência já baixada '
        '(mesmo dia de vencimento, só o valor muda)', () {
      final serieMensalDia21 = SerieRecorrente(
        id: 's2',
        descricao: 'Internet',
        tipo: TipoLancamento.despesa,
        debitoAutomatico: false,
        valorBase: const Money(9000),
        regra: RegraRecorrencia(
          frequencia: Frequencia.mensal,
          dataInicial: const CivilDate(2026, 1, 21),
        ),
      );

      final ocorrenciaBaixada21Set = Ocorrencia(
        serieId: 's2',
        id: 's2#2026-09-21#9',
        dataVencimento: const CivilDate(2026, 9, 21),
        valorPrevisto: const Money(9000),
        sequencia: 9,
        baixa: Baixa(
          valorPago: const Money(9000),
          dataPagamento: const CivilDate(2026, 9, 21),
          registradoEm: DateTime(2026, 9, 21),
        ),
      );

      final revisada = adicionarRevisao(
        serieMensalDia21,
        dataEfeito: const CivilDate(2026, 9, 20),
        novoValorBase: const Money(9500),
        novaRegra: RegraRecorrencia(
          frequencia: Frequencia.mensal,
          dataInicial: const CivilDate(2026, 9, 21),
        ),
        ocorrenciasExistentes: [ocorrenciaBaixada21Set],
      );

      expect(revisada.revisoes.single.valorBase, equals(const Money(9500)));
    });

    test('bloqueia redução de terminoQuantidade abaixo da quantidade já '
        'preservada a partir da data de efeito', () {
      final serieComTermino = SerieRecorrente(
        id: 's3',
        descricao: 'Curso',
        tipo: TipoLancamento.despesa,
        debitoAutomatico: false,
        valorBase: const Money(20000),
        regra: RegraRecorrencia(
          frequencia: Frequencia.mensal,
          dataInicial: const CivilDate(2026, 1, 10),
          terminoTipo: TerminoTipo.quantidade,
          terminoQuantidade: 12,
        ),
      );

      // 3 ocorrências já preservadas a partir da data de efeito (abertas).
      final abertas = List.generate(
        3,
        (i) => Ocorrencia(
          serieId: 's3',
          id: 's3#occ$i',
          dataVencimento: CivilDate(2026, 9 + i, 10),
          valorPrevisto: const Money(20000),
          sequencia: 9 + i,
        ),
      );

      expect(
        () => adicionarRevisao(
          serieComTermino,
          dataEfeito: const CivilDate(2026, 9, 1),
          novoValorBase: const Money(20000),
          novaRegra: RegraRecorrencia(
            frequencia: Frequencia.mensal,
            dataInicial: const CivilDate(2026, 9, 10),
            terminoTipo: TerminoTipo.quantidade,
            terminoQuantidade: 2, // menor que as 3 já preservadas
          ),
          ocorrenciasExistentes: abertas,
        ),
        throwsA(isA<EdicaoBloqueadaException>()),
      );
    });
  });
}
