import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoix/states/firebase_state.dart';
import 'package:invoix/states/hive_state.dart';
import 'package:invoix/states/invoice_data_state.dart';

class GlobalProviderContainer {
  static final GlobalProviderContainer _instance = GlobalProviderContainer._internal();
  late final ProviderContainer container;

  factory GlobalProviderContainer() {
    return _instance;
  }

  GlobalProviderContainer._internal() {
    container = ProviderContainer();
  }

  static ProviderContainer get() => _instance.container;

  static Future<void> initialize() async {
    final container = get();
    await container.read(hiveServiceProvider).initialize();
    await container.read(firebaseServiceProvider).initialize();
    await container.read(invoiceDataServiceProvider).initialize();
  }
}
