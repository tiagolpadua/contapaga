import 'package:contapaga/core/time/clock.dart';
import 'package:contapaga/features/recurring_bills/domain/civil_date.dart';
import 'package:contapaga/features/recurring_bills/domain/competency_period.dart';
import 'package:contapaga/features/recurring_bills/domain/money.dart';
import 'package:contapaga/features/recurring_bills/domain/settlement.dart';

enum OccurrenceStatus { open, settled, overdue, pendingAutoDebit }

class Occurrence {
  new({
    required this.seriesId,
    required this.id,
    required this.dueDate,
    required this.expectedAmount,
    required this.sequenceNumber,
    this.settlement,
    this.autoDebit = false,
  });
  final String seriesId;
  final String id;
  final CivilDate dueDate;
  final Money expectedAmount;
  final int sequenceNumber; // 1-based index na série
  final Settlement? settlement;
  final bool autoDebit;

  CompetencyPeriod get competencyPeriod => CompetencyPeriod.fromDate(dueDate);

  OccurrenceStatus status(Clock clock) {
    if (settlement != null) {
      return OccurrenceStatus.settled;
    }

    final hoje = CivilDate.hoje(clock);
    if (dueDate.isBefore(hoje)) {
      return autoDebit
          ? OccurrenceStatus.pendingAutoDebit
          : OccurrenceStatus.overdue;
    }

    return OccurrenceStatus.open;
  }

  Occurrence copyWithSettlement(Settlement? novaBaixa) {
    return Occurrence(
      seriesId: seriesId,
      id: id,
      dueDate: dueDate,
      expectedAmount: expectedAmount,
      sequenceNumber: sequenceNumber,
      settlement: novaBaixa,
      autoDebit: autoDebit,
    );
  }
}
