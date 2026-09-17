import 'package:contapaga/features/recorrencias/domain/civil_date.dart';
import 'package:contapaga/features/recorrencias/domain/money.dart';
import 'package:contapaga/features/recorrencias/domain/regra_recorrencia.dart';
import 'package:contapaga/features/recorrencias/domain/revisao_serie.dart';
import 'package:contapaga/features/recorrencias/domain/serie_recorrente.dart';

/// Cria uma nova revisão prospectiva para a série.
/// A revisão passa a valer a partir de `dataEfeito`.
SerieRecorrente adicionarRevisao(
  SerieRecorrente serie, {
  required CivilDate dataEfeito,
  required Money novoValorBase,
  required RegraRecorrencia novaRegra,
}) {
  // A data de efeito de uma nova revisão deve ser estritamente maior (ou igual, mas se for igual substitui?)
  // O domínio costuma apenas validar que a data de efeito não está no passado de outra revisão.
  if (serie.revisoes.isNotEmpty) {
    final ultimaEfeito = serie.revisoes.last.dataEfeito;
    if (dataEfeito.isBefore(ultimaEfeito)) {
      throw ArgumentError(
        'A nova revisão não pode ter data de efeito anterior à última revisão.',
      );
    }
  } else {
    if (dataEfeito.isBefore(serie.regra.dataInicial)) {
      throw ArgumentError(
        'A nova revisão não pode ter data de efeito anterior à data inicial da série.',
      );
    }
  }

  final novaRevisao = RevisaoSerie(
    dataEfeito: dataEfeito,
    valorBase: novoValorBase,
    regra: novaRegra,
  );

  return serie.copyWithInternal(
    revisoes: List.unmodifiable([...serie.revisoes, novaRevisao]),
  );
}
