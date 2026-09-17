class PreferenciasNotificacao {

  new({
    required this.hora,
    required this.minuto,
    this.ativo = true,
    this.antecedenciaDias = 3,
  }) {
    if (hora < 0 || hora > 23) {
      throw ArgumentError('Hora deve ser entre 0 e 23.');
    }
    if (minuto < 0 || minuto > 59) {
      throw ArgumentError('Minuto deve ser entre 0 e 59.');
    }
    if (antecedenciaDias < 1 || antecedenciaDias > 10) {
      throw ArgumentError('Antecedência deve ser entre 1 e 10 dias.');
    }
  }
  final int hora;
  final int minuto;
  final bool ativo;
  final int antecedenciaDias;
}
