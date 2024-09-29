import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:invoix/pages/main_page.dart';
import 'package:invoix/theme.dart';

class InvoixMain extends StatelessWidget {
  const InvoixMain({super.key});

  @override
  Widget build(final BuildContext context) {

    return MaterialApp(
      title: 'InvoiX',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('tr', ''), // Turkish
        // Other supported languages can be added here
      ],
      localeResolutionCallback: (final locale, final supportedLocales) {
        for (final supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            //return Locale('tr', '');
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
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
        listTileTheme: ListTileThemeData(
          shape: const Border(right: BorderSide(color: Colors.white, width: 2.5)),
          tileColor: Colors.grey[850],
          titleTextStyle: const TextStyle(fontSize: 20),
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
