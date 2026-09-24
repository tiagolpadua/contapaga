import 'package:contapaga/core/time/clock.dart';
import 'package:contapaga/features/recurring_bills/domain/civil_date.dart';
import 'package:contapaga/features/recurring_bills/domain/money.dart';
import 'package:contapaga/features/recurring_bills/domain/occurrence.dart';
import 'package:contapaga/features/recurring_bills/domain/settlement.dart';

Occurrence settleOccurrence(
  Occurrence ocorrencia, {
  required Money paidAmount,
  required CivilDate paymentDate,
  required Clock clock,
}) {
  if (ocorrencia.settlement != null) {
    throw StateError('A ocorrência já possui uma settlement.');
  }

  if (paidAmount <= const Money(0)) {
    throw ArgumentError('O valor pago deve ser maior que zero.');
  }

  final hoje = CivilDate.hoje(clock);
  if (paymentDate.isAfter(hoje)) {
    throw ArgumentError('A date de pagamento não pode ser no futuro.');
  }

  final settlement = Settlement(
    paidAmount: paidAmount,
    paymentDate: paymentDate,
    recordedAt: clock.now(),
  );

  return ocorrencia.copyWithSettlement(settlement);
}

Occurrence revertSettlement(Occurrence ocorrencia) {
  if (ocorrencia.settlement == null) {
    throw StateError('A ocorrência não possui settlement para reverter.');
  }
  return ocorrencia.copyWithSettlement(null);
}
