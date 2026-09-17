import 'package:contapaga/features/mes/presentation/month_controller.dart';
import 'package:contapaga/features/mes/presentation/month_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class ContaPagaApp extends StatelessWidget {
  const new({required this.controller, super.key});
  final MonthController controller;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Conta Paga',
    debugShowCheckedModeBanner: false,
    locale: const Locale('pt', 'BR'),
    supportedLocales: const [Locale('pt', 'BR')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff5980a6)),
    ),
    home: MonthPage(controller: controller),
  );
}
