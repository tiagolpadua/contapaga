import 'package:contapaga/features/recurring_bills/domain/civil_date.dart';
import 'package:contapaga/features/recurring_bills/domain/money.dart';
import 'package:contapaga/features/recurring_bills/domain/occurrence.dart';
import 'package:contapaga/features/recurring_bills/domain/recurrence_rule.dart';
import 'package:contapaga/features/recurring_bills/domain/recurring_series.dart';

List<Occurrence> generateOccurrences(
  RecurringSeries serie, {
  required CivilDate desde,
  required CivilDate ate,
}) {
  if (desde.isAfter(ate)) return [];

  // Ordenar chunks pela date de efeito apenas para garantir,
  // embora o domínio diga que já vêm ordenados.
  final chunks = <_SerieChunk>[
    _SerieChunk(
      effectiveDate: serie.rule.startDate,
      rule: serie.rule,
      baseAmount: serie.baseAmount,
    ),
    ...serie.revisions.map(
      (r) => _SerieChunk(
        effectiveDate: r.effectiveDate,
        rule: r.rule,
        baseAmount: r.baseAmount,
      ),
    ),
  ]..sort((a, b) => a.effectiveDate.compareTo(b.effectiveDate));

  var sequenceNumber = 1;
  final occurrences = <Occurrence>[];

  for (var i = 0; i < chunks.length; i++) {
    final chunk = chunks[i];
    final start = chunk.effectiveDate;
    final end = (i + 1 < chunks.length)
        ? chunks[i + 1].effectiveDate.addDays(-1)
        : null;

    final dates = _generateDates(chunk.rule);
    for (final date in dates) {
      if (date.isBefore(start)) {
        continue; // Pertence ao chunk anterior (ou irrelevante)
      }
      if (end != null && date.isAfter(end)) break; // Terminou o chunk

      if (serie.closedAt != null && date.isAfter(serie.closedAt!)) {
        return occurrences
            .where(
              (o) =>
                  o.dueDate.isSameOrAfter(desde) &&
                  o.dueDate.isSameOrBefore(ate),
            )
            .toList();
      }

      // Verifica término da rule do chunk
      if (chunk.rule.endType == EndConditionType.date) {
        if (date.isAfter(chunk.rule.endDate!)) break;
      }

      final seqAtAtual = sequenceNumber;

      // Checa count global. Se for término por count, e já passou da count?
      // Wait, endCount é da REGRA. Se a revisão mudou a count, a contagem recomeça?
      // O plano diz: "a contagem de "count" considera ocorrências geradas ... não reinicia"
      // Se a rule diz endCount = 10, e estamos na seq = 11, acabou.
      if (chunk.rule.endType == EndConditionType.count) {
        if (seqAtAtual > chunk.rule.endCount!) break;
      }

      if (date.isSameOrAfter(desde) && date.isSameOrBefore(ate)) {
        final dataFormatada =
            "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

        occurrences.add(
          Occurrence(
            seriesId: serie.id,
            id: '${serie.id}#$dataFormatada#$seqAtAtual',
            dueDate: date,
            expectedAmount: chunk.baseAmount,
            sequenceNumber: seqAtAtual,
            autoDebit: serie.autoDebit,
          ),
        );
      }

      sequenceNumber++;

      // Se já passamos do `ate` e não precisamos contar sequências adicionais,
      // podemos parar? Não, porque a próxima ocorrência gerada já vai estar > ate
      // (pois _generateDates produz datas estritamente crescentes).
      if (date.isAfter(ate)) {
        // We can safely break because any further dates in this chunk will be > ate
        // AND any further chunks will have effectiveDate > ate, so they will also be > ate.
        return occurrences;
      }
    }
  }

  return occurrences;
}

class _SerieChunk {
  new({
    required this.effectiveDate,
    required this.rule,
    required this.baseAmount,
  });
  final CivilDate effectiveDate;
  final RecurrenceRule rule;
  final Money baseAmount;
}

Iterable<CivilDate> _generateDates(RecurrenceRule rule) sync* {
  var iter = 0;

  if (rule.frequency == RecurrenceFrequency.weekly) {
    final diff = rule.startDate.weekday - 1;
    final monday = rule.startDate.addDays(-diff);

    while (true) {
      final baseMonday = monday.addDays(iter * rule.interval * 7);
      for (var d = 1; d <= 7; d++) {
        if (rule.weekdays.contains(d)) {
          final candidate = baseMonday.addDays(d - 1);
          if (candidate.isSameOrAfter(rule.startDate)) {
            yield candidate;
          }
        }
      }
      iter++;
    }
  } else {
    while (true) {
      switch (rule.frequency) {
        case RecurrenceFrequency.daily:
          yield rule.startDate.addDays(iter * rule.interval);
        case RecurrenceFrequency.monthly:
          // mês base = startDate + (iter * interval)
          // usamos aritmética de anos/meses para não depender do addMonths e ser mais direto
          final rawMonth = rule.startDate.month + (iter * rule.interval);
          final additionalYears = (rawMonth - 1) ~/ 12;
          final finalMonth = ((rawMonth - 1) % 12) + 1;
          final finalYear = rule.startDate.year + additionalYears;

          yield CivilDate(
            finalYear,
            finalMonth,
            rule.effectiveDayInMonth(finalYear, finalMonth),
          );
        case RecurrenceFrequency.yearly:
          final finalYear = rule.startDate.year + (iter * rule.interval);
          final finalMonth = rule.startDate.month;
          yield CivilDate(
            finalYear,
            finalMonth,
            rule.effectiveDayInMonth(finalYear, finalMonth),
          );
        case RecurrenceFrequency.weekly: // handled above
          break;
      }
      iter++;
    }
  }
}
