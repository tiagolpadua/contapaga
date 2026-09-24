import 'package:contapaga/core/time/clock.dart';
import 'package:contapaga/features/recurring_bills/domain/civil_date.dart';
import 'package:contapaga/features/recurring_bills/domain/occurrence.dart';

class DashboardSummary {
  // ex: próximos 7 dias (exclusive hoje)

  new({
    required this.atrasadas,
    required this.vencendoHoje,
    required this.vencendoEmBreve,
  });
  final List<Occurrence> atrasadas;
  final List<Occurrence> vencendoHoje;
  final List<Occurrence> vencendoEmBreve;
}

DashboardSummary calculateDashboard(
  List<Occurrence> occurrences, {
  required Clock clock,
  int diasEmBreve = 7,
}) {
  final hoje = CivilDate.hoje(clock);
  final limiteEmBreve = hoje.addDays(diasEmBreve);

  final atrasadas = <Occurrence>[];
  final vencendoHoje = <Occurrence>[];
  final vencendoEmBreve = <Occurrence>[];

  for (final o in occurrences) {
    if (o.settlement != null) continue; // Só consideramos ocorrências abertas

    if (o.dueDate.isBefore(hoje)) {
      atrasadas.add(o);
    } else if (o.dueDate == hoje) {
      vencendoHoje.add(o);
    } else if (o.dueDate.isSameOrBefore(limiteEmBreve)) {
      vencendoEmBreve.add(o);
    }
  }

  // Ordenar por date de vencimento
  atrasadas.sort((a, b) => a.dueDate.compareTo(b.dueDate));
  vencendoHoje.sort((a, b) => a.dueDate.compareTo(b.dueDate));
  vencendoEmBreve.sort((a, b) => a.dueDate.compareTo(b.dueDate));

  return DashboardSummary(
    atrasadas: atrasadas,
    vencendoHoje: vencendoHoje,
    vencendoEmBreve: vencendoEmBreve,
  );
}
