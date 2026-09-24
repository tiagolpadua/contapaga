import 'package:contapaga/features/recurring_bills/domain/civil_date.dart';
import 'package:contapaga/features/recurring_bills/domain/recurrence_rule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RecurrenceRule', () {
    const dBase = CivilDate(2026, 9, 16);

    test('valida interval', () {
      expect(
        () => RecurrenceRule(
          frequency: RecurrenceFrequency.daily,
          interval: 0,
          startDate: dBase,
        ),
        throwsArgumentError,
      );
    });

    test('valida weekly com dias da semana vazios', () {
      expect(
        () => RecurrenceRule(
          frequency: RecurrenceFrequency.weekly,
          weekdays: {},
          startDate: dBase,
        ),
        throwsArgumentError,
      );

      // Deve aceitar se tiver dia
      expect(
        () => RecurrenceRule(
          frequency: RecurrenceFrequency.weekly,
          weekdays: {1},
          startDate: dBase,
        ),
        returnsNormally,
      );
    });

    test('valida endType', () {
      // Nunca, com date ou count
      expect(
        () => RecurrenceRule(
          frequency: RecurrenceFrequency.monthly,
          startDate: dBase,
          endCount: 5,
        ),
        throwsArgumentError,
      );

      // Data, sem date
      expect(
        () => RecurrenceRule(
          frequency: RecurrenceFrequency.monthly,
          startDate: dBase,
          endType: EndConditionType.date,
        ),
        throwsArgumentError,
      );

      // Quantidade, sem count
      expect(
        () => RecurrenceRule(
          frequency: RecurrenceFrequency.monthly,
          startDate: dBase,
          endType: EndConditionType.count,
        ),
        throwsArgumentError,
      );
    });

    test('effectiveDayInMonth', () {
      final regra31 = RecurrenceRule(
        frequency: RecurrenceFrequency.monthly,
        startDate: const CivilDate(2026, 1, 31),
      );

      // 2026 não é bissexto
      expect(regra31.effectiveDayInMonth(2026, 2), 28);
      expect(regra31.effectiveDayInMonth(2026, 3), 31);
      expect(regra31.effectiveDayInMonth(2026, 4), 30);

      // 2024 é bissexto
      expect(regra31.effectiveDayInMonth(2024, 2), 29);
    });

    test('effectiveDayInMonth yearly 29/02', () {
      final regra29Feb = RecurrenceRule(
        frequency: RecurrenceFrequency.yearly,
        startDate: const CivilDate(2024, 2, 29),
      );

      expect(regra29Feb.effectiveDayInMonth(2025, 2), 28);
      expect(regra29Feb.effectiveDayInMonth(2028, 2), 29);
    });
  });
}
