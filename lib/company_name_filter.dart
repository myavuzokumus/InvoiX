import 'Models/invoice_data.dart';

enum listType {
  company,
  invoice
}

Future<List<InvoiceData>> getInvoiceDataList(final listType type, final Iterable<InvoiceData> savedList, [final String? companyName]) async {
  await null;
  List<InvoiceData> returnList = [];
  switch (type) {
    case listType.company:
      returnList = savedList.where((final element) => !returnList.contains(element.companyName)).toList();
      print(returnList);
      return returnList;

    case listType.invoice:
      returnList = savedList.where((final element) => companyName == element.companyName).toList();
      print(returnList);
      return returnList;
  }

}
