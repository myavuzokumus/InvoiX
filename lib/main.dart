import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:invoix/invoix_main.dart';
import 'package:invoix/services/firebase_service.dart';
import 'package:invoix/services/hive_service.dart';
import 'package:invoix/services/invoice_data_service.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  final hiveService = HiveService();
  await hiveService.initialize();

  final firebaseService = FirebaseService();
  await firebaseService.initialize();

  final invoiceDataService = InvoiceDataService();
  await invoiceDataService.initialize();

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
