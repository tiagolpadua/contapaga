import 'package:contapaga/features/recorrencias/domain/civil_date.dart';
import 'package:contapaga/features/recorrencias/domain/money.dart';

class Baixa {
  final Money valorPago;
  final CivilDate dataPagamento;
  final DateTime registradoEm;

  Baixa({
    required this.valorPago,
    required this.dataPagamento,
    required this.registradoEm,
  }) {
    if (valorPago <= Money(0)) {
      throw ArgumentError('O valor pago deve ser maior que zero.');
    }
  }
}
