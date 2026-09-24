import 'package:contapaga/core/notifications/notification_scheduler.dart';
import 'package:contapaga/features/recurring_bills/application/settle_occurrence_service.dart';
import 'package:contapaga/features/recurring_bills/domain/civil_date.dart';
import 'package:contapaga/features/recurring_bills/domain/money.dart';
import 'package:contapaga/features/recurring_bills/domain/occurrence.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

class _FailingNotificationScheduler implements NotificationScheduler {
  @override
  Future<bool> isEnabled() async => true;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<bool> schedule(ScheduledReminder reminder) async =>
      throw StateError('Simulated notification failure');

  @override
  Future<void> cancel(int id) async {}
}

void main() {
  group('SettleOccurrenceService', () {
    late FakeOccurrenceRepository repository;
    late FixedClock clock;
    late SettleOccurrenceService service;

    final occurrence = Occurrence(
      seriesId: 's1',
      id: 's1#2026-09-10#1',
      dueDate: const CivilDate(2026, 9, 10),
      expectedAmount: const Money(10000),
      sequenceNumber: 1,
    );

    setUp(() {
      repository = FakeOccurrenceRepository();
      repository.occurrences[occurrence.id] = occurrence;
      clock = FixedClock(DateTime(2026, 9, 16));
      service = SettleOccurrenceService(
        repository,
        clock,
        _FailingNotificationScheduler(),
      );
    });

    test('persiste a settlement através do repositório', () async {
      await service.settle(
        occurrence,
        paidAmount: const Money(9500),
        paymentDate: const CivilDate(2026, 9, 11),
      );

      final persisted = repository.occurrences[occurrence.id]!;
      expect(persisted.settlement, isNotNull);
      expect(persisted.settlement!.paidAmount, equals(const Money(9500)));
      expect(
        persisted.settlement!.paymentDate,
        equals(const CivilDate(2026, 9, 11)),
      );
    });

    test('falha na reconciliação de notificações não impede nem reverte a '
        'settlement já persistida', () async {
      // O _FailingNotificationScheduler simula uma falha na reconciliação;
      // a chamada não deve lançar, e a settlement deve continuar persistida.
      await service.settle(
        occurrence,
        paidAmount: const Money(9500),
        paymentDate: const CivilDate(2026, 9, 11),
      );

      expect(repository.occurrences[occurrence.id]!.settlement, isNotNull);
    });

    test(
      'propaga erro de domínio sem persistir (valor pago inválido)',
      () async {
        await expectLater(
          () => service.settle(
            occurrence,
            paidAmount: const Money(0),
            paymentDate: const CivilDate(2026, 9, 11),
          ),
          throwsArgumentError,
        );

        expect(repository.occurrences[occurrence.id]!.settlement, isNull);
      },
    );

    test('reverte uma settlement existente', () async {
      await service.settle(
        occurrence,
        paidAmount: const Money(9500),
        paymentDate: const CivilDate(2026, 9, 11),
      );
      final settled = repository.occurrences[occurrence.id]!;

      await service.revertSettlement(settled);

      expect(repository.occurrences[occurrence.id]!.settlement, isNull);
    });
  });
}
