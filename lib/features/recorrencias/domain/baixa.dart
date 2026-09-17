import 'package:contapaga/features/recorrencias/domain/civil_date.dart';
import 'package:contapaga/features/recorrencias/domain/money.dart';

class Baixa {

  new({
    required this.valorPago,
    required this.dataPagamento,
    required this.registradoEm,
  }) {
    if (valorPago <= const Money(0)) {
      throw ArgumentError('O valor pago deve ser maior que zero.');
    }
  }
  final Money valorPago;
  final CivilDate dataPagamento;
  final DateTime registradoEm;
}
