import 'package:contapaga/core/storage/key_value_store.dart';
import 'package:contapaga/core/time/clock.dart';

class FixedClock implements Clock {
  new(this.value);
  final DateTime value;
  @override
  DateTime now() => value;
}

class MemoryStore implements KeyValueStore {
  final values = <String, String>{};
  bool failWrites = false;
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> write(String key, String value) async {
    if (failWrites) throw StateError('Simulated storage failure');
    values[key] = value;
  }

  @override
  Future<void> close() async {}
}
