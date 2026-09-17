import 'package:contapaga/features/recorrencias/domain/civil_date.dart';
import 'package:contapaga/features/recorrencias/domain/geracao_ocorrencias.dart';
import 'package:contapaga/features/recorrencias/domain/money.dart';
import 'package:contapaga/features/recorrencias/domain/ocorrencia.dart';
import 'package:contapaga/features/recorrencias/domain/regra_recorrencia.dart';
import 'package:contapaga/features/recorrencias/domain/revisao_serie.dart';
import 'package:contapaga/features/recorrencias/domain/serie_recorrente.dart';

/// Lançada quando uma edição prospectiva eliminaria histórico já registrado:
/// uma ocorrência já baixada, ou reduziria a quantidade de término abaixo do
/// que já foi preservado (baixado ou aberto) antes da data de efeito.
class EdicaoBloqueadaException implements Exception {
  new(this.message);
  final String message;

  @override
  String toString() => 'EdicaoBloqueadaException: $message';
}

/// Horizonte usado para verificar se a nova regra preserva o histórico.
/// Suficiente para cobrir qualquer combinação de frequência/intervalo
/// praticada pela v1 (fase 0: sem exceções de calendário avançadas).
const _horizonteVerificacao = Duration(days: 366 * 5);

/// Cria uma nova revisão prospectiva para a série, válida a partir de
/// `dataEfeito`. Bloqueia a edição (fase 0) quando a nova regra eliminaria
/// uma ocorrência já baixada, ou reduziria `terminoQuantidade` abaixo da
/// quantidade de ocorrências (baixadas ou abertas) já preservadas antes de
/// `dataEfeito` — reversão não altera essa contagem.
SerieRecorrente adicionarRevisao(
  SerieRecorrente serie, {
  required CivilDate dataEfeito,
  required Money novoValorBase,
  required RegraRecorrencia novaRegra,
  required List<Ocorrencia> ocorrenciasExistentes,
}) {
  if (serie.revisoes.isNotEmpty) {
    final ultimaEfeito = serie.revisoes.last.dataEfeito;
    if (dataEfeito.isBefore(ultimaEfeito)) {
      throw ArgumentError(
        'A nova revisão não pode ter data de efeito anterior à última revisão.',
      );
    }
  } else {
    if (dataEfeito.isBefore(serie.regra.dataInicial)) {
      throw ArgumentError(
        'A nova revisão não pode ter data de efeito anterior à data inicial da série.',
      );
    }
  }

  final novaRevisao = RevisaoSerie(
    dataEfeito: dataEfeito,
    valorBase: novoValorBase,
    regra: novaRegra,
  );

  final serieRevisada = serie.copyWithInternal(
    revisoes: List.unmodifiable([...serie.revisoes, novaRevisao]),
  );

  final horizonte = dataEfeito.addDays(_horizonteVerificacao.inDays);

  final idsPreservadosPelaNovaRegra = gerarOcorrencias(
    serieRevisada,
    desde: dataEfeito,
    ate: horizonte,
  ).map((o) => o.id).toSet();

  final afetadasPelaEdicao = ocorrenciasExistentes.where(
    (o) => o.dataVencimento.isSameOrAfter(dataEfeito),
  );

  final baixadasEliminadas = afetadasPelaEdicao.where(
    (o) => o.baixa != null && !idsPreservadosPelaNovaRegra.contains(o.id),
  );
  if (baixadasEliminadas.isNotEmpty) {
    throw EdicaoBloqueadaException(
      'A edição eliminaria ${baixadasEliminadas.length} ocorrência(s) já '
      'baixada(s); registre a série como está ou encerre-a em vez de editar.',
    );
  }

  final quantidadePreservada = afetadasPelaEdicao.length;
  if (novaRegra.terminoTipo == TerminoTipo.quantidade &&
      novaRegra.terminoQuantidade! < quantidadePreservada) {
    throw EdicaoBloqueadaException(
      'A nova quantidade de término (${novaRegra.terminoQuantidade}) é '
      'menor que a quantidade de ocorrências já preservadas '
      '($quantidadePreservada) a partir da data de efeito.',
    );
  }

  return serieRevisada;
}
