import 'package:contapaga/core/time/clock.dart';

class CivilDate implements Comparable<CivilDate> {

  const new(this.year, this.month, this.day)
    : assert(month >= 1 && month <= 12, 'Mês deve ser entre 1 e 12'),
      assert(day >= 1 && day <= 31, 'Dia deve ser entre 1 e 31');
  // A validação rigorosa de dias no mês é feita no construtor via factory ou deixamos o assert simples,
  // mas idealmente validar o último dia do mês.

  new _validated(this.year, this.month, this.day) {
    if (day > _daysInMonth(year, month)) {
      throw ArgumentError('Dia $day não existe no mês $month de $year');
    }
  }

  factory validated(int year, int month, int day) =>
      CivilDate._validated(year, month, day);

  factory hoje(Clock clock) {
    final now = clock.now();
    return CivilDate(now.year, now.month, now.day);
  }

  factory fromDate(DateTime date) {
    return CivilDate(date.year, date.month, date.day);
  }
  final int year;
  final int month;
  final int day;

  DateTime toDateTime() => DateTime(year, month, day);

  /// Retorna o último dia do mês para um dado ano e mês
  static int _daysInMonth(int year, int month) {
    if (month == 2) {
      final isLeap = (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0));
      return isLeap ? 29 : 28;
    }
    const days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return days[month - 1];
  }

  CivilDate addDays(int n) {
    // Usando DateTime para addDays é seguro pois não tem problemas de timezone se usarmos meio-dia ou se
    // a matemática de dias for exata, mas como local pode ter DST, DateTime.utc é mais seguro para matemática de dias
    final dt = DateTime.utc(year, month, day).add(Duration(days: n));
    return CivilDate(dt.year, dt.month, dt.day);
  }

  CivilDate addMonths(int n) {
    var newMonth = month + n;
    var newYear = year;

    while (newMonth > 12) {
      newMonth -= 12;
      newYear++;
    }
    while (newMonth < 1) {
      newMonth += 12;
      newYear--;
    }

    var newDay = day;
    final maxDays = _daysInMonth(newYear, newMonth);
    if (newDay > maxDays) {
      newDay = maxDays;
    }

    return CivilDate(newYear, newMonth, newDay);
  }

  CivilDate addYears(int n) {
    final newYear = year + n;
    var newDay = day;
    final maxDays = _daysInMonth(newYear, month);
    if (newDay > maxDays) {
      newDay = maxDays;
    }
    return CivilDate(newYear, month, newDay);
  }

  bool isBefore(CivilDate other) => compareTo(other) < 0;
  bool isAfter(CivilDate other) => compareTo(other) > 0;
  bool isSameOrBefore(CivilDate other) => compareTo(other) <= 0;
  bool isSameOrAfter(CivilDate other) => compareTo(other) >= 0;

  @override
  int compareTo(CivilDate other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CivilDate &&
          other.year == year &&
          other.month == month &&
          other.day == day);

  @override
  int get hashCode => Object.hash(year, month, day);

  /// Retorna o dia da semana (segunda=1 .. domingo=7)
  int get weekday => DateTime.utc(year, month, day).weekday;

  @override
  String toString() {
    final y = year.toString().padLeft(4, '0');
    final m = month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
