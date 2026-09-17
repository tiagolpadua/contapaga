import 'package:contapaga/features/recorrencias/domain/civil_date.dart';
import 'package:contapaga/features/recorrencias/domain/competencia.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Competencia', () {
    test('criação básica', () {
      const c = Competencia(2026, 9);
      expect(c.ano, 2026);
      expect(c.mes, 9);
    });

    test('fromDate', () {
      const d = CivilDate(2026, 9, 16);
      final c = Competencia.fromDate(d);
      expect(c.ano, 2026);
      expect(c.mes, 9);
    });

    test('previous e next (mes normal)', () {
      const c = Competencia(2026, 9);
      expect(c.previous(), equals(const Competencia(2026, 8)));
      expect(c.next(), equals(const Competencia(2026, 10)));
    });

    test('previous e next (virada de ano)', () {
      const c1 = Competencia(2026, 1);
      expect(c1.previous(), equals(const Competencia(2025, 12)));

      const c2 = Competencia(2026, 12);
      expect(c2.next(), equals(const Competencia(2027, 1)));
    });

    test('precedentes(6)', () {
      const c = Competencia(2026, 9);
      final lista = c.precedentes(6);

      expect(lista.length, 6);
      expect(
        lista,
        equals([
          const Competencia(2026, 8),
          const Competencia(2026, 7),
          const Competencia(2026, 6),
          const Competencia(2026, 5),
          const Competencia(2026, 4),
          const Competencia(2026, 3),
        ]),
      );
    });

    test('precedentes cruzando o ano', () {
      const c = Competencia(2026, 2);
      final lista = c.precedentes(3);

      expect(
        lista,
        equals([
          const Competencia(2026, 1),
          const Competencia(2025, 12),
          const Competencia(2025, 11),
        ]),
      );
    });

    test('comparações', () {
      const c1 = Competencia(2026, 8);
      const c2 = Competencia(2026, 9);
      const c3 = Competencia(2027, 1);

      expect(c1.isBefore(c2), isTrue);
      expect(c2.isAfter(c1), isTrue);
      expect(c1.isBefore(c3), isTrue);
      expect(c3.isAfter(c1), isTrue);

      final list = [c3, c1, c2]..sort();
      expect(list, equals([c1, c2, c3]));
    });
  });
}
