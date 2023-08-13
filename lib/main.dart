import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'MainPage.dart';

void main() {
  runApp(const ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Color ThemeTextColor(color) => color.computeLuminance() > 0.5 ? Colors.white : Colors.black;
  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fast Invoicer Reader',
      theme: ThemeData(
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
      appBarTheme: AppBarTheme(
          titleTextStyle: TextStyle(color: Colors.white,),
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white)
      ),
      scaffoldBackgroundColor: Colors.black87,
      useMaterial3: true,
      ),
      home: const CompanyList(title: 'Fast Invoicer Reader'),
    );
  }
}