import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoix/services/invoice_data_service.dart';

final invoiceDataServiceProvider = Provider<InvoiceDataService>((final ref) {
  return InvoiceDataService();
});
