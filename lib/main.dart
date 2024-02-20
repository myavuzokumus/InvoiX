import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:invoix/models/invoice_data.dart';
import 'package:invoix/pages/CompaniesPage/company_main.dart';

import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(InvoiceDataAdapter());
  await Hive.openBox<InvoiceData>('InvoiceData');
  await Hive.openBox<int>('remainingTimeBox');

  await dotenv.load(fileName: ".env");

  runApp(const ProviderScope(child: InvoixMain()));

  final Box<int> box = Hive.box<int>('remainingTimeBox');
  for (final key in box.keys) {
    int remainingTime = box.get(key) ?? 0;
    if (remainingTime > 0) {
      Timer.periodic(const Duration(seconds: 1), (final t) async {
        remainingTime -= 1;

        if (remainingTime <= 0) {
          remainingTime = 0;
          t.cancel();
        }
        await box.put(key, remainingTime);
      });
    }
  }
}

class InvoixMain extends StatelessWidget {
  const InvoixMain({super.key});

  @override
  Widget build(final BuildContext context) {

    return MaterialApp(
      title: 'InvoiX',
      theme: const MaterialTheme(TextTheme()).dark().copyWith(

      inputDecorationTheme: const InputDecorationTheme(
             labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
             border: OutlineInputBorder(),
             isDense: true,
             counterStyle: TextStyle(fontSize: 0),
             errorStyle: TextStyle(fontSize: 0),
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
      home: const CompanyPage(),
    );
  }
}
