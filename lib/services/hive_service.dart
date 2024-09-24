import 'package:hive_flutter/hive_flutter.dart';
import 'package:invoix/models/invoice_data.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();

  factory HiveService() {
    return _instance;
  }

  HiveService._internal();

  Future<void> initialize() async {
    await Hive.initFlutter();
    Hive.registerAdapter(InvoiceDataAdapter());
    //await Hive.openBox<InvoiceData>('InvoiceData');
    //await Hive.openBox<int>('remainingTimeBox');
  }

  Future<Box<T>> openBox<T>(final String boxName) async {
    return Hive.openBox<T>(boxName);
  }

}