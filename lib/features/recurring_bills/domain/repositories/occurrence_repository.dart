import 'package:contapaga/features/recurring_bills/domain/civil_date.dart';
import 'package:contapaga/features/recurring_bills/domain/competency_period.dart';
import 'package:contapaga/features/recurring_bills/domain/occurrence.dart';
import 'package:contapaga/features/recurring_bills/domain/settlement.dart';

abstract interface class OccurrenceRepository {
  Future<List<Occurrence>> listByCompetencyPeriod(
    CompetencyPeriod competencyPeriod,
  );
  Future<List<Occurrence>> listBySeries(
    String seriesId, {
    CivilDate? from,
    CivilDate? through,
  });
  Future<void> settleOccurrence(String occurrenceId, Settlement settlement);
  Future<void> revertSettlement(String occurrenceId);
  Future<void> ensureMaterializedThrough(String seriesId, CivilDate through);

  /// Descarta as ocorrências não settled de [seriesId] com vencimento a
  /// partir de [effectiveDate] e regenera esse trecho com a regra vigente
  /// da série já persistida (que deve refletir a revisão que motivou a
  /// chamada). Ocorrências settled nunca são removidas por este método —
  /// a validação de que a nova regra as preserva é responsabilidade do
  /// caso de uso de domínio (`addRevision`), chamado antes desta operação.
  Future<void> resyncFromRevision(String seriesId, CivilDate effectiveDate);
}
