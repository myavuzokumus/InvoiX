import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:invoix/pages/main_page.dart';
import 'package:invoix/pages/welcome_page.dart';
import 'package:invoix/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InvoixMain extends StatefulWidget {
  const InvoixMain({super.key});

  @override
  State<InvoixMain> createState() => _InvoixMainState();
}

class _InvoixMainState extends State<InvoixMain> {
  bool _showWelcomePage = false;

  @override
  void initState() {
    super.initState();
    _checkFirstSeen();
  }

  Future<void> _checkFirstSeen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool seen = (prefs.getBool('seen') ?? false);

    setState(() {
      _showWelcomePage = !seen;
    });
  }

  void _onWelcomePageDone() {
    setState(() {
      _showWelcomePage = false;
    });
  }

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
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      theme: const MaterialTheme(TextTheme()).dark().copyWith(
            inputDecorationTheme: InputDecorationTheme(
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(150),
              ),
              isDense: true,
              counterStyle: const TextStyle(fontSize: 0),
              errorStyle: const TextStyle(fontSize: 0),
            ),
            listTileTheme: ListTileThemeData(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
              ),
              tileColor: Colors.grey[850],
              titleTextStyle: const TextStyle(fontSize: 18),
            ),
            expansionTileTheme: const ExpansionTileThemeData(
              shape: Border.symmetric(
                vertical: BorderSide.none,
              ),
            ),
          ),
      home: _showWelcomePage
          ? WelcomePage(onDone: _onWelcomePageDone)
          : const MainPage(),
    );
  }
}
