import 'package:contapaga/app/conta_paga_app.dart';
import 'package:contapaga/features/mes/data/local_month_repository.dart';
import 'package:contapaga/features/mes/presentation/month_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'support/fakes.dart';

void main() {
  testWidgets('Portuguese month and selection survive settings navigation', (
    tester,
  ) async {
    await initializeDateFormatting('pt_BR');
    final controller = MonthController(
      repository: LocalMonthRepository(MemoryStore()),
      clock: FixedClock(DateTime(2026, 12, 31)),
    );
    await tester.pumpWidget(ContaPagaApp(controller: controller));
    await tester.pumpAndSettle();
    expect(find.text('dezembro de 2026'), findsOneWidget);
    await tester.tap(find.byTooltip('Próximo mês'));
    await tester.pumpAndSettle();
    expect(find.text('janeiro de 2027'), findsOneWidget);
    await tester.tap(find.byTooltip('Ajustes'));
    await tester.pumpAndSettle();
    expect(find.text('Dados neste aparelho'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('janeiro de 2027'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });
}
