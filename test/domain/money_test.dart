import 'package:contapaga/features/recurring_bills/domain/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Money', () {
    test('criação básica e propriedades', () {
      const m1 = Money(100);
      const m2 = Money(-50);
      const m3 = Money(0);

      expect(m1.cents, 100);
      expect(m1.isNegative, isFalse);
      expect(m1.isZero, isFalse);

      expect(m2.isNegative, isTrue);
      expect(m2.isZero, isFalse);

      expect(m3.isNegative, isFalse);
      expect(m3.isZero, isTrue);
    });

    test('operadores matemáticos', () {
      const m1 = Money(100);
      const m2 = Money(50);

      expect((m1 + m2).cents, 150);
      expect((m1 - m2).cents, 50);
      expect((-m1).cents, -100);
    });

    test('igualdade e hashcode', () {
      const m1 = Money(100);
      const m2 = Money(100);
      const m3 = Money(200);

      expect(m1, equals(m2));
      expect(m1, isNot(equals(m3)));
      expect(m1.hashCode, equals(m2.hashCode));
    });

    test('comparação', () {
      const m1 = Money(100);
      const m2 = Money(200);
      const m3 = Money(100);

      expect(m1 < m2, isTrue);
      expect(m2 > m1, isTrue);
      expect(m1 <= m3, isTrue);
      expect(m1 >= m3, isTrue);

      final list = [m2, m1]..sort();
      expect(list.first, equals(m1));
    });

    test('arredondamento de meio centavo para cima (averageRoundedHalfUp)', () {
      // R$ 1,00 + R$ 1,00 + R$ 1,01 -> média R$ 1,0033... -> arredonda para R$ 1,00
      const m1 = Money(100);
      const m2 = Money(100);
      const m3 = Money(101);

      expect(Money.averageRoundedHalfUp([m1, m2, m3]).cents, 100);

      // R$ 1,00 + R$ 1,01 -> média R$ 1,005 -> arredonda para cima -> R$ 1,01
      expect(Money.averageRoundedHalfUp([m1, m3]).cents, 101);

      // Valores maiores
      expect(
        Money.averageRoundedHalfUp([const Money(105), const Money(100)]).cents,
        103,
      );

      // Zero
      expect(
        Money.averageRoundedHalfUp([const Money(0), const Money(0)]).cents,
        0,
      );

      // Negativos
      // -3 / 2 = -1.5 -> arredonda half up -> -1
      expect(
        Money.averageRoundedHalfUp([const Money(-1), const Money(-2)]).cents,
        -1,
      );
    });

    test('averageRoundedHalfUp rejeita lista vazia', () {
      expect(() => Money.averageRoundedHalfUp([]), throwsArgumentError);
    });
  });
}
