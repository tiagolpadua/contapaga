import 'package:contapaga/features/recorrencias/domain/competencia.dart';
import 'package:contapaga/features/recorrencias/domain/money.dart';
import 'package:contapaga/features/recorrencias/domain/ocorrencia.dart';
import 'package:contapaga/features/recorrencias/domain/serie_recorrente.dart';

/// Média das baixas da série nas 6 competências imediatamente anteriores a
/// [competenciaAlvo] (excluindo-a); meses sem baixa não entram como zero e
/// não são compensados buscando mais longe. Sem baixas na janela, usa
/// `serie.valorBase`.
Money preverValorOcorrencia(
  SerieRecorrente serie,
  Competencia competenciaAlvo,
  List<Ocorrencia> ocorrenciasPassadas,
) {
  final janela = competenciaAlvo.precedentes(6).toSet();

  final selecionadas = ocorrenciasPassadas
      .where((o) => o.baixa != null && janela.contains(o.competencia))
      .map((o) => o.baixa!.valorPago)
      .toList();

  if (selecionadas.isEmpty) {
    return serie.valorBase;
  }

  return Money.averageRoundedHalfUp(selecionadas);
}
