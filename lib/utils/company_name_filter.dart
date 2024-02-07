import 'package:invoix/models/invoice_data.dart';

enum ListType { company, invoice }

Future<List<InvoiceData>> getInvoiceDataList(
    final ListType type, final Iterable<InvoiceData> savedList,
    [final String? companyName]) async {
  await null;

  List<InvoiceData> returnList = [];

  switch (type) {
    case ListType.company:

      for (final element in savedList) {
        if (!returnList.any((final item) => item.companyName == element.companyName)) {
          returnList.add(element);
        }
      }

      return returnList;

    case ListType.invoice:
      returnList = savedList
          .where((final element) => companyName == element.companyName)
          .toList();
      return returnList;
  }
}
