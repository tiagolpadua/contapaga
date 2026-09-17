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
    required this.saldoPrevisto,
  });
  final Competencia competencia;
  final Money receitasPrevistas;
  final Money receitasPagas;
  final Money despesasPrevistas;
  final Money despesasPagas;

  /// Receitas menos despesas: valores efetivos (pagos) nas ocorrências já
  /// baixadas e previstos nas abertas (fase 0). Não é
  /// `receitasPrevistas - despesasPrevistas`, que ignoraria o valor
  /// realmente pago numa ocorrência já baixada.
  final Money saldoPrevisto;

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
  var recEfetivoOuPrevisto = const Money(0);
  var despEfetivoOuPrevisto = const Money(0);

  for (final o in ocorrencias) {
    if (o.competencia != competencia) continue;

    final serie = seriesPorId[o.serieId];
    if (serie == null) continue; // Ignora se não achar a série

    final isReceita = serie.tipo == TipoLancamento.receita;
    // Regra fase 0: saldo usa o valor efetivo (pago) quando baixada, e o
    // valor previsto quando ainda aberta.
    final valorParaSaldo = o.baixa?.valorPago ?? o.valorPrevisto;

    if (isReceita) {
      recPrev += o.valorPrevisto;
      recEfetivoOuPrevisto += valorParaSaldo;
      if (o.baixa != null) {
        recPagas += o.baixa!.valorPago;
      }
    } else {
      despPrev += o.valorPrevisto;
      despEfetivoOuPrevisto += valorParaSaldo;
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
    saldoPrevisto: recEfetivoOuPrevisto - despEfetivoOuPrevisto,
  );
}
