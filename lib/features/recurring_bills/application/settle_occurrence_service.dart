import 'package:contapaga/core/notifications/notification_scheduler.dart';
import 'package:contapaga/core/time/clock.dart';
import 'package:contapaga/features/recurring_bills/domain/civil_date.dart';
import 'package:contapaga/features/recurring_bills/domain/money.dart';
import 'package:contapaga/features/recurring_bills/domain/occurrence.dart';
import 'package:contapaga/features/recurring_bills/domain/repositories/occurrence_repository.dart';
import 'package:contapaga/features/recurring_bills/domain/use_cases/settle_occurrence.dart'
    as domain;
import 'package:flutter/foundation.dart';

class SettleOccurrenceService {
  new(this._repository, this._clock, this._notificationScheduler);
  final OccurrenceRepository _repository;
  final Clock _clock;

  // Reservado para a reconciliação de notificações (Fase 5/6); ver
  // _reconcileNotifications abaixo — mantido como dependência já injetada
  // para não exigir replumbing dos chamadores quando a Fase 5/6 a implementar.
  // ignore: unused_field
  final NotificationScheduler _notificationScheduler;

  Future<void> settle(
    Occurrence occurrence, {
    required Money paidAmount,
    required CivilDate paymentDate,
  }) async {
    final settledOccurrence = domain.settleOccurrence(
      occurrence,
      paidAmount: paidAmount,
      paymentDate: paymentDate,
      clock: _clock,
    );

    // Persiste transacionalmente antes de qualquer confirmação de sucesso.
    await _repository.settleOccurrence(
      occurrence.id,
      settledOccurrence.settlement!,
    );

    // Reconciliação de notificações roda depois do commit; sua falha nunca
    // reverte a settlement já persistida.
    try {
      await _reconcileNotifications();
    } catch (e, st) {
      debugPrint('Falha ao reconciliar notificações após settlement: $e\n$st');
    }
  }

  Future<void> revertSettlement(Occurrence occurrence) async {
    domain.revertSettlement(occurrence); // Valida que há settlement a reverter.
    await _repository.revertSettlement(occurrence.id);

    try {
      await _reconcileNotifications();
    } catch (e, st) {
      debugPrint(
        'Falha ao reconciliar notificações após reverter settlement: $e\n$st',
      );
    }
  }

  Future<void> _reconcileNotifications() async {
    // TODO(fase-5-6): reconciliar lembretes agendados via
    // _notificationScheduler quando a UI de notificações existir.
  }
}
