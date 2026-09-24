import 'package:contapaga/features/recurring_bills/domain/civil_date.dart';
import 'package:contapaga/features/recurring_bills/domain/money.dart';

class Settlement {
  new({
    required this.paidAmount,
    required this.paymentDate,
    required this.recordedAt,
  }) {
    if (paidAmount <= const Money(0)) {
      throw ArgumentError('O valor pago deve ser maior que zero.');
    }
  }
  final Money paidAmount;
  final CivilDate paymentDate;
  final DateTime recordedAt;
}
