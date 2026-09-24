import 'package:contapaga/features/recurring_bills/domain/civil_date.dart';
import 'package:contapaga/features/recurring_bills/domain/money.dart';
import 'package:contapaga/features/recurring_bills/domain/recurrence_rule.dart';
import 'package:contapaga/features/recurring_bills/domain/recurring_series.dart';
import 'package:contapaga/features/recurring_bills/domain/series_revision.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RecurringSeries.revisionInEffectOn', () {
    final regraOriginal = RecurrenceRule(
      frequency: RecurrenceFrequency.monthly,
      startDate: const CivilDate(2026, 1, 10),
    );

    test('sem revisions, retorna sempre a rule original', () {
      final series = RecurringSeries(
        id: 's1',
        description: 'Internet',
        type: EntryType.expense,
        autoDebit: false,
        baseAmount: const Money(9000),
        rule: regraOriginal,
      );

      final inEffect = series.revisionInEffectOn(const CivilDate(2026, 12, 1));
      expect(inEffect.rule, same(regraOriginal));
      expect(inEffect.baseAmount, equals(const Money(9000)));
    });

    test('antes da primeira revisao usa a rule original', () {
      final novaRegra = RecurrenceRule(
        frequency: RecurrenceFrequency.monthly,
        startDate: const CivilDate(2026, 6, 15),
      );
      final series = RecurringSeries(
        id: 's1',
        description: 'Internet',
        type: EntryType.expense,
        autoDebit: false,
        baseAmount: const Money(9000),
        rule: regraOriginal,
        revisions: [
          SeriesRevision(
            effectiveDate: const CivilDate(2026, 6, 10),
            baseAmount: const Money(9500),
            rule: novaRegra,
          ),
        ],
      );

      final inEffectBefore = series.revisionInEffectOn(
        const CivilDate(2026, 5, 1),
      );
      expect(inEffectBefore.rule, same(regraOriginal));
      expect(inEffectBefore.baseAmount, equals(const Money(9000)));
    });

    test('na date de efeito e after, usa a revisao (edicao prospectiva)', () {
      final novaRegra = RecurrenceRule(
        frequency: RecurrenceFrequency.monthly,
        startDate: const CivilDate(2026, 6, 15),
      );
      final series = RecurringSeries(
        id: 's1',
        description: 'Internet',
        type: EntryType.expense,
        autoDebit: false,
        baseAmount: const Money(9000),
        rule: regraOriginal,
        revisions: [
          SeriesRevision(
            effectiveDate: const CivilDate(2026, 6, 10),
            baseAmount: const Money(9500),
            rule: novaRegra,
          ),
        ],
      );

      final onDate = series.revisionInEffectOn(const CivilDate(2026, 6, 10));
      expect(onDate.baseAmount, equals(const Money(9500)));

      final after = series.revisionInEffectOn(const CivilDate(2026, 12, 1));
      expect(after.baseAmount, equals(const Money(9500)));
    });

    test('com multiplas revisions, escolhe a mais recente aplicavel', () {
      final regraJulho = RecurrenceRule(
        frequency: RecurrenceFrequency.monthly,
        startDate: const CivilDate(2026, 7, 1),
      );
      final regraSetembro = RecurrenceRule(
        frequency: RecurrenceFrequency.monthly,
        startDate: const CivilDate(2026, 9, 1),
      );
      final series = RecurringSeries(
        id: 's1',
        description: 'Internet',
        type: EntryType.expense,
        autoDebit: false,
        baseAmount: const Money(9000),
        rule: regraOriginal,
        revisions: [
          SeriesRevision(
            effectiveDate: const CivilDate(2026, 7, 1),
            baseAmount: const Money(9500),
            rule: regraJulho,
          ),
          SeriesRevision(
            effectiveDate: const CivilDate(2026, 9, 1),
            baseAmount: const Money(9800),
            rule: regraSetembro,
          ),
        ],
      );

      expect(
        series.revisionInEffectOn(const CivilDate(2026, 8, 1)).baseAmount,
        equals(const Money(9500)),
      );
      expect(
        series.revisionInEffectOn(const CivilDate(2026, 10, 1)).baseAmount,
        equals(const Money(9800)),
      );
    });
  });
}
