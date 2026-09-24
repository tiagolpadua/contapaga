import 'package:contapaga/features/recurring_bills/domain/money.dart';

class MoneyParser {
  /// Faz o parse de uma string em formato pt-BR ('1.234,56' ou '1234,56' ou '12')
  /// Retorna um objeto Money ou null se for inválido.
  static Money? tryParsePtBr(String value) {
    var raw = value.trim();
    if (raw.isEmpty) return null;

    // Remover "R$" ou espaços caso tenha, embora seja bom manter estrito
    raw = raw.replaceAll(RegExp(r'[R$\s]'), '');

    if (raw.isEmpty) return null;

    // Se tiver vírgula, a parte decimal deve ter 1 ou 2 dígitos (ou mais, nós cortamos/falhamos?)
    // Vamos padronizar: se tem vírgula, pegamos os centavos.
    var cents = 0;

    if (raw.contains(',')) {
      final parts = raw.split(',');
      if (parts.length != 2) return null;

      final wholeStr = parts[0].replaceAll('.', ''); // remove pontos de milhar
      final fracStr = parts[1];

      if (int.tryParse(wholeStr) == null && wholeStr.isNotEmpty) return null;
      if (int.tryParse(fracStr) == null && fracStr.isNotEmpty) return null;

      final whole = wholeStr.isEmpty ? 0 : int.parse(wholeStr);

      // se fracStr tiver 1 digito, ex: ",5" -> 50 cents
      // se fracStr tiver 2 digitos, ex: ",56" -> 56 cents
      // se fracStr tiver mais de 2 digitos, ex: ",567" -> falha ou trunca? O plano diz "parsing seguro", vamos suportar até 2.
      if (fracStr.length > 2) return null;

      var frac = fracStr.isEmpty ? 0 : int.parse(fracStr);
      if (fracStr.length == 1) {
        frac *= 10;
      }

      cents = (whole * 100) + frac;

      // se o original era negativo?
      if (wholeStr.startsWith('-')) {
        // whole é negativo, então whole * 100 já é negativo. Precisamos subtrair os centavos.
        cents = (whole * 100) - frac;
        if (whole == 0) {
          cents = -frac;
        }
      }
    } else {
      // sem virgula
      final wholeStr = raw.replaceAll('.', '');
      final whole = int.tryParse(wholeStr);
      if (whole == null) return null;
      cents = whole * 100;
    }

    return Money(cents);
  }
}
