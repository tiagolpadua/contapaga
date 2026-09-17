class Money implements Comparable<Money> {
  final int cents;

  const Money(this.cents);

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

  /// Arredonda meio centavo para cima, usando aritmética inteira.
  static Money averageRoundedHalfUp(List<Money> values) {
    if (values.isEmpty) {
      throw ArgumentError('A lista de valores não pode estar vazia.');
    }
    
    final int sum = values.fold(0, (prev, m) => prev + m.cents);
    final int count = values.length;
    
    final int res = (sum * 2 + count) ~/ (count * 2);
    
    return Money(res);
  }

  @override
  String toString() => 'Money($cents cents)';
}
