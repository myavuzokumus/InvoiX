import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:invoix/models/invoice_data.dart';
import 'package:invoix/utils/legacy_mode/text_to_invoicedata_regex.dart';
import 'package:string_similarity/string_similarity.dart';

enum ListType { company, invoice }

extension ListTypeExtension on ListType {
  String get name {
    switch (this) {
      case ListType.company:
        return 'Company';
      case ListType.invoice:
        return 'Invoice';
    }
  }
}

enum CompanyType { SP, LTD, LLC, PLC, INC, GMBH, CORP, JSC }

extension CompanyTypeExtension on CompanyType {
  String get name {
    switch (this) {
      case CompanyType.SP:
        return 'SP';
      case CompanyType.CORP:
        return 'Corp';
      case CompanyType.LLC:
        return 'LLC';
      case CompanyType.PLC:
        return 'PLC';
      case CompanyType.INC:
        return 'INC';
      case CompanyType.GMBH:
        return 'GmbH';
      case CompanyType.JSC:
        return 'JSC';
      case CompanyType.LTD:
        return 'LTD';
      }
  }
}

enum InvoiceCategory {
  Food,
  Clothing,
  Electronics,
  Health,
  Education,
  Transportation,
  Entertainment,
  Shopping,
  Others;

  static InvoiceCategory? parse(final String category) {
    return InvoiceCategory.values.firstWhere(
        (final InvoiceCategory e) => category.contains(e.name), orElse: () {
      //print('Invalid category name: $category');
      return InvoiceCategory.Others;
    });
  }
}

extension InvoiceCategoryExtension on InvoiceCategory {
  Color get color {
    switch (this) {
      case InvoiceCategory.Food:
        return Colors.yellow;
      case InvoiceCategory.Clothing:
        return Colors.blue;
      case InvoiceCategory.Electronics:
        return Colors.lightGreenAccent;
      case InvoiceCategory.Health:
        return Colors.red;
      case InvoiceCategory.Education:
        return Colors.purple;
      case InvoiceCategory.Transportation:
        return Colors.orange;
      case InvoiceCategory.Entertainment:
        return Colors.pink;
      case InvoiceCategory.Shopping:
        return Colors.teal;
      case InvoiceCategory.Others:
        return Colors.grey;
    }
  }

  ImageProvider get icon {
    switch (this) {
      case InvoiceCategory.Food:
        return const AssetImage('assets/icons/categories/food.png');
      case InvoiceCategory.Clothing:
        return const AssetImage('assets/icons/categories/clothing.png');
      case InvoiceCategory.Electronics:
        return const AssetImage('assets/icons/categories/electronics.png');
      case InvoiceCategory.Health:
        return const AssetImage('assets/icons/categories/health.png');
      case InvoiceCategory.Education:
        return const AssetImage('assets/icons/categories/education.png');
      case InvoiceCategory.Transportation:
        return const AssetImage('assets/icons/categories/transportation.png');
      case InvoiceCategory.Entertainment:
        return const AssetImage('assets/icons/categories/entertainment.png');
      case InvoiceCategory.Shopping:
        return const AssetImage('assets/icons/categories/shopping.png');
      case InvoiceCategory.Others:
        return const AssetImage('assets/icons/categories/others.png');
    }
  }
}

final Box<InvoiceData> invoiceDataBox = Hive.box<InvoiceData>('InvoiceData');

class InvoiceDataService {
  Future<void> saveInvoiceData(final InvoiceData invoiceData) async {
    await invoiceDataBox.put(invoiceData.id, invoiceData);
  }

  Future<void> deleteInvoiceData(final List<InvoiceData> invoiceData) async {
    final Box<int> remainingTimeBox = Hive.box<int>('remainingTimeBox');
    await remainingTimeBox.deleteAll(
        invoiceData.map((final invoiceData) => invoiceData.imagePath));
    await invoiceDataBox
        .deleteAll(invoiceData.map((final invoiceData) => invoiceData.id));
  }

  Future<void> deleteCompany(final String companyName) async {
    await getInvoiceList(companyName).then((final List<InvoiceData> invoices) {
      for (final InvoiceData invoice in invoices) {
        deleteInvoiceData([invoice]);
      }
    });
  }

  InvoiceData? getInvoiceData(final InvoiceData invoiceData) {
    return invoiceDataBox.get(invoiceData.id);
  }

  Future<List<InvoiceData>> getInvoiceList(final String companyName) async {
    final Iterable<InvoiceData> savedList =
        invoiceDataBox.values.cast<InvoiceData>();

    return savedList
        .where((final element) => companyName == element.companyName)
        .toList();
  }

  Future<List<String>> getCompanyList() async {
    final Iterable<InvoiceData> savedList =
        invoiceDataBox.values.cast<InvoiceData>();
    return savedList.map((final item) => item.companyName).toSet().toList();
  }

  Future<List<InvoiceData>> getAllInvoices() async {
    return invoiceDataBox.values.cast<InvoiceData>().toList();
  }

  CompanyType companyTypeFinder(String companyName) {
    return CompanyType.values.firstWhere((final CompanyType e) {

      companyName = companyName.replaceAll(" ", "");
      if (companyName.contains(invalidCompanyRegex)) {
        companyName = companyName.replaceAll(invalidCompanyRegex, "JSC");
      }

      final List matchList =
          companyRegex.allMatches(companyName).toList();
      final RegExpMatch? pairedType =
          matchList.isNotEmpty ? matchList.last : null;
      if (pairedType == null) {
        return false;
      }

      return companyName
              .substring(pairedType.start, pairedType.end)
              .similarityTo(e.name) >
          0.3;
    }, orElse: () => CompanyType.LTD);
  }

  // Filter invoices by date range
  Future<List<InvoiceData>> getInvoicesBetweenDates(
      final DateTime startDate, final DateTime endDate) async {
    final List<InvoiceData> allInvoices =
        await InvoiceDataService().getAllInvoices();
    return allInvoices
        .where((final invoice) =>
            isInvoiceBetweenDates(invoice, startDate, endDate))
        .toList();
  }

  bool isInvoiceBetweenDates(final InvoiceData invoice,
      final DateTime startDate, final DateTime endDate) {
    return ((invoice.date.isAfter(startDate) || invoice.date.isAtSameMomentAs(startDate))&&
        (invoice.date.isBefore(endDate) ||
            invoice.date.isAtSameMomentAs(endDate)));
  }

  bool isSameInvoice(
      final InvoiceData invoiceData1, final InvoiceData invoiceData2) {
    return invoiceData1 == invoiceData2;
  }

  String companyTypeExtractor(String text) {
    text = text.replaceAll(companyRegex, "");
    List matchList = companyRegex.allMatches(text).toList();
    RegExpMatch? pairedType = matchList.isNotEmpty ? matchList.first : null;
    if (pairedType == null) {
      matchList = companyRegex.allMatches(text.replaceAll(" ", "")).toList();
      pairedType = matchList.isNotEmpty ? matchList.first : null;
    }
    if (pairedType != null) {
      text = text.substring(0, pairedType.start - 1);
    }

    text = text.trim();
    if (text.isEmpty) {
      throw "Company name cannot be empty.";
    }

    return text;
  }

  String invalidCompanyTypeExtractor(String text) {
    text = text.replaceAll(invalidCompanyRegex, "");
    List matchList = invalidCompanyRegex.allMatches(text).toList();
    RegExpMatch? pairedType = matchList.isNotEmpty ? matchList.first : null;
    if (pairedType == null) {
      matchList = invalidCompanyRegex.allMatches(text.replaceAll(" ", "")).toList();
      pairedType = matchList.isNotEmpty ? matchList.first : null;
    }
    if (pairedType != null) {
      text = text.substring(0, pairedType.start - 1);
    }

    text = text.trim();
    if (text.isEmpty) {
      throw "Company name cannot be empty.";
    }

    return text;
  }

}
