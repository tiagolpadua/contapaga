import 'package:contapaga/features/recorrencias/domain/casos_uso/editar_serie.dart';
import 'package:contapaga/features/recorrencias/domain/civil_date.dart';
import 'package:contapaga/features/recorrencias/domain/money.dart';
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
        ),
        throwsArgumentError,
      );
    });
  });
}
