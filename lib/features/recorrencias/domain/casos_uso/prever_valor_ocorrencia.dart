import 'package:contapaga/features/recorrencias/domain/money.dart';
import 'package:contapaga/features/recorrencias/domain/ocorrencia.dart';
import 'package:contapaga/features/recorrencias/domain/serie_recorrente.dart';

Money preverValorOcorrencia(
  SerieRecorrente serie,
  List<Ocorrencia> ocorrenciasPassadas, {
  int ultimasN = 3,
}) {
  final baixadas = ocorrenciasPassadas.where((o) => o.baixa != null).toList()
    ..sort(
      (a, b) => b.dataVencimento.compareTo(a.dataVencimento),
    ); // Mais recentes primeiro

  final selecionadas = baixadas
      .take(ultimasN)
      .map((o) => o.baixa!.valorPago)
      .toList();

  if (selecionadas.isEmpty) {
    return serie.valorBase;
  }

  return Money.averageRoundedHalfUp(selecionadas);
}
