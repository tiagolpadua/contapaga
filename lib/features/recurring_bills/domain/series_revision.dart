import 'package:contapaga/features/recurring_bills/domain/civil_date.dart';
import 'package:contapaga/features/recurring_bills/domain/money.dart';
import 'package:contapaga/features/recurring_bills/domain/recurrence_rule.dart';

class SeriesRevision {
  const new({
    required this.effectiveDate,
    required this.rule,
    required this.baseAmount,
  });
  final CivilDate effectiveDate;
  final RecurrenceRule rule;
  final Money baseAmount;
}
