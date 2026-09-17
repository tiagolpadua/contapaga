import 'package:contapaga/core/time/clock.dart';
import 'package:contapaga/features/recorrencias/domain/civil_date.dart';
import 'package:contapaga/features/recorrencias/domain/ocorrencia.dart';

class PainelResumo {
  final List<Ocorrencia> atrasadas;
  final List<Ocorrencia> vencendoHoje;
  final List<Ocorrencia> vencendoEmBreve; // ex: próximos 7 dias (exclusive hoje)

  PainelResumo({
    required this.atrasadas,
    required this.vencendoHoje,
    required this.vencendoEmBreve,
  });
}

PainelResumo calcularPainel(
  List<Ocorrencia> ocorrencias, {
  required Clock clock,
  int diasEmBreve = 7,
}) {
  final hoje = CivilDate.hoje(clock);
  final limiteEmBreve = hoje.addDays(diasEmBreve);

  final atrasadas = <Ocorrencia>[];
  final vencendoHoje = <Ocorrencia>[];
  final vencendoEmBreve = <Ocorrencia>[];

  for (final o in ocorrencias) {
    if (o.baixa != null) continue; // Só consideramos ocorrências abertas

    if (o.dataVencimento.isBefore(hoje)) {
      atrasadas.add(o);
    } else if (o.dataVencimento == hoje) {
      vencendoHoje.add(o);
    } else if (o.dataVencimento.isSameOrBefore(limiteEmBreve)) {
      vencendoEmBreve.add(o);
    }
  }

  // Ordenar por data de vencimento
  atrasadas.sort((a, b) => a.dataVencimento.compareTo(b.dataVencimento));
  vencendoHoje.sort((a, b) => a.dataVencimento.compareTo(b.dataVencimento));
  vencendoEmBreve.sort((a, b) => a.dataVencimento.compareTo(b.dataVencimento));

  return PainelResumo(
    atrasadas: atrasadas,
    vencendoHoje: vencendoHoje,
    vencendoEmBreve: vencendoEmBreve,
  );
}
