import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:invoix/invoix_main.dart';
import 'package:invoix/states/firebase_state.dart';
import 'package:invoix/states/hive_state.dart';
import 'package:invoix/states/invoice_data_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();

  //initialize services
  await container.read(hiveServiceProvider).initialize();
  await container.read(firebaseServiceProvider).initialize();
  await container.read(invoiceDataServiceProvider).initialize();

  runApp(UncontrolledProviderScope(
      container: container, child: const InvoixMain()));

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
