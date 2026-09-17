import 'package:contapaga/features/recorrencias/domain/competencia.dart';
import 'package:contapaga/features/recorrencias/domain/civil_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Competencia', () {
    test('criação básica', () {
      final c = Competencia(2026, 9);
      expect(c.ano, 2026);
      expect(c.mes, 9);
    });

    test('fromDate', () {
      final d = CivilDate(2026, 9, 16);
      final c = Competencia.fromDate(d);
      expect(c.ano, 2026);
      expect(c.mes, 9);
    });

    test('previous e next (mes normal)', () {
      final c = Competencia(2026, 9);
      expect(c.previous(), equals(Competencia(2026, 8)));
      expect(c.next(), equals(Competencia(2026, 10)));
    });

    test('previous e next (virada de ano)', () {
      final c1 = Competencia(2026, 1);
      expect(c1.previous(), equals(Competencia(2025, 12)));

      final c2 = Competencia(2026, 12);
      expect(c2.next(), equals(Competencia(2027, 1)));
    });

    test('precedentes(6)', () {
      final c = Competencia(2026, 9);
      final lista = c.precedentes(6);
      
      expect(lista.length, 6);
      expect(lista, equals([
        Competencia(2026, 8),
        Competencia(2026, 7),
        Competencia(2026, 6),
        Competencia(2026, 5),
        Competencia(2026, 4),
        Competencia(2026, 3),
      ]));
    });

    test('precedentes cruzando o ano', () {
      final c = Competencia(2026, 2);
      final lista = c.precedentes(3);
      
      expect(lista, equals([
        Competencia(2026, 1),
        Competencia(2025, 12),
        Competencia(2025, 11),
      ]));
    });

    test('comparações', () {
      final c1 = Competencia(2026, 8);
      final c2 = Competencia(2026, 9);
      final c3 = Competencia(2027, 1);

      expect(c1.isBefore(c2), isTrue);
      expect(c2.isAfter(c1), isTrue);
      expect(c1.isBefore(c3), isTrue);
      expect(c3.isAfter(c1), isTrue);
      
      final list = [c3, c1, c2];
      list.sort();
      expect(list, equals([c1, c2, c3]));
    });
  });
}
