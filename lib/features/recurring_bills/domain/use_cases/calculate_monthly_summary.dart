import 'package:contapaga/features/recurring_bills/domain/competency_period.dart';
import 'package:contapaga/features/recurring_bills/domain/money.dart';
import 'package:contapaga/features/recurring_bills/domain/occurrence.dart';
import 'package:contapaga/features/recurring_bills/domain/recurring_series.dart';

class MonthlySummary {
  const new({
    required this.competencyPeriod,
    required this.expectedIncome,
    required this.paidIncome,
    required this.expectedExpenses,
    required this.paidExpenses,
    required this.expectedBalance,
  });
  final CompetencyPeriod competencyPeriod;
  final Money expectedIncome;
  final Money paidIncome;
  final Money expectedExpenses;
  final Money paidExpenses;

  /// Receitas menos despesas: valores efetivos (pagos) nas ocorrências já
  /// baixadas e previstos nas abertas (fase 0). Não é
  /// `expectedIncome - expectedExpenses`, que ignoraria o valor
  /// realmente pago numa ocorrência já settled.
  final Money expectedBalance;

  Money get settledBalance => paidIncome - paidExpenses;
}

MonthlySummary calculateMonthlySummary(
  CompetencyPeriod competencyPeriod,
  List<Occurrence> occurrences,
  Map<String, RecurringSeries> seriesPorId,
) {
  var recPrev = const Money(0);
  var recPagas = const Money(0);
  var despPrev = const Money(0);
  var despPagas = const Money(0);
  var recEfetivoOuPrevisto = const Money(0);
  var despEfetivoOuPrevisto = const Money(0);

  for (final o in occurrences) {
    if (o.competencyPeriod != competencyPeriod) continue;

    final serie = seriesPorId[o.seriesId];
    if (serie == null) continue; // Ignora se não achar a série

    final isReceita = serie.type == EntryType.income;
    // Regra fase 0: saldo usa o valor efetivo (pago) quando settled, e o
    // valor previsto quando ainda open.
    final valorParaSaldo = o.settlement?.paidAmount ?? o.expectedAmount;

    if (isReceita) {
      recPrev += o.expectedAmount;
      recEfetivoOuPrevisto += valorParaSaldo;
      if (o.settlement != null) {
        recPagas += o.settlement!.paidAmount;
      }
    } else {
      despPrev += o.expectedAmount;
      despEfetivoOuPrevisto += valorParaSaldo;
      if (o.settlement != null) {
        despPagas += o.settlement!.paidAmount;
      }
    }
  }

  return MonthlySummary(
    competencyPeriod: competencyPeriod,
    expectedIncome: recPrev,
    paidIncome: recPagas,
    expectedExpenses: despPrev,
    paidExpenses: despPagas,
    expectedBalance: recEfetivoOuPrevisto - despEfetivoOuPrevisto,
  );
}
