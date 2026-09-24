import 'package:contapaga/features/recurring_bills/domain/civil_date.dart';
import 'package:contapaga/features/recurring_bills/domain/competency_period.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CompetencyPeriod', () {
    test('criação básica', () {
      const c = CompetencyPeriod(2026, 9);
      expect(c.year, 2026);
      expect(c.month, 9);
    });

    test('fromDate', () {
      const d = CivilDate(2026, 9, 16);
      final c = CompetencyPeriod.fromDate(d);
      expect(c.year, 2026);
      expect(c.month, 9);
    });

    test('previous e next (month normal)', () {
      const c = CompetencyPeriod(2026, 9);
      expect(c.previous(), equals(const CompetencyPeriod(2026, 8)));
      expect(c.next(), equals(const CompetencyPeriod(2026, 10)));
    });

    test('previous e next (virada de year)', () {
      const c1 = CompetencyPeriod(2026, 1);
      expect(c1.previous(), equals(const CompetencyPeriod(2025, 12)));

      const c2 = CompetencyPeriod(2026, 12);
      expect(c2.next(), equals(const CompetencyPeriod(2027, 1)));
    });

    test('preceding(6)', () {
      const c = CompetencyPeriod(2026, 9);
      final lista = c.preceding(6);

      expect(lista.length, 6);
      expect(
        lista,
        equals([
          const CompetencyPeriod(2026, 8),
          const CompetencyPeriod(2026, 7),
          const CompetencyPeriod(2026, 6),
          const CompetencyPeriod(2026, 5),
          const CompetencyPeriod(2026, 4),
          const CompetencyPeriod(2026, 3),
        ]),
      );
    });

    test('preceding cruzando o year', () {
      const c = CompetencyPeriod(2026, 2);
      final lista = c.preceding(3);

      expect(
        lista,
        equals([
          const CompetencyPeriod(2026, 1),
          const CompetencyPeriod(2025, 12),
          const CompetencyPeriod(2025, 11),
        ]),
      );
    });

    test('comparações', () {
      const c1 = CompetencyPeriod(2026, 8);
      const c2 = CompetencyPeriod(2026, 9);
      const c3 = CompetencyPeriod(2027, 1);

      expect(c1.isBefore(c2), isTrue);
      expect(c2.isAfter(c1), isTrue);
      expect(c1.isBefore(c3), isTrue);
      expect(c3.isAfter(c1), isTrue);

      final list = [c3, c1, c2]..sort();
      expect(list, equals([c1, c2, c3]));
    });
  });
}
