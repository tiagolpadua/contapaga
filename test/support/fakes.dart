import 'package:contapaga/core/storage/key_value_store.dart';
import 'package:contapaga/core/time/clock.dart';
import 'package:contapaga/features/recurring_bills/domain/civil_date.dart';
import 'package:contapaga/features/recurring_bills/domain/competency_period.dart';
import 'package:contapaga/features/recurring_bills/domain/notification_preferences.dart';
import 'package:contapaga/features/recurring_bills/domain/occurrence.dart';
import 'package:contapaga/features/recurring_bills/domain/occurrence_generation.dart';
import 'package:contapaga/features/recurring_bills/domain/recurring_series.dart';
import 'package:contapaga/features/recurring_bills/domain/repositories/notification_preferences_repository.dart';
import 'package:contapaga/features/recurring_bills/domain/repositories/occurrence_repository.dart';
import 'package:contapaga/features/recurring_bills/domain/repositories/series_repository.dart';
import 'package:contapaga/features/recurring_bills/domain/settlement.dart';

class FixedClock implements Clock {
  new(this.value);
  final DateTime value;
  @override
  DateTime now() => value;
}

class MemoryStore implements KeyValueStore {
  final values = <String, String>{};
  bool failWrites = false;
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> write(String key, String value) async {
    if (failWrites) throw StateError('Simulated storage failure');
    values[key] = value;
  }

  @override
  Future<void> close() async {}
}

class FakeSeriesRepository implements SeriesRepository {
  final series = <String, RecurringSeries>{};

  @override
  Future<List<RecurringSeries>> listActive() async {
    return series.values.where((s) => s.closedAt == null).toList();
  }

  @override
  Future<List<RecurringSeries>> listAll() async {
    return series.values.toList();
  }

  @override
  Future<RecurringSeries?> findById(String id) async {
    return series[id];
  }

  @override
  Future<void> save(RecurringSeries series) async {
    this.series[series.id] = series;
  }

  @override
  Future<void> close(String id, CivilDate closedAt) async {
    final s = series[id];
    if (s != null) {
      series[id] = s.copyWithInternal(closedAt: closedAt);
    }
  }
}

class FakeOccurrenceRepository implements OccurrenceRepository {
  new([this.seriesRepository]);

  /// Opcional: quando fornecido, `resyncFromRevision` regenera as
  /// ocorrências descartadas com a regra vigente da série, replicando o
  /// comportamento do repositório SQLite real. Sem ele, apenas descarta.
  final FakeSeriesRepository? seriesRepository;
  final occurrences = <String, Occurrence>{};
  final materializedThrough = <String, CivilDate>{};

  @override
  Future<List<Occurrence>> listByCompetencyPeriod(
    CompetencyPeriod competencyPeriod,
  ) async {
    return occurrences.values
        .where((o) => o.competencyPeriod == competencyPeriod)
        .toList();
  }

  @override
  Future<List<Occurrence>> listBySeries(
    String seriesId, {
    CivilDate? from,
    CivilDate? through,
  }) async {
    return occurrences.values.where((o) {
      if (o.seriesId != seriesId) return false;
      if (from != null && o.dueDate.isBefore(from)) return false;
      if (through != null && o.dueDate.isAfter(through)) return false;
      return true;
    }).toList();
  }

  @override
  Future<void> settleOccurrence(
    String occurrenceId,
    Settlement settlement,
  ) async {
    final o = occurrences[occurrenceId];
    if (o == null) {
      throw StateError('Ocorrência não encontrada: $occurrenceId');
    }
    if (o.settlement != null) {
      throw StateError('Ocorrência já possui settlement: $occurrenceId');
    }
    occurrences[occurrenceId] = o.copyWithSettlement(settlement);
  }

  @override
  Future<void> revertSettlement(String occurrenceId) async {
    final o = occurrences[occurrenceId];
    if (o == null) {
      throw StateError('Ocorrência não encontrada: $occurrenceId');
    }
    if (o.settlement == null) {
      throw StateError('Ocorrência não possui settlement: $occurrenceId');
    }
    occurrences[occurrenceId] = o.copyWithSettlement(null);
  }

  @override
  Future<void> ensureMaterializedThrough(
    String seriesId,
    CivilDate through,
  ) async {
    final current = materializedThrough[seriesId];
    if (current == null || current.isBefore(through)) {
      materializedThrough[seriesId] = through;
    }
  }

  @override
  Future<void> resyncFromRevision(
    String seriesId,
    CivilDate effectiveDate,
  ) async {
    final through = materializedThrough[seriesId];

    occurrences.removeWhere(
      (_, o) =>
          o.seriesId == seriesId &&
          o.settlement == null &&
          o.dueDate.isSameOrAfter(effectiveDate),
    );

    if (through == null || through.isBefore(effectiveDate)) return;

    final series = seriesRepository?.series[seriesId];
    if (series == null) return;

    for (final o in generateOccurrences(
      series,
      desde: effectiveDate,
      ate: through,
    )) {
      occurrences[o.id] = o;
    }
  }
}

class FakeNotificationPreferencesRepository
    implements NotificationPreferencesRepository {
  NotificationPreferences prefs = NotificationPreferences(hour: 9, minute: 0);

  @override
  Future<NotificationPreferences> load() async => prefs;

  @override
  Future<void> save(NotificationPreferences preferences) async {
    prefs = preferences;
  }
}
