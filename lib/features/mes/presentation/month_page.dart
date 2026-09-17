import 'package:contapaga/features/ajustes/presentation/settings_page.dart';
import 'package:contapaga/features/mes/presentation/month_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthPage extends StatelessWidget {
  const new({required this.controller, super.key});
  final MonthController controller;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Conta Paga'),
      actions: [
        IconButton(
          tooltip: 'Ajustes',
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => Navigator.of(
            context,
          ).push<void>(MaterialPageRoute(builder: (_) => const SettingsPage())),
        ),
      ],
    ),
    body: SafeArea(
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Mês anterior',
                  icon: const Icon(Icons.chevron_left),
                  onPressed: controller.busy ? null : () => controller.move(-1),
                ),
                Expanded(
                  child: Text(
                    DateFormat.yMMMM('pt_BR').format(controller.selectedMonth),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Próximo mês',
                  icon: const Icon(Icons.chevron_right),
                  onPressed: controller.busy ? null : () => controller.move(1),
                ),
              ],
            ),
            if (controller.error case final error?)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(error, semanticsLabel: error),
              ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Column(
                children: [
                  Icon(Icons.event_note_outlined, size: 48),
                  SizedBox(height: 16),
                  Text('Suas contas em um só lugar'),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
