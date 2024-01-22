import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'Models/invoice_data.dart';
import 'Pages/main_page.dart';

final invoiceDataBox = Hive.box('InvoiceData').values;

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register for invoice class adapter
  Hive.registerAdapter(InvoiceDataAdapter());
  // Open user box
  await Hive.openBox('InvoiceData');

  runApp(const MyApp());
  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Color themeTextColor(final color) => color.computeLuminance() > 0.5 ? Colors.white : Colors.black;

  // This widget is the root of your application.
  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      title: 'Fast Invoice Reader',
      theme: ThemeData(
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle:
          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          border: OutlineInputBorder(),
          isDense: true,
          counterStyle: TextStyle(fontSize: 0),
          errorStyle: TextStyle(fontSize: 0),
        ),


        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black87),
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
          decorationColor: Colors.white,
        ),
        primaryTextTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
          decorationColor: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
            titleTextStyle: TextStyle(color: Colors.white,),
            backgroundColor: Colors.black,
            iconTheme: IconThemeData(color: Colors.white)
        ),
        scaffoldBackgroundColor: Colors.black87,
        useMaterial3: true,
      ),
      home: const CompanyList(title: 'Fast Invoice Reader'),
    );
  }
}
