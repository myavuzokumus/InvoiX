import 'package:flutter/material.dart';
import 'package:invoix/pages/main_page.dart';
import 'package:invoix/theme.dart';

class InvoixMain extends StatelessWidget {
  const InvoixMain({super.key});

  @override
  Widget build(final BuildContext context) {

    return MaterialApp(
      title: 'InvoiX',
      theme: const MaterialTheme(TextTheme()).dark().copyWith(

        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(150),
          ),
          isDense: true,
          counterStyle: const TextStyle(fontSize: 0),
          errorStyle: const TextStyle(fontSize: 0),
        ),
        listTileTheme: const ListTileThemeData(
          shape: Border.symmetric(
            vertical: BorderSide(color: Colors.white, width: 2.5),
          ),
          titleTextStyle: TextStyle(fontSize: 24),
        ),
        expansionTileTheme: const ExpansionTileThemeData(
          shape: Border.symmetric(
            vertical: BorderSide.none,
          ),
        ),
      ),
      home: const MainPage(),
    );
  }
}