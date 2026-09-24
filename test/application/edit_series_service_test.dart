import 'package:contapaga/features/recurring_bills/application/edit_series_service.dart';
import 'package:contapaga/features/recurring_bills/domain/civil_date.dart';
import 'package:contapaga/features/recurring_bills/domain/money.dart';
import 'package:contapaga/features/recurring_bills/domain/occurrence.dart';
import 'package:contapaga/features/recurring_bills/domain/recurrence_rule.dart';
import 'package:contapaga/features/recurring_bills/domain/recurring_series.dart';
import 'package:contapaga/features/recurring_bills/domain/settlement.dart';
import 'package:contapaga/features/recurring_bills/domain/use_cases/edit_series.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

void main() {
  group('EditSeriesService', () {
    late FakeSeriesRepository seriesRepository;
    late FakeOccurrenceRepository occurrenceRepository;
    late EditSeriesService service;

    final series = RecurringSeries(
      id: 's1',
      description: 'Internet',
      type: EntryType.expense,
      autoDebit: false,
      baseAmount: const Money(9000),
      rule: RecurrenceRule(
        frequency: RecurrenceFrequency.monthly,
        startDate: const CivilDate(2026, 1, 21),
      ),
    );

    setUp(() {
      seriesRepository = FakeSeriesRepository();
      occurrenceRepository = FakeOccurrenceRepository(seriesRepository);
      seriesRepository.series[series.id] = series;
      service = EditSeriesService(seriesRepository, occurrenceRepository);
    });

    test(
      'persiste a nova revisão e regenera ocorrências futuras não settled',
      () async {
        final openFutureOccurrence = Occurrence(
          seriesId: series.id,
          id: 's1#2026-10-21#10',
          dueDate: const CivilDate(2026, 10, 21),
          expectedAmount: const Money(9000),
          sequenceNumber: 10,
        );
        occurrenceRepository.occurrences[openFutureOccurrence.id] =
            openFutureOccurrence;
        occurrenceRepository.materializedThrough[series.id] = const CivilDate(
          2027,
          1,
          21,
        );

        await service.editSeries(
          series,
          effectiveDate: const CivilDate(2026, 10, 1),
          newBaseAmount: const Money(9500),
          newRule: RecurrenceRule(
            frequency: RecurrenceFrequency.monthly,
            startDate: const CivilDate(2026, 10, 25),
          ),
        );

        final savedSeries = seriesRepository.series[series.id]!;
        expect(savedSeries.revisions, hasLength(1));
        expect(
          savedSeries.revisions.single.baseAmount,
          equals(const Money(9500)),
        );

        // A ocorrência antiga (dia 21) foi descartada; o novo trecho reflete a
        // regra nova (dia 25) a partir da data de efeito.
        expect(
          occurrenceRepository.occurrences.containsKey(openFutureOccurrence.id),
          isFalse,
        );
        expect(
          occurrenceRepository.occurrences.values.any(
            (o) => o.seriesId == series.id && o.dueDate.day == 25,
          ),
          isTrue,
        );
      },
    );

    test('não persiste nada e propaga EditBlockedException quando a edição '
        'eliminaria uma ocorrência já settled', () async {
      final settledOccurrence = Occurrence(
        seriesId: series.id,
        id: 's1#2026-09-21#9',
        dueDate: const CivilDate(2026, 9, 21),
        expectedAmount: const Money(9000),
        sequenceNumber: 9,
        settlement: Settlement(
          paidAmount: const Money(9000),
          paymentDate: const CivilDate(2026, 9, 21),
          recordedAt: DateTime(2026, 9, 21),
        ),
      );
      occurrenceRepository.occurrences[settledOccurrence.id] =
          settledOccurrence;

      await expectLater(
        () => service.editSeries(
          series,
          effectiveDate: const CivilDate(2026, 9, 20),
          newBaseAmount: const Money(9000),
          newRule: RecurrenceRule(
            frequency: RecurrenceFrequency.monthly,
            startDate: const CivilDate(2026, 9, 25),
          ),
        ),
        throwsA(isA<EditBlockedException>()),
      );

      // Nada foi persistido: a série continua sem revisões.
      expect(seriesRepository.series[series.id]!.revisions, isEmpty);
    });
  });
}
