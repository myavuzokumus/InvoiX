import 'dart:async';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:invoix/firebase_options.dart';
import 'package:invoix/invoix_main.dart';
import 'package:invoix/models/invoice_data.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(InvoiceDataAdapter());
  await Hive.openBox<InvoiceData>('InvoiceData');
  await Hive.openBox<int>('remainingTimeBox');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if(!kDebugMode) {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.appAttest,
      //webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    );
  } else {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
      //webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    );
  }

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
