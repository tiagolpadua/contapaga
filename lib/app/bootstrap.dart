import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../core/storage/sqlite_key_value_store.dart';
import '../core/time/clock.dart';
import '../features/mes/data/local_month_repository.dart';
import '../features/mes/presentation/month_controller.dart';
import 'app_environment.dart';
import 'conta_paga_app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  final environment = AppEnvironment.fromName(
    const String.fromEnvironment('APP_ENV', defaultValue: 'production'),
  );
  SqliteKeyValueStore? store;
  MonthController? controller;
  try {
    store = await SqliteKeyValueStore.open(environment.databaseName);
    controller = MonthController(
      repository: LocalMonthRepository(store),
      clock: const SystemClock(),
    );
    await controller.restore();
    runApp(ContaPagaApp(controller: controller));
  } catch (_) {
    controller?.dispose();
    await store?.close();
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Não foi possível abrir seus dados.'),
                FilledButton(
                  onPressed: bootstrap,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
