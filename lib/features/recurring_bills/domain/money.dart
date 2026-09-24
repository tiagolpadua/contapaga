// Classe de valor imutável (todos os campos final, sem setters); não
// depende diretamente de package:meta apenas para a anotação @immutable.
// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

class Money implements Comparable<Money> {
  const new(this.cents);

  /// Arredonda meio centavo para cima, usando aritmética inteira.
  factory averageRoundedHalfUp(List<Money> values) {
    if (values.isEmpty) {
      throw ArgumentError('A lista de valores não pode estar vazia.');
    }

    final sum = values.fold(0, (prev, m) => prev + m.cents);
    final count = values.length;

    final res = (sum * 2 + count) ~/ (count * 2);

    return Money(res);
  }
  final int cents;

  bool get isNegative => cents < 0;
  bool get isZero => cents == 0;

  Money operator +(Money other) => Money(cents + other.cents);
  Money operator -(Money other) => Money(cents - other.cents);
  Money operator -() => Money(-cents);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Money && other.cents == cents);

  @override
  int get hashCode => cents.hashCode;

  @override
  int compareTo(Money other) => cents.compareTo(other.cents);

  bool operator <(Money other) => cents < other.cents;
  bool operator <=(Money other) => cents <= other.cents;
  bool operator >(Money other) => cents > other.cents;
  bool operator >=(Money other) => cents >= other.cents;

  @override
  String toString() => 'Money($cents cents)';
}
