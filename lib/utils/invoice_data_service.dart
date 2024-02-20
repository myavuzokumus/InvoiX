import 'package:hive/hive.dart';
import 'package:invoix/models/invoice_data.dart';

enum ListType { company, invoice }

enum CompanyType { AS, LTD, STI, LLC, PLC, INC, GMBH }

extension CompanyTypeExtension on CompanyType {
  String get name {
    switch (this) {
      case CompanyType.AS:
        return 'A.Ş.';
      case CompanyType.LTD:
        return 'Ltd.';
      case CompanyType.STI:
        return 'Şti.';
      case CompanyType.LLC:
        return 'LLC';
      case CompanyType.PLC:
        return 'PLC';
      case CompanyType.INC:
        return 'Inc.';
      case CompanyType.GMBH:
        return 'GmbH';
    }
  }
}


final Box<InvoiceData> invoiceDataBox = Hive.box<InvoiceData>('InvoiceData');

class InvoiceDataService {

  Future<void> saveInvoiceData(final InvoiceData invoiceData) async {
    await invoiceDataBox.put(invoiceData.id, invoiceData);
  }

  Future<void> deleteInvoiceData(final InvoiceData invoiceData) async {
    final Box<int> remainingTimeBox = Hive.box<int>('remainingTimeBox');
    await remainingTimeBox.delete(invoiceData.imagePath);
    await invoiceDataBox.delete(invoiceData.id);
  }

  InvoiceData? getInvoiceData(final InvoiceData invoiceData) {
    return invoiceDataBox.get(invoiceData.id);
  }

  Future<List<InvoiceData>> getInvoiceList(final String companyName) async {

    final Iterable<InvoiceData> savedList = invoiceDataBox.values.cast<InvoiceData>();

    return savedList
        .where((final element) => companyName == element.companyName)
        .toList();
  }

  Future<List<String>> getCompanyList() async {
    final Iterable<InvoiceData> savedList = invoiceDataBox.values.cast<InvoiceData>();
    return savedList.map((final item) => item.companyName).toSet().toList();
  }
}


//  static Future<List<InvoiceData>> getCompanyList() async {
//
//     final Iterable<InvoiceData> savedList = invoiceDataBox.values.cast<InvoiceData>();
//     List<InvoiceData> returnList = [];
//
//     for (final element in savedList) {
//       if (!returnList.any((final item) => item.companyName == element.companyName)) {
//         returnList.add(element);
//       }
//     }
//     return returnList;
//   }