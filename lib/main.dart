import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:invoix/models/invoice_data.dart';

import 'pages/company_list.dart';
import 'theme.dart';

final invoiceDataBox = Hive.box('InvoiceData');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register for invoice class adapter
  Hive.registerAdapter(InvoiceDataAdapter());
  // Open user box
  await Hive.openBox('InvoiceData');

  await dotenv.load(fileName: ".env");
  Gemini.init(apiKey: dotenv.env['GEMINI_API_KEY']!);

  runApp(const InvoixMain());
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
