import 'package:contapaga/features/recurring_bills/domain/civil_date.dart';

// Classe de valor imutável (todos os campos final, sem setters); não
// depende diretamente de package:meta apenas para a anotação @immutable.
// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

class CompetencyPeriod implements Comparable<CompetencyPeriod> {
  const new(this.year, this.month)
    : assert(month >= 1 && month <= 12, 'Mês deve ser entre 1 e 12');

  factory fromDate(CivilDate date) {
    return CompetencyPeriod(date.year, date.month);
  }
  final int year;
  final int month;

  CompetencyPeriod previous() {
    if (month == 1) {
      return CompetencyPeriod(year - 1, 12);
    }
    return CompetencyPeriod(year, month - 1);
  }

  CompetencyPeriod next() {
    if (month == 12) {
      return CompetencyPeriod(year + 1, 1);
    }
    return CompetencyPeriod(year, month + 1);
  }

  /// Gera as N competências imediatamente anteriores a esta (excluindo esta).
  /// Ex: se esta é 2026/09, preceding(3) -> [2026/08, 2026/07, 2026/06]
  List<CompetencyPeriod> preceding(int n) {
    if (n <= 0) return [];
    final list = <CompetencyPeriod>[];
    var current = this;
    for (var i = 0; i < n; i++) {
      current = current.previous();
      list.add(current);
    }
    return list;
  }

  @override
  int compareTo(CompetencyPeriod other) {
    if (year != other.year) return year.compareTo(other.year);
    return month.compareTo(other.month);
  }

  bool isBefore(CompetencyPeriod other) => compareTo(other) < 0;
  bool isAfter(CompetencyPeriod other) => compareTo(other) > 0;
  bool isSameOrBefore(CompetencyPeriod other) => compareTo(other) <= 0;
  bool isSameOrAfter(CompetencyPeriod other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompetencyPeriod && other.year == year && other.month == month);

  @override
  int get hashCode => Object.hash(year, month);

  @override
  String toString() {
    final a = year.toString().padLeft(4, '0');
    final m = month.toString().padLeft(2, '0');
    return '$a-$m';
  }
}
