import 'package:contapaga/core/time/clock.dart';
import 'package:contapaga/features/recorrencias/domain/civil_date.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeClock implements Clock {
  const new(this._now);
  final DateTime _now;

  @override
  DateTime now() => _now;
}

void main() {
  group('CivilDate', () {
    test('criação básica e validação', () {
      const d1 = CivilDate(2026, 9, 16);
      expect(d1.year, 2026);
      expect(d1.month, 9);
      expect(d1.day, 16);

      expect(() => CivilDate(2026, 13, 1), throwsA(isA<AssertionError>()));
      expect(() => CivilDate(2026, 0, 1), throwsA(isA<AssertionError>()));
      expect(() => CivilDate(2026, 9, 32), throwsA(isA<AssertionError>()));
      expect(() => CivilDate(2026, 9, 0), throwsA(isA<AssertionError>()));
    });

    test('validação rigorosa de dias no mês (validated)', () {
      expect(() => CivilDate.validated(2026, 2, 29), throwsArgumentError);
      expect(() => CivilDate.validated(2024, 2, 29), returnsNormally);
      expect(() => CivilDate.validated(2026, 4, 31), throwsArgumentError);
      expect(() => CivilDate.validated(2026, 4, 30), returnsNormally);
    });

    test('CivilDate.hoje e fromDate', () {
      final clock = FakeClock(DateTime(2026, 9, 16, 15, 30));
      final d1 = CivilDate.hoje(clock);
      expect(d1, equals(const CivilDate(2026, 9, 16)));

      final d2 = CivilDate.fromDate(DateTime(2026, 10, 5, 23, 59));
      expect(d2, equals(const CivilDate(2026, 10, 5)));
    });

    test('addDays atravessando meses', () {
      const d1 = CivilDate(2026, 9, 30);
      expect(d1.addDays(1), equals(const CivilDate(2026, 10, 1)));

      const d2 = CivilDate(2026, 2, 28);
      expect(d2.addDays(1), equals(const CivilDate(2026, 3, 1)));

      const d3 = CivilDate(2024, 2, 28);
      expect(d3.addDays(1), equals(const CivilDate(2024, 2, 29)));
      expect(d3.addDays(2), equals(const CivilDate(2024, 3, 1)));
    });

    test('addMonths com cap de dias inexistentes', () {
      // 31/01 -> +1 mes -> 28/02
      const d1 = CivilDate(2026, 1, 31);
      expect(d1.addMonths(1), equals(const CivilDate(2026, 2, 28)));

      // 31/01/2024 -> +1 mes -> 29/02
      const d2 = CivilDate(2024, 1, 31);
      expect(d2.addMonths(1), equals(const CivilDate(2024, 2, 29)));

      // 30/11 -> +1 mes -> 30/12
      const d3 = CivilDate(2026, 11, 30);
      expect(d3.addMonths(1), equals(const CivilDate(2026, 12, 30)));

      // 15/12 -> +1 mes -> 15/01/2027 (virada de ano)
      const d4 = CivilDate(2026, 12, 15);
      expect(d4.addMonths(1), equals(const CivilDate(2027, 1, 15)));
    });

    test('addYears com regra 29/02', () {
      const d1 = CivilDate(2024, 2, 29);
      expect(d1.addYears(1), equals(const CivilDate(2025, 2, 28)));
      expect(d1.addYears(4), equals(const CivilDate(2028, 2, 29)));
    });

    test('comparações e ordenação', () {
      const d1 = CivilDate(2026, 9, 15);
      const d2 = CivilDate(2026, 9, 16);
      const d3 = CivilDate(2026, 10, 1);

      expect(d1.isBefore(d2), isTrue);
      expect(d2.isAfter(d1), isTrue);
      expect(d1.isSameOrBefore(d1), isTrue);

      final list = [d3, d1, d2]..sort();
      expect(list, equals([d1, d2, d3]));
    });

    test('weekday', () {
      // 16/09/2026 é uma quarta-feira (3)
      const d1 = CivilDate(2026, 9, 16);
      expect(d1.weekday, 3);

      // 14/09/2026 é segunda-feira (1)
      const d2 = CivilDate(2026, 9, 14);
      expect(d2.weekday, 1);
    });
  });
}
