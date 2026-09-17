import 'package:contapaga/features/recorrencias/domain/civil_date.dart';

class Competencia implements Comparable<Competencia> {

  const new(this.ano, this.mes)
    : assert(mes >= 1 && mes <= 12, 'Mês deve ser entre 1 e 12');

  factory fromDate(CivilDate date) {
    return Competencia(date.year, date.month);
  }
  final int ano;
  final int mes;

  Competencia previous() {
    if (mes == 1) {
      return Competencia(ano - 1, 12);
    }
    return Competencia(ano, mes - 1);
  }

  Competencia next() {
    if (mes == 12) {
      return Competencia(ano + 1, 1);
    }
    return Competencia(ano, mes + 1);
  }

  /// Gera as N competências imediatamente anteriores a esta (excluindo esta).
  /// Ex: se esta é 2026/09, precedentes(3) -> [2026/08, 2026/07, 2026/06]
  List<Competencia> precedentes(int n) {
    if (n <= 0) return [];
    final list = <Competencia>[];
    var current = this;
    for (var i = 0; i < n; i++) {
      current = current.previous();
      list.add(current);
    }
    return list;
  }

  @override
  int compareTo(Competencia other) {
    if (ano != other.ano) return ano.compareTo(other.ano);
    return mes.compareTo(other.mes);
  }

  bool isBefore(Competencia other) => compareTo(other) < 0;
  bool isAfter(Competencia other) => compareTo(other) > 0;
  bool isSameOrBefore(Competencia other) => compareTo(other) <= 0;
  bool isSameOrAfter(Competencia other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Competencia && other.ano == ano && other.mes == mes);

  @override
  int get hashCode => Object.hash(ano, mes);

  @override
  String toString() {
    final a = ano.toString().padLeft(4, '0');
    final m = mes.toString().padLeft(2, '0');
    return '$a-$m';
  }
}
