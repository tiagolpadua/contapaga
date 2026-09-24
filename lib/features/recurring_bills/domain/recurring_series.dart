import 'package:contapaga/features/recurring_bills/domain/civil_date.dart';
import 'package:contapaga/features/recurring_bills/domain/money.dart';
import 'package:contapaga/features/recurring_bills/domain/recurrence_rule.dart';
import 'package:contapaga/features/recurring_bills/domain/series_revision.dart';

enum EntryType { income, expense }

class RecurringSeries {
  const new({
    required this.id,
    required this.description,
    required this.type,
    required this.autoDebit,
    required this.baseAmount,
    required this.rule,
    this.counterparty,
    this.revisions = const [],
    this.closedAt,
  });
  final String id;
  final String description;
  final EntryType type;
  final String? counterparty;
  final bool autoDebit;
  final Money baseAmount;
  final RecurrenceRule rule;
  final List<SeriesRevision> revisions;
  final CivilDate? closedAt;

  RecurringSeries copyWithInternal({
    String? description,
    String? counterparty,
    bool? autoDebit,
    Money? baseAmount,
    RecurrenceRule? rule,
    List<SeriesRevision>? revisions,
    CivilDate? closedAt,
  }) {
    return RecurringSeries(
      id: id,
      description: description ?? this.description,
      type: type,
      counterparty: counterparty ?? this.counterparty,
      autoDebit: autoDebit ?? this.autoDebit,
      baseAmount: baseAmount ?? this.baseAmount,
      rule: rule ?? this.rule,
      revisions: revisions ?? this.revisions,
      closedAt: closedAt ?? this.closedAt,
    );
  }

  /// Retorna a rule de recorrência e o valor base vigentes para uma determinada date.
  /// Percorre as revisões de trás pra frente (assumindo que estão em ordem cronológica de `effectiveDate`).
  SeriesRevision revisionInEffectOn(CivilDate date) {
    if (revisions.isEmpty) {
      return SeriesRevision(
        effectiveDate: rule.startDate,
        rule: rule,
        baseAmount: baseAmount,
      );
    }

    // Assume que as revisões estão ordenadas por effectiveDate crescente.
    for (var i = revisions.length - 1; i >= 0; i--) {
      final r = revisions[i];
      if (r.effectiveDate.isSameOrBefore(date)) {
        return r;
      }
    }

    return SeriesRevision(
      effectiveDate: rule.startDate,
      rule: rule,
      baseAmount: baseAmount,
    );
  }
}
