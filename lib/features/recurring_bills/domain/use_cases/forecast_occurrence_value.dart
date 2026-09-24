import 'package:contapaga/features/recurring_bills/domain/competency_period.dart';
import 'package:contapaga/features/recurring_bills/domain/money.dart';
import 'package:contapaga/features/recurring_bills/domain/occurrence.dart';
import 'package:contapaga/features/recurring_bills/domain/recurring_series.dart';

/// Média das baixas da série nas 6 competências imediatamente anteriores a
/// [competenciaAlvo] (excluindo-a); meses sem settlement não entram como zero e
/// não são compensados buscando mais longe. Sem baixas na janela, usa
/// `serie.baseAmount`.
Money forecastOccurrenceValue(
  RecurringSeries serie,
  CompetencyPeriod competenciaAlvo,
  List<Occurrence> ocorrenciasPassadas,
) {
  final janela = competenciaAlvo.preceding(6).toSet();

  final selecionadas = ocorrenciasPassadas
      .where((o) => o.settlement != null && janela.contains(o.competencyPeriod))
      .map((o) => o.settlement!.paidAmount)
      .toList();

  if (selecionadas.isEmpty) {
    return serie.baseAmount;
  }

  return Money.averageRoundedHalfUp(selecionadas);
}
