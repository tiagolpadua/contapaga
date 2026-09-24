import 'package:contapaga/features/recurring_bills/domain/civil_date.dart';
import 'package:contapaga/features/recurring_bills/domain/money.dart';
import 'package:contapaga/features/recurring_bills/domain/occurrence.dart';
import 'package:contapaga/features/recurring_bills/domain/occurrence_generation.dart';
import 'package:contapaga/features/recurring_bills/domain/recurrence_rule.dart';
import 'package:contapaga/features/recurring_bills/domain/recurring_series.dart';
import 'package:contapaga/features/recurring_bills/domain/series_revision.dart';

/// Lançada quando uma edição prospectiva eliminaria histórico já registrado:
/// uma ocorrência já settled, ou reduziria a count de término abaixo do
/// que já foi preservado (baixado ou aberto) antes da date de efeito.
class EditBlockedException implements Exception {
  new(this.message);
  final String message;

  @override
  String toString() => 'EditBlockedException: $message';
}

/// Horizonte usado para verificar se a nova rule preserva o histórico.
/// Suficiente para cobrir qualquer combinação de frequência/interval
/// praticada pela v1 (fase 0: sem exceções de calendário avançadas).
const _horizonteVerificacao = Duration(days: 366 * 5);

/// Cria uma nova revisão prospectiva para a série, válida a partir de
/// `effectiveDate`. Bloqueia a edição (fase 0) quando a nova rule eliminaria
/// uma ocorrência já settled, ou reduziria `endCount` abaixo da
/// count de ocorrências (baixadas ou abertas) já preservadas antes de
/// `effectiveDate` — reversão não altera essa contagem.
RecurringSeries addRevision(
  RecurringSeries serie, {
  required CivilDate effectiveDate,
  required Money novoValorBase,
  required RecurrenceRule novaRegra,
  required List<Occurrence> existingOccurrences,
}) {
  if (serie.revisions.isNotEmpty) {
    final ultimaEfeito = serie.revisions.last.effectiveDate;
    if (effectiveDate.isBefore(ultimaEfeito)) {
      throw ArgumentError(
        'A nova revisão não pode ter date de efeito anterior à última revisão.',
      );
    }
  } else {
    if (effectiveDate.isBefore(serie.rule.startDate)) {
      throw ArgumentError(
        'A nova revisão não pode ter date de efeito anterior à date inicial da série.',
      );
    }
  }

  final novaRevisao = SeriesRevision(
    effectiveDate: effectiveDate,
    baseAmount: novoValorBase,
    rule: novaRegra,
  );

  final serieRevisada = serie.copyWithInternal(
    revisions: List.unmodifiable([...serie.revisions, novaRevisao]),
  );

  final horizonte = effectiveDate.addDays(_horizonteVerificacao.inDays);

  final idsPreservadosPelaNovaRegra = generateOccurrences(
    serieRevisada,
    desde: effectiveDate,
    ate: horizonte,
  ).map((o) => o.id).toSet();

  final afetadasPelaEdicao = existingOccurrences.where(
    (o) => o.dueDate.isSameOrAfter(effectiveDate),
  );

  final baixadasEliminadas = afetadasPelaEdicao.where(
    (o) => o.settlement != null && !idsPreservadosPelaNovaRegra.contains(o.id),
  );
  if (baixadasEliminadas.isNotEmpty) {
    throw EditBlockedException(
      'A edição eliminaria ${baixadasEliminadas.length} ocorrência(s) já '
      'settled(s); registre a série como está ou encerre-a em vez de editar.',
    );
  }

  final quantidadePreservada = afetadasPelaEdicao.length;
  if (novaRegra.endType == EndConditionType.count &&
      novaRegra.endCount! < quantidadePreservada) {
    throw EditBlockedException(
      'A nova count de término (${novaRegra.endCount}) é '
      'menor que a count de ocorrências já preservadas '
      '($quantidadePreservada) a partir da date de efeito.',
    );
  }

  return serieRevisada;
}
