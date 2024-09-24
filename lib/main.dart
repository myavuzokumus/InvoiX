import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoix/invoix_main.dart';
import 'package:invoix/states/firebase_state.dart';
import 'package:invoix/states/hive_state.dart';
import 'package:invoix/states/invoice_data_state.dart';
import 'package:invoix/utils/cooldown.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();

  //initialize services
  await container.read(hiveServiceProvider).initialize();
  await container.read(firebaseServiceProvider).initialize();
  final invoiceDataService = container.read(invoiceDataServiceProvider);
  await invoiceDataService.initialize();

  for (final key in invoiceDataService.remainingTimeBox.keys) {
    final int remainingTime = invoiceDataService.remainingTimeBox.get(key) ?? 0;
    if (remainingTime > 0) {

      await cooldown(remainingTime, key, invoiceDataService);

    }
  }

  runApp(UncontrolledProviderScope(
      container: container, child: const InvoixMain()));

}
