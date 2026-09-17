import 'package:contapaga/features/recorrencias/domain/competencia.dart';
import 'package:contapaga/features/recorrencias/domain/money.dart';
import 'package:contapaga/features/recorrencias/domain/ocorrencia.dart';
import 'package:contapaga/features/recorrencias/domain/serie_recorrente.dart';

class ResumoMensal {

  const new({
    required this.competencia,
    required this.receitasPrevistas,
    required this.receitasPagas,
    required this.despesasPrevistas,
    required this.despesasPagas,
  });
  final Competencia competencia;
  final Money receitasPrevistas;
  final Money receitasPagas;
  final Money despesasPrevistas;
  final Money despesasPagas;

  Money get saldoPrevisto => receitasPrevistas - despesasPrevistas;
  Money get saldoRealizado => receitasPagas - despesasPagas;
}

ResumoMensal calcularResumoMensal(
  Competencia competencia,
  List<Ocorrencia> ocorrencias,
  Map<String, SerieRecorrente> seriesPorId,
) {
  var recPrev = const Money(0);
  var recPagas = const Money(0);
  var despPrev = const Money(0);
  var despPagas = const Money(0);

  for (final o in ocorrencias) {
    if (o.competencia != competencia) continue;

    final serie = seriesPorId[o.serieId];
    if (serie == null) continue; // Ignora se não achar a série

    final isReceita = serie.tipo == TipoLancamento.receita;

    if (isReceita) {
      recPrev += o.valorPrevisto;
      if (o.baixa != null) {
        recPagas += o.baixa!.valorPago;
      }
    } else {
      despPrev += o.valorPrevisto;
      if (o.baixa != null) {
        despPagas += o.baixa!.valorPago;
      }
    }
  }

  return ResumoMensal(
    competencia: competencia,
    receitasPrevistas: recPrev,
    receitasPagas: recPagas,
    despesasPrevistas: despPrev,
    despesasPagas: despPagas,
  );
}
