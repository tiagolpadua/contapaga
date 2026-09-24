import 'dart:convert';

import 'package:contapaga/features/recurring_bills/domain/civil_date.dart';
import 'package:contapaga/features/recurring_bills/domain/competency_period.dart';
import 'package:contapaga/features/recurring_bills/domain/notification_preferences.dart';
import 'package:contapaga/features/recurring_bills/domain/occurrence.dart';
import 'package:contapaga/features/recurring_bills/domain/recurrence_rule.dart';
import 'package:contapaga/features/recurring_bills/domain/recurring_series.dart';
import 'package:contapaga/features/recurring_bills/domain/repositories/notification_preferences_repository.dart';
import 'package:contapaga/features/recurring_bills/domain/repositories/occurrence_repository.dart';
import 'package:contapaga/features/recurring_bills/domain/repositories/series_repository.dart';
import 'package:sqflite/sqflite.dart';

const _backupVersion = 1;

/// Lançada quando o arquivo de backup não pode ser importado: versão
/// desconhecida ou conteúdo malformado. O banco não é tocado quando esta
/// exceção é lançada durante a validação (antes da transação de importação).
class InvalidBackupException implements Exception {
  new(this.message);
  final String message;

  @override
  String toString() => 'InvalidBackupException: $message';
}

/// Resumo do conteúdo de um backup, para exibir uma prévia de confirmação
/// ao usuário antes da substituição transacional e irreversível dos dados.
class BackupPreview {
  const new({
    required this.seriesCount,
    required this.occurrenceCount,
    required this.generatedAt,
  });
  final int seriesCount;
  final int occurrenceCount;
  final DateTime generatedAt;
}

class SqliteBackupService {
  new(
    this._database,
    this._seriesRepository,
    this._occurrenceRepository,
    this._preferencesRepository,
  );
  final Database _database;
  final SeriesRepository _seriesRepository;
  final OccurrenceRepository _occurrenceRepository;
  final NotificationPreferencesRepository _preferencesRepository;

  Future<String> export() async {
    final series = await _seriesRepository.listAll();
    final occurrences = <Occurrence>[];
    for (final s in series) {
      occurrences.addAll(await _occurrenceRepository.listBySeries(s.id));
    }
    final preferences = await _preferencesRepository.load();

    return jsonEncode({
      'backupVersion': _backupVersion,
      'generatedAt': DateTime.now().toUtc().toIso8601String(),
      'series': series.map(_seriesToJson).toList(),
      'occurrences': occurrences.map(_occurrenceToJson).toList(),
      'preferences': _preferencesToJson(preferences),
    });
  }

  /// Faz o parse completo do arquivo e devolve um resumo para confirmação,
  /// sem tocar no banco. Lança [InvalidBackupException] se o arquivo não
  /// puder ser importado.
  BackupPreview preview(String jsonString) {
    final map = _decodeAndValidate(jsonString);
    final series = map['series']! as List;
    final occurrences = map['occurrences']! as List;
    return BackupPreview(
      seriesCount: series.length,
      occurrenceCount: occurrences.length,
      generatedAt: DateTime.parse(map['generatedAt']! as String),
    );
  }

  /// Substitui integralmente os dados financeiros pelo conteúdo do backup,
  /// dentro de uma única transação: se qualquer etapa falhar, nada é
  /// persistido (nunca fica em estado parcialmente importado). Não faz
  /// mesclagem — os dados atuais são descartados.
  Future<void> import(String jsonString) async {
    final map = _decodeAndValidate(jsonString);

    final seriesJson = (map['series']! as List).cast<Map<String, dynamic>>();
    final occurrencesJson = (map['occurrences']! as List)
        .cast<Map<String, dynamic>>();
    final preferencesJson = map['preferences']! as Map<String, dynamic>;

    await _database.transaction((txn) async {
      await txn.delete('occurrences');
      await txn.delete('materialized_series');
      await txn.delete('series_revisions');
      await txn.delete('series');

      for (final s in seriesJson) {
        await txn.insert('series', _seriesJsonToRow(s));
        for (final r in s['revisions']! as List) {
          await txn.insert(
            'series_revisions',
            _revisionJsonToRow(s['id']! as String, r as Map<String, dynamic>),
          );
        }
      }

      for (final o in occurrencesJson) {
        await txn.insert('occurrences', _occurrenceJsonToRow(o));
      }
    });

    await _preferencesRepository.save(_preferencesFromJson(preferencesJson));
  }

  Map<String, dynamic> _decodeAndValidate(String jsonString) {
    final Map<String, dynamic> map;
    try {
      map = jsonDecode(jsonString) as Map<String, dynamic>;
    } on FormatException catch (e) {
      throw InvalidBackupException('Arquivo de backup inválido: $e');
    }

    if (map['backupVersion'] != _backupVersion) {
      throw InvalidBackupException(
        'Versão de backup não suportada: ${map['backupVersion']}',
      );
    }
    if (map['series'] is! List ||
        map['occurrences'] is! List ||
        map['preferences'] is! Map ||
        map['generatedAt'] is! String) {
      throw InvalidBackupException('Estrutura de backup inválida.');
    }
    return map;
  }

  Map<String, dynamic> _seriesToJson(RecurringSeries series) {
    return {
      'id': series.id,
      'description': series.description,
      'type': series.type.name,
      'counterparty': series.counterparty,
      'autoDebit': series.autoDebit,
      'baseAmountCents': series.baseAmount.cents,
      'rule': _ruleToJson(series.rule),
      'revisions': series.revisions
          .map(
            (r) => {
              'effectiveDate': r.effectiveDate.toString(),
              'baseAmountCents': r.baseAmount.cents,
              'rule': _ruleToJson(r.rule),
            },
          )
          .toList(),
      'closedAt': series.closedAt?.toString(),
    };
  }

  Map<String, dynamic> _ruleToJson(RecurrenceRule rule) {
    return {
      'frequency': rule.frequency.name,
      'interval': rule.interval,
      'weekdays': rule.weekdays.toList(),
      'startDate': rule.startDate.toString(),
      'endType': rule.endType.name,
      'endDate': rule.endDate?.toString(),
      'endCount': rule.endCount,
    };
  }

  Map<String, dynamic> _occurrenceToJson(Occurrence occurrence) {
    return {
      'id': occurrence.id,
      'seriesId': occurrence.seriesId,
      'dueDate': occurrence.dueDate.toString(),
      'expectedAmountCents': occurrence.expectedAmount.cents,
      'sequenceNumber': occurrence.sequenceNumber,
      'autoDebit': occurrence.autoDebit,
      'settlement': occurrence.settlement == null
          ? null
          : {
              'paidAmountCents': occurrence.settlement!.paidAmount.cents,
              'paymentDate': occurrence.settlement!.paymentDate.toString(),
              'recordedAt': occurrence.settlement!.recordedAt
                  .toUtc()
                  .toIso8601String(),
            },
    };
  }

  Map<String, dynamic> _preferencesToJson(NotificationPreferences prefs) {
    return {
      'hour': prefs.hour,
      'minute': prefs.minute,
      'enabled': prefs.enabled,
      'leadDays': prefs.leadDays,
    };
  }

  NotificationPreferences _preferencesFromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      hour: json['hour']! as int,
      minute: json['minute']! as int,
      enabled: json['enabled']! as bool,
      leadDays: json['leadDays']! as int,
    );
  }

  Map<String, dynamic> _seriesJsonToRow(Map<String, dynamic> s) {
    final rule = s['rule']! as Map<String, dynamic>;
    final now = DateTime.now().toUtc().toIso8601String();
    return {
      'id': s['id'],
      'description': s['description'],
      'type': s['type'],
      'counterparty': s['counterparty'],
      'auto_debit': (s['autoDebit']! as bool) ? 1 : 0,
      'base_amount_cents': s['baseAmountCents'],
      ..._ruleJsonToColumns(rule),
      'closed_at': s['closedAt'],
      'created_at': now,
      'updated_at': now,
    };
  }

  Map<String, dynamic> _revisionJsonToRow(
    String seriesId,
    Map<String, dynamic> r,
  ) {
    final rule = r['rule']! as Map<String, dynamic>;
    return {
      'series_id': seriesId,
      'effective_date': r['effectiveDate'],
      'base_amount_cents': r['baseAmountCents'],
      ..._ruleJsonToColumns(rule),
    };
  }

  Map<String, dynamic> _ruleJsonToColumns(Map<String, dynamic> rule) {
    return {
      'rule_frequency': rule['frequency'],
      'rule_interval': rule['interval'],
      'rule_weekdays': (rule['weekdays']! as List).join(','),
      'rule_start_date': rule['startDate'],
      'rule_end_type': rule['endType'],
      'rule_end_date': rule['endDate'],
      'rule_end_count': rule['endCount'],
    };
  }

  Map<String, dynamic> _occurrenceJsonToRow(Map<String, dynamic> o) {
    final dueDate = CivilDate.fromString(o['dueDate']! as String);
    final settlement = o['settlement'] as Map<String, dynamic>?;
    return {
      'id': o['id'],
      'series_id': o['seriesId'],
      'due_date': o['dueDate'],
      'competency_period': CompetencyPeriod.fromDate(dueDate).toString(),
      'sequence_number': o['sequenceNumber'],
      'expected_amount_cents': o['expectedAmountCents'],
      'auto_debit': (o['autoDebit']! as bool) ? 1 : 0,
      'settlement_paid_amount_cents': settlement?['paidAmountCents'],
      'settlement_payment_date': settlement?['paymentDate'],
      'settlement_recorded_at': settlement?['recordedAt'],
    };
  }
}
