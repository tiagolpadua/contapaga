import 'package:contapaga/features/recorrencias/domain/civil_date.dart';
import 'package:contapaga/features/recorrencias/domain/money.dart';
import 'package:contapaga/features/recorrencias/domain/ocorrencia.dart';
import 'package:contapaga/features/recorrencias/domain/regra_recorrencia.dart';
import 'package:contapaga/features/recorrencias/domain/serie_recorrente.dart';

List<Ocorrencia> gerarOcorrencias(
  SerieRecorrente serie, {
  required CivilDate desde,
  required CivilDate ate,
}) {
  if (desde.isAfter(ate)) return [];

  // Ordenar chunks pela data de efeito apenas para garantir,
  // embora o domínio diga que já vêm ordenados.
  final chunks = <_SerieChunk>[
    _SerieChunk(
      dataEfeito: serie.regra.dataInicial,
      regra: serie.regra,
      valorBase: serie.valorBase,
    ),
    ...serie.revisoes.map(
      (r) => _SerieChunk(
        dataEfeito: r.dataEfeito,
        regra: r.regra,
        valorBase: r.valorBase,
      ),
    ),
  ]..sort((a, b) => a.dataEfeito.compareTo(b.dataEfeito));

  var sequencia = 1;
  final ocorrencias = <Ocorrencia>[];

  for (var i = 0; i < chunks.length; i++) {
    final chunk = chunks[i];
    final start = chunk.dataEfeito;
    final end = (i + 1 < chunks.length)
        ? chunks[i + 1].dataEfeito.addDays(-1)
        : null;

    final dates = _generateDates(chunk.regra);
    for (final date in dates) {
      if (date.isBefore(start)) {
        continue; // Pertence ao chunk anterior (ou irrelevante)
      }
      if (end != null && date.isAfter(end)) break; // Terminou o chunk

      if (serie.dataEncerramento != null &&
          date.isAfter(serie.dataEncerramento!)) {
        return ocorrencias
            .where(
              (o) =>
                  o.dataVencimento.isSameOrAfter(desde) &&
                  o.dataVencimento.isSameOrBefore(ate),
            )
            .toList();
      }

      // Verifica término da regra do chunk
      if (chunk.regra.terminoTipo == TerminoTipo.data) {
        if (date.isAfter(chunk.regra.terminoData!)) break;
      }

      final seqAtAtual = sequencia;

      // Checa quantidade global. Se for término por quantidade, e já passou da quantidade?
      // Wait, terminoQuantidade é da REGRA. Se a revisão mudou a quantidade, a contagem recomeça?
      // O plano diz: "a contagem de "quantidade" considera ocorrências geradas ... não reinicia"
      // Se a regra diz terminoQuantidade = 10, e estamos na seq = 11, acabou.
      if (chunk.regra.terminoTipo == TerminoTipo.quantidade) {
        if (seqAtAtual > chunk.regra.terminoQuantidade!) break;
      }

      if (date.isSameOrAfter(desde) && date.isSameOrBefore(ate)) {
        final dataFormatada =
            "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

        ocorrencias.add(
          Ocorrencia(
            serieId: serie.id,
            id: '${serie.id}#$dataFormatada#$seqAtAtual',
            dataVencimento: date,
            valorPrevisto: chunk.valorBase,
            sequencia: seqAtAtual,
            debitoAutomatico: serie.debitoAutomatico,
          ),
        );
      }

      sequencia++;

      // Se já passamos do `ate` e não precisamos contar sequências adicionais,
      // podemos parar? Não, porque a próxima ocorrência gerada já vai estar > ate
      // (pois _generateDates produz datas estritamente crescentes).
      if (date.isAfter(ate)) {
        // We can safely break because any further dates in this chunk will be > ate
        // AND any further chunks will have dataEfeito > ate, so they will also be > ate.
        return ocorrencias;
      }
    }
  }

  return ocorrencias;
}

class _SerieChunk {
  new({required this.dataEfeito, required this.regra, required this.valorBase});
  final CivilDate dataEfeito;
  final RegraRecorrencia regra;
  final Money valorBase;
}

Iterable<CivilDate> _generateDates(RegraRecorrencia regra) sync* {
  var iter = 0;

  if (regra.frequencia == Frequencia.semanal) {
    final diff = regra.dataInicial.weekday - 1;
    final monday = regra.dataInicial.addDays(-diff);

    while (true) {
      final baseMonday = monday.addDays(iter * regra.intervalo * 7);
      for (var d = 1; d <= 7; d++) {
        if (regra.diasSemana.contains(d)) {
          final candidate = baseMonday.addDays(d - 1);
          if (candidate.isSameOrAfter(regra.dataInicial)) {
            yield candidate;
          }
        }
      }
      iter++;
    }
  } else {
    while (true) {
      switch (regra.frequencia) {
        case Frequencia.diaria:
          yield regra.dataInicial.addDays(iter * regra.intervalo);
        case Frequencia.mensal:
          // mês base = dataInicial + (iter * intervalo)
          // usamos aritmética de anos/meses para não depender do addMonths e ser mais direto
          final rawMonth = regra.dataInicial.month + (iter * regra.intervalo);
          final additionalYears = (rawMonth - 1) ~/ 12;
          final finalMonth = ((rawMonth - 1) % 12) + 1;
          final finalYear = regra.dataInicial.year + additionalYears;

          yield CivilDate(
            finalYear,
            finalMonth,
            regra.diaEfetivoNoMes(finalYear, finalMonth),
          );
        case Frequencia.anual:
          final finalYear = regra.dataInicial.year + (iter * regra.intervalo);
          final finalMonth = regra.dataInicial.month;
          yield CivilDate(
            finalYear,
            finalMonth,
            regra.diaEfetivoNoMes(finalYear, finalMonth),
          );
        case Frequencia.semanal: // handled above
          break;
      }
      iter++;
    }
  }
}
