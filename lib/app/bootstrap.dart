import 'package:contapaga/app/app_environment.dart';
import 'package:contapaga/app/conta_paga_app.dart';
import 'package:contapaga/core/storage/sqlite_key_value_store.dart';
import 'package:contapaga/core/time/clock.dart';
import 'package:contapaga/features/month/data/local_month_repository.dart';
import 'package:contapaga/features/month/presentation/month_controller.dart';
import 'package:contapaga/features/recurring_bills/data/sqlite_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite/sqflite.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  final environment = AppEnvironment.fromName(
    const String.fromEnvironment('APP_ENV', defaultValue: 'production'),
  );
  Database? database;
  MonthController? controller;
  try {
    database = await openContaPagaDatabase(environment.databaseName);
    final store = SqliteKeyValueStore(database);

    controller = MonthController(
      repository: LocalMonthRepository(store),
      clock: const SystemClock(),
    );
    await controller.restore();
    runApp(ContaPagaApp(controller: controller));
  } catch (_) {
    controller?.dispose();
    await database?.close();
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Não foi possível abrir seus dados.'),
                FilledButton(
                  onPressed: bootstrap,
                  child: Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
