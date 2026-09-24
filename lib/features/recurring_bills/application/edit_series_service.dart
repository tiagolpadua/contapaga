import 'package:contapaga/features/recurring_bills/domain/civil_date.dart';
import 'package:contapaga/features/recurring_bills/domain/money.dart';
import 'package:contapaga/features/recurring_bills/domain/recurrence_rule.dart';
import 'package:contapaga/features/recurring_bills/domain/recurring_series.dart';
import 'package:contapaga/features/recurring_bills/domain/repositories/occurrence_repository.dart';
import 'package:contapaga/features/recurring_bills/domain/repositories/series_repository.dart';
import 'package:contapaga/features/recurring_bills/domain/use_cases/edit_series.dart'
    as domain;

class EditSeriesService {
  new(this._seriesRepository, this._occurrenceRepository);
  final SeriesRepository _seriesRepository;
  final OccurrenceRepository _occurrenceRepository;

  Future<void> editSeries(
    RecurringSeries series, {
    required CivilDate effectiveDate,
    required Money newBaseAmount,
    required RecurrenceRule newRule,
  }) async {
    final existingOccurrences = await _occurrenceRepository.listBySeries(
      series.id,
    );

    final editedSeries = domain.addRevision(
      series,
      effectiveDate: effectiveDate,
      novoValorBase: newBaseAmount,
      novaRegra: newRule,
      existingOccurrences: existingOccurrences,
    );

    await _seriesRepository.save(editedSeries);

    // Ocorrências não settled já materializadas a partir da data de efeito
    // foram geradas com a regra anterior; resyncFromRevision as descarta e
    // regenera com a regra nova. Ocorrências settled nunca são tocadas —
    // addRevision já garantiu acima que a nova regra as preserva.
    await _occurrenceRepository.resyncFromRevision(series.id, effectiveDate);
  }
}
