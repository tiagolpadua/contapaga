import 'package:contapaga/features/recorrencias/domain/civil_date.dart';
import 'package:contapaga/features/recorrencias/domain/regra_recorrencia.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RegraRecorrencia', () {
    const dBase = CivilDate(2026, 9, 16);

    test('valida intervalo', () {
      expect(
        () => RegraRecorrencia(
          frequencia: Frequencia.diaria,
          intervalo: 0,
          dataInicial: dBase,
        ),
        throwsArgumentError,
      );
    });

    test('valida semanal com dias da semana vazios', () {
      expect(
        () => RegraRecorrencia(
          frequencia: Frequencia.semanal,
          diasSemana: {},
          dataInicial: dBase,
        ),
        throwsArgumentError,
      );

      // Deve aceitar se tiver dia
      expect(
        () => RegraRecorrencia(
          frequencia: Frequencia.semanal,
          diasSemana: {1},
          dataInicial: dBase,
        ),
        returnsNormally,
      );
    });

    test('valida terminoTipo', () {
      // Nunca, com data ou quantidade
      expect(
        () => RegraRecorrencia(
          frequencia: Frequencia.mensal,
          dataInicial: dBase,
          terminoQuantidade: 5,
        ),
        throwsArgumentError,
      );

      // Data, sem data
      expect(
        () => RegraRecorrencia(
          frequencia: Frequencia.mensal,
          dataInicial: dBase,
          terminoTipo: TerminoTipo.data,
        ),
        throwsArgumentError,
      );

      // Quantidade, sem quantidade
      expect(
        () => RegraRecorrencia(
          frequencia: Frequencia.mensal,
          dataInicial: dBase,
          terminoTipo: TerminoTipo.quantidade,
        ),
        throwsArgumentError,
      );
    });

    test('diaEfetivoNoMes', () {
      final regra31 = RegraRecorrencia(
        frequencia: Frequencia.mensal,
        dataInicial: const CivilDate(2026, 1, 31),
      );

      // 2026 não é bissexto
      expect(regra31.diaEfetivoNoMes(2026, 2), 28);
      expect(regra31.diaEfetivoNoMes(2026, 3), 31);
      expect(regra31.diaEfetivoNoMes(2026, 4), 30);

      // 2024 é bissexto
      expect(regra31.diaEfetivoNoMes(2024, 2), 29);
    });

    test('diaEfetivoNoMes anual 29/02', () {
      final regra29Feb = RegraRecorrencia(
        frequencia: Frequencia.anual,
        dataInicial: const CivilDate(2024, 2, 29),
      );

      expect(regra29Feb.diaEfetivoNoMes(2025, 2), 28);
      expect(regra29Feb.diaEfetivoNoMes(2028, 2), 29);
    });
  });
}
