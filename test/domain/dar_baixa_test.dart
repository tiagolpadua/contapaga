import 'package:contapaga/core/time/clock.dart';
import 'package:contapaga/features/recorrencias/domain/casos_uso/dar_baixa.dart';
import 'package:contapaga/features/recorrencias/domain/civil_date.dart';
import 'package:contapaga/features/recorrencias/domain/money.dart';
import 'package:contapaga/features/recorrencias/domain/ocorrencia.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeClock implements Clock {
  const new(this._now);
  final DateTime _now;

  @override
  DateTime now() => _now;
}

void main() {
  group('dar_baixa e reverter_baixa', () {
    final clock = FakeClock(DateTime(2026, 9, 16, 12));

    final o = Ocorrencia(
      serieId: 's1',
      id: 's1#1',
      dataVencimento: const CivilDate(2026, 9, 10),
      valorPrevisto: const Money(100),
      sequencia: 1,
    );

    test('baixa com sucesso', () {
      final baixada = darBaixa(
        o,
        valorPago: const Money(120),
        dataPagamento: const CivilDate(2026, 9, 11),
        clock: clock,
      );

      expect(baixada.baixa, isNotNull);
      expect(baixada.baixa!.valorPago, equals(const Money(120)));
      expect(baixada.baixa!.dataPagamento, equals(const CivilDate(2026, 9, 11)));
      expect(baixada.status(clock), equals(StatusOcorrencia.baixada));
      // Verifica que o ID original foi mantido
      expect(baixada.id, equals(o.id));
    });

    test('reverter baixa', () {
      final baixada = darBaixa(
        o,
        valorPago: const Money(120),
        dataPagamento: const CivilDate(2026, 9, 11),
        clock: clock,
      );

      final revertida = reverterBaixa(baixada);
      expect(revertida.baixa, isNull);
      expect(
        revertida.status(clock),
        equals(StatusOcorrencia.atrasada),
      ); // 10/09 < 16/09
      expect(revertida.id, equals(o.id));
    });

    test('bloqueia baixa em ocorrencia já baixada', () {
      final baixada = darBaixa(
        o,
        valorPago: const Money(120),
        dataPagamento: const CivilDate(2026, 9, 11),
        clock: clock,
      );

      expect(
        () => darBaixa(
          baixada,
          valorPago: const Money(10),
          dataPagamento: const CivilDate(2026, 9, 11),
          clock: clock,
        ),
        throwsStateError,
      );
    });

    test('bloqueia data de pagamento no futuro', () {
      expect(
        () => darBaixa(
          o,
          valorPago: const Money(10),
          dataPagamento: const CivilDate(2026, 9, 17),
          clock: clock,
        ),
        throwsArgumentError,
      );
    });

    test('bloqueia valor pago zero ou negativo', () {
      expect(
        () => darBaixa(
          o,
          valorPago: const Money(0),
          dataPagamento: const CivilDate(2026, 9, 16),
          clock: clock,
        ),
        throwsArgumentError,
      );
      expect(
        () => darBaixa(
          o,
          valorPago: const Money(-10),
          dataPagamento: const CivilDate(2026, 9, 16),
          clock: clock,
        ),
        throwsArgumentError,
      );
    });

    test('reverter ocorrencia não baixada falha', () {
      expect(() => reverterBaixa(o), throwsStateError);
    });
  });
}
