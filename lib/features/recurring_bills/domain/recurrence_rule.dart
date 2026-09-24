import 'package:contapaga/features/recurring_bills/domain/civil_date.dart';

enum RecurrenceFrequency { daily, weekly, monthly, yearly }

enum EndConditionType { never, date, count }

class RecurrenceRule {
  new({
    required this.frequency,
    required this.startDate,
    this.interval = 1,
    this.weekdays = const {},
    this.endType = EndConditionType.never,
    this.endDate,
    this.endCount,
  }) {
    if (interval < 1) {
      throw ArgumentError('O interval deve ser maior ou igual a 1.');
    }
    if (frequency == RecurrenceFrequency.weekly && weekdays.isEmpty) {
      throw ArgumentError(
        'Para frequência weekly, pelo menos um dia da semana deve ser informado.',
      );
    }

    switch (endType) {
      case EndConditionType.never:
        if (endDate != null || endCount != null) {
          throw ArgumentError('Término "never" não deve ter date ou count.');
        }
      case EndConditionType.date:
        if (endDate == null) {
          throw ArgumentError('Término por "date" exige a date de término.');
        }
        if (endCount != null) {
          throw ArgumentError('Término por "date" não deve ter count.');
        }
        if (endDate!.isBefore(startDate)) {
          throw ArgumentError(
            'A date de término não pode ser anterior à date inicial.',
          );
        }
      case EndConditionType.count:
        if (endCount == null) {
          throw ArgumentError('Término por "count" exige a count.');
        }
        if (endCount! < 1) {
          throw ArgumentError(
            'A count de término deve ser maior ou igual a 1.',
          );
        }
        if (endDate != null) {
          throw ArgumentError('Término por "count" não deve ter date.');
        }
    }
  }
  final RecurrenceFrequency frequency;
  final int interval;
  final Set<int> weekdays;
  final CivilDate startDate;
  final EndConditionType endType;
  final CivilDate? endDate;
  final int? endCount;

  /// Retorna o dia ajustado para o mês e year fornecidos.
  /// Se o dia original da série for maior que o último dia do mês alvo,
  /// retorna o último dia daquele mês.
  int effectiveDayInMonth(int year, int month) {
    final maxDays = _daysInMonth(year, month);
    if (startDate.day > maxDays) {
      return maxDays;
    }
    return startDate.day;
  }

  static int _daysInMonth(int year, int month) {
    if (month == 2) {
      final isLeap =
          (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0));
      return isLeap ? 29 : 28;
    }
    const days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return days[month - 1];
  }
}
