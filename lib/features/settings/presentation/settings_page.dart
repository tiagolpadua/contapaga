import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const new({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Ajustes')),
    body: ListView(
      children: [
        const ListTile(
          leading: Icon(Icons.phone_android),
          title: Text('Dados neste aparelho'),
          subtitle: Text('Uso individual, sem login.'),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Sobre'),
          onTap: () => showAboutDialog(
            context: context,
            applicationName: 'Conta Paga',
            applicationVersion: const String.fromEnvironment(
              'APP_VERSION',
              defaultValue: '0.1.0+1',
            ),
            children: [
              const Text('Organização pessoal de contas a pagar e receber.'),
            ],
          ),
        ),
      ],
    ),
  );
}
