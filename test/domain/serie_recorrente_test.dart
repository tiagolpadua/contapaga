import 'package:contapaga/features/recorrencias/domain/civil_date.dart';
import 'package:contapaga/features/recorrencias/domain/money.dart';
import 'package:contapaga/features/recorrencias/domain/regra_recorrencia.dart';
import 'package:contapaga/features/recorrencias/domain/revisao_serie.dart';
import 'package:contapaga/features/recorrencias/domain/serie_recorrente.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SerieRecorrente.revisaoVigenteEm', () {
    final regraOriginal = RegraRecorrencia(
      frequencia: Frequencia.mensal,
      dataInicial: const CivilDate(2026, 1, 10),
    );

    test('sem revisoes, retorna sempre a regra original', () {
      final serie = SerieRecorrente(
        id: 's1',
        descricao: 'Internet',
        tipo: TipoLancamento.despesa,
        debitoAutomatico: false,
        valorBase: const Money(9000),
        regra: regraOriginal,
      );

      final vigente = serie.revisaoVigenteEm(const CivilDate(2026, 12, 1));
      expect(vigente.regra, same(regraOriginal));
      expect(vigente.valorBase, equals(const Money(9000)));
    });

    test('antes da primeira revisao usa a regra original', () {
      final novaRegra = RegraRecorrencia(
        frequencia: Frequencia.mensal,
        dataInicial: const CivilDate(2026, 6, 15),
      );
      final serie = SerieRecorrente(
        id: 's1',
        descricao: 'Internet',
        tipo: TipoLancamento.despesa,
        debitoAutomatico: false,
        valorBase: const Money(9000),
        regra: regraOriginal,
        revisoes: [
          RevisaoSerie(
            dataEfeito: const CivilDate(2026, 6, 10),
            valorBase: const Money(9500),
            regra: novaRegra,
          ),
        ],
      );

      final vigenteAntes = serie.revisaoVigenteEm(const CivilDate(2026, 5, 1));
      expect(vigenteAntes.regra, same(regraOriginal));
      expect(vigenteAntes.valorBase, equals(const Money(9000)));
    });

    test('na data de efeito e depois, usa a revisao (edicao prospectiva)', () {
      final novaRegra = RegraRecorrencia(
        frequencia: Frequencia.mensal,
        dataInicial: const CivilDate(2026, 6, 15),
      );
      final serie = SerieRecorrente(
        id: 's1',
        descricao: 'Internet',
        tipo: TipoLancamento.despesa,
        debitoAutomatico: false,
        valorBase: const Money(9000),
        regra: regraOriginal,
        revisoes: [
          RevisaoSerie(
            dataEfeito: const CivilDate(2026, 6, 10),
            valorBase: const Money(9500),
            regra: novaRegra,
          ),
        ],
      );

      final naData = serie.revisaoVigenteEm(const CivilDate(2026, 6, 10));
      expect(naData.valorBase, equals(const Money(9500)));

      final depois = serie.revisaoVigenteEm(const CivilDate(2026, 12, 1));
      expect(depois.valorBase, equals(const Money(9500)));
    });

    test('com multiplas revisoes, escolhe a mais recente aplicavel', () {
      final regraJulho = RegraRecorrencia(
        frequencia: Frequencia.mensal,
        dataInicial: const CivilDate(2026, 7, 1),
      );
      final regraSetembro = RegraRecorrencia(
        frequencia: Frequencia.mensal,
        dataInicial: const CivilDate(2026, 9, 1),
      );
      final serie = SerieRecorrente(
        id: 's1',
        descricao: 'Internet',
        tipo: TipoLancamento.despesa,
        debitoAutomatico: false,
        valorBase: const Money(9000),
        regra: regraOriginal,
        revisoes: [
          RevisaoSerie(
            dataEfeito: const CivilDate(2026, 7, 1),
            valorBase: const Money(9500),
            regra: regraJulho,
          ),
          RevisaoSerie(
            dataEfeito: const CivilDate(2026, 9, 1),
            valorBase: const Money(9800),
            regra: regraSetembro,
          ),
        ],
      );

      expect(
        serie.revisaoVigenteEm(const CivilDate(2026, 8, 1)).valorBase,
        equals(const Money(9500)),
      );
      expect(
        serie.revisaoVigenteEm(const CivilDate(2026, 10, 1)).valorBase,
        equals(const Money(9800)),
      );
    });
  });
}
