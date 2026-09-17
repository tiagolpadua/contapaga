import 'package:contapaga/core/time/clock.dart';
import 'package:contapaga/features/recorrencias/domain/baixa.dart';
import 'package:contapaga/features/recorrencias/domain/civil_date.dart';
import 'package:contapaga/features/recorrencias/domain/money.dart';
import 'package:contapaga/features/recorrencias/domain/ocorrencia.dart';

Ocorrencia darBaixa(
  Ocorrencia ocorrencia, {
  required Money valorPago,
  required CivilDate dataPagamento,
  required Clock clock,
}) {
  if (ocorrencia.baixa != null) {
    throw StateError('A ocorrência já possui uma baixa.');
  }

  if (valorPago <= const Money(0)) {
    throw ArgumentError('O valor pago deve ser maior que zero.');
  }

  final hoje = CivilDate.hoje(clock);
  if (dataPagamento.isAfter(hoje)) {
    throw ArgumentError('A data de pagamento não pode ser no futuro.');
  }

  final baixa = Baixa(
    valorPago: valorPago,
    dataPagamento: dataPagamento,
    registradoEm: clock.now(),
  );

  return ocorrencia.copyWithBaixa(baixa);
}

Ocorrencia reverterBaixa(Ocorrencia ocorrencia) {
  if (ocorrencia.baixa == null) {
    throw StateError('A ocorrência não possui baixa para reverter.');
  }
  return ocorrencia.copyWithBaixa(null);
}
