import 'package:contapaga/features/recorrencias/domain/civil_date.dart';
import 'package:contapaga/features/recorrencias/domain/money.dart';
import 'package:contapaga/features/recorrencias/domain/regra_recorrencia.dart';
import 'package:contapaga/features/recorrencias/domain/revisao_serie.dart';

enum TipoLancamento { receita, despesa }

class SerieRecorrente {
  final String id;
  final String descricao;
  final TipoLancamento tipo;
  final String? contraparte;
  final bool debitoAutomatico;
  final Money valorBase;
  final RegraRecorrencia regra;
  final List<RevisaoSerie> revisoes;
  final CivilDate? dataEncerramento;

  const SerieRecorrente({
    required this.id,
    required this.descricao,
    required this.tipo,
    this.contraparte,
    required this.debitoAutomatico,
    required this.valorBase,
    required this.regra,
    this.revisoes = const [],
    this.dataEncerramento,
  });

  SerieRecorrente copyWithInternal({
    String? descricao,
    String? contraparte,
    bool? debitoAutomatico,
    Money? valorBase,
    RegraRecorrencia? regra,
    List<RevisaoSerie>? revisoes,
    CivilDate? dataEncerramento,
  }) {
    return SerieRecorrente(
      id: id,
      descricao: descricao ?? this.descricao,
      tipo: tipo,
      contraparte: contraparte ?? this.contraparte,
      debitoAutomatico: debitoAutomatico ?? this.debitoAutomatico,
      valorBase: valorBase ?? this.valorBase,
      regra: regra ?? this.regra,
      revisoes: revisoes ?? this.revisoes,
      dataEncerramento: dataEncerramento ?? this.dataEncerramento,
    );
  }

  /// Retorna a regra de recorrência e o valor base vigentes para uma determinada data.
  /// Percorre as revisões de trás pra frente (assumindo que estão em ordem cronológica de `dataEfeito`).
  RevisaoSerie revisaoVigenteEm(CivilDate data) {
    if (revisoes.isEmpty) {
      return RevisaoSerie(
        dataEfeito: regra.dataInicial,
        regra: regra,
        valorBase: valorBase,
      );
    }
    
    // Assume que as revisões estão ordenadas por dataEfeito crescente.
    for (int i = revisoes.length - 1; i >= 0; i--) {
      final r = revisoes[i];
      if (r.dataEfeito.isSameOrBefore(data)) {
        return r;
      }
    }

    return RevisaoSerie(
      dataEfeito: regra.dataInicial,
      regra: regra,
      valorBase: valorBase,
    );
  }
}
