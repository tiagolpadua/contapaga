import 'package:contapaga/features/recorrencias/domain/civil_date.dart';

enum Frequencia { diaria, semanal, mensal, anual }

enum TerminoTipo { nunca, data, quantidade }

class RegraRecorrencia {
  new({
    required this.frequencia,
    required this.dataInicial,
    this.intervalo = 1,
    this.diasSemana = const {},
    this.terminoTipo = TerminoTipo.nunca,
    this.terminoData,
    this.terminoQuantidade,
  }) {
    if (intervalo < 1) {
      throw ArgumentError('O intervalo deve ser maior ou igual a 1.');
    }
    if (frequencia == Frequencia.semanal && diasSemana.isEmpty) {
      throw ArgumentError(
        'Para frequência semanal, pelo menos um dia da semana deve ser informado.',
      );
    }

    switch (terminoTipo) {
      case TerminoTipo.nunca:
        if (terminoData != null || terminoQuantidade != null) {
          throw ArgumentError(
            'Término "nunca" não deve ter data ou quantidade.',
          );
        }
      case TerminoTipo.data:
        if (terminoData == null) {
          throw ArgumentError('Término por "data" exige a data de término.');
        }
        if (terminoQuantidade != null) {
          throw ArgumentError('Término por "data" não deve ter quantidade.');
        }
        if (terminoData!.isBefore(dataInicial)) {
          throw ArgumentError(
            'A data de término não pode ser anterior à data inicial.',
          );
        }
      case TerminoTipo.quantidade:
        if (terminoQuantidade == null) {
          throw ArgumentError('Término por "quantidade" exige a quantidade.');
        }
        if (terminoQuantidade! < 1) {
          throw ArgumentError(
            'A quantidade de término deve ser maior ou igual a 1.',
          );
        }
        if (terminoData != null) {
          throw ArgumentError('Término por "quantidade" não deve ter data.');
        }
    }
  }
  final Frequencia frequencia;
  final int intervalo;
  final Set<int> diasSemana;
  final CivilDate dataInicial;
  final TerminoTipo terminoTipo;
  final CivilDate? terminoData;
  final int? terminoQuantidade;

  /// Retorna o dia ajustado para o mês e ano fornecidos.
  /// Se o dia original da série for maior que o último dia do mês alvo,
  /// retorna o último dia daquele mês.
  int diaEfetivoNoMes(int ano, int mes) {
    final maxDays = _daysInMonth(ano, mes);
    if (dataInicial.day > maxDays) {
      return maxDays;
    }
    return dataInicial.day;
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
