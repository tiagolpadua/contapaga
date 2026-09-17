import 'package:contapaga/features/recorrencias/domain/baixa.dart';
import 'package:contapaga/features/recorrencias/domain/civil_date.dart';
import 'package:contapaga/features/recorrencias/domain/competencia.dart';
import 'package:contapaga/features/recorrencias/domain/money.dart';
import 'package:contapaga/core/time/clock.dart';

enum StatusOcorrencia { aberta, baixada, atrasada, pendenteAutomatico }

class Ocorrencia {
  final String serieId;
  final String id;
  final CivilDate dataVencimento;
  final Money valorPrevisto;
  final int sequencia; // 1-based index na série
  final Baixa? baixa;
  final bool debitoAutomatico;

  Ocorrencia({
    required this.serieId,
    required this.id,
    required this.dataVencimento,
    required this.valorPrevisto,
    required this.sequencia,
    this.baixa,
    this.debitoAutomatico = false,
  });

  Competencia get competencia => Competencia.fromDate(dataVencimento);

  StatusOcorrencia status(Clock clock) {
    if (baixa != null) {
      return StatusOcorrencia.baixada;
    }
    
    final hoje = CivilDate.hoje(clock);
    if (dataVencimento.isBefore(hoje)) {
      return debitoAutomatico ? StatusOcorrencia.pendenteAutomatico : StatusOcorrencia.atrasada;
    }
    
    return StatusOcorrencia.aberta;
  }

  Ocorrencia copyWithBaixa(Baixa? novaBaixa) {
    return Ocorrencia(
      serieId: serieId,
      id: id,
      dataVencimento: dataVencimento,
      valorPrevisto: valorPrevisto,
      sequencia: sequencia,
      baixa: novaBaixa,
      debitoAutomatico: debitoAutomatico,
    );
  }
}
