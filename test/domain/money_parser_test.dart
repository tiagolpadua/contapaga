import 'package:contapaga/features/recorrencias/domain/money.dart';
import 'package:contapaga/features/recorrencias/domain/util/money_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MoneyParser', () {
    test('formato com milhar e centavos', () {
      expect(MoneyParser.tryParsePtBr('1.234,56'), equals(const Money(123456)));
      expect(
        MoneyParser.tryParsePtBr('1.234.567,89'),
        equals(const Money(123456789)),
      );
    });

    test('sem ponto de milhar', () {
      expect(MoneyParser.tryParsePtBr('1234,56'), equals(const Money(123456)));
      expect(MoneyParser.tryParsePtBr('0,50'), equals(const Money(50)));
    });

    test('sem decimais', () {
      expect(MoneyParser.tryParsePtBr('1.234'), equals(const Money(123400)));
      expect(MoneyParser.tryParsePtBr('1234'), equals(const Money(123400)));
    });

    test('um decimal', () {
      expect(MoneyParser.tryParsePtBr('10,5'), equals(const Money(1050)));
    });

    test(r'com R$ e espaços', () {
      expect(MoneyParser.tryParsePtBr(r'R$ 1.234,56'), equals(const Money(123456)));
      expect(MoneyParser.tryParsePtBr('  10,00  '), equals(const Money(1000)));
    });

    test('negativos', () {
      expect(MoneyParser.tryParsePtBr('-1.234,56'), equals(const Money(-123456)));
      expect(MoneyParser.tryParsePtBr('-0,50'), equals(const Money(-50)));
    });

    test('inválidos retornam null', () {
      expect(MoneyParser.tryParsePtBr('abc'), isNull);
      expect(MoneyParser.tryParsePtBr('10,567'), isNull); // mais de 2 decimais
      expect(MoneyParser.tryParsePtBr('1,2,3'), isNull);
      expect(MoneyParser.tryParsePtBr(''), isNull);
    });
  });
}
