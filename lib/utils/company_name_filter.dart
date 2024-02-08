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
