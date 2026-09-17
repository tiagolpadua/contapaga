import 'package:contapaga/app/app_environment.dart';
import 'package:contapaga/app/conta_paga_app.dart';
import 'package:contapaga/core/storage/sqlite_key_value_store.dart';
import 'package:contapaga/core/time/clock.dart';
import 'package:contapaga/features/mes/data/local_month_repository.dart';
import 'package:contapaga/features/mes/presentation/month_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

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
