import 'dart:async';

import 'package:contapaga/features/mes/data/local_month_repository.dart';
import 'package:contapaga/features/mes/domain/month_repository.dart';
import 'package:contapaga/features/mes/presentation/month_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

void main() {
  test('December to January survives controller recreation', () async {
    final repository = LocalMonthRepository(MemoryStore());
    final clock = FixedClock(DateTime(2026, 12, 31));
    final controller = MonthController(repository: repository, clock: clock);
    await controller.move(1);
    final restored = MonthController(repository: repository, clock: clock);
    await restored.restore();
    expect(restored.selectedMonth, DateTime(2027));
    controller.dispose();
    restored.dispose();
  });

  test('failed persistence keeps current month and supports retry', () async {
    final store = MemoryStore()..failWrites = true;
    final controller = MonthController(
      repository: LocalMonthRepository(store),
      clock: FixedClock(DateTime(2026, 9, 16)),
    );
    await controller.move(1);
    expect(controller.selectedMonth, DateTime(2026, 9));
    expect(controller.error, isNotNull);
    expect(controller.busy, isFalse);
    store.failWrites = false;
    await controller.move(1);
    expect(controller.selectedMonth, DateTime(2026, 10));
    expect(controller.error, isNull);
    controller.dispose();
  });

  test('corrupt stored month falls back to clock', () async {
    final store = MemoryStore()..values['selected_month'] = '2026-13';
    final controller = MonthController(
      repository: LocalMonthRepository(store),
      clock: FixedClock(DateTime(2026, 9, 16)),
    );
    await controller.restore();
    expect(controller.selectedMonth, DateTime(2026, 9));
    controller.dispose();
  });

  test('repeated taps do not overlap asynchronous writes', () async {
    final repository = DelayedRepository();
    final controller = MonthController(
      repository: repository,
      clock: FixedClock(DateTime(2026, 9, 16)),
    );
    final first = controller.move(1);
    await controller.move(1);
    expect(repository.writes, 1);
    repository.completer.complete();
    await first;
    expect(controller.selectedMonth, DateTime(2026, 10));
    controller.dispose();
  });
}

class DelayedRepository implements MonthRepository {
  final completer = Completer<void>();
  int writes = 0;
  @override
  Future<DateTime?> loadSelectedMonth() async => null;
  @override
  Future<void> saveSelectedMonth(DateTime month) {
    writes++;
    return completer.future;
  }
}
