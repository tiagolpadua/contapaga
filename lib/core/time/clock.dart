abstract interface class Clock {
  DateTime now();
}

final class SystemClock implements Clock {
  const new();
  @override
  DateTime now() => DateTime.now();
}
