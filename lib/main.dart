import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoix/invoix_main.dart';
import 'package:invoix/states/global_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //initialize services
  await GlobalProviderContainer.initialize();

  runApp(UncontrolledProviderScope(
      container: GlobalProviderContainer.get(), child: const InvoixMain()));

}
