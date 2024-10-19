import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:invoix/l10n/localization_extension.dart';
import 'package:invoix/models/invoice_data.dart';
import 'package:invoix/services/hive_service.dart';
import 'package:invoix/utils/legacy_mode/text_to_invoicedata_regex.dart';
import 'package:string_similarity/string_similarity.dart';

enum ListType { company, invoice }

extension ListTypeExtension on ListType {
  String get name {
    switch (this) {
      case ListType.company:
        return LocalizationManager.instance.appLocalization.listType_company;
      case ListType.invoice:
        return LocalizationManager.instance.appLocalization.listType_invoice;
    }
  }
}

enum CompanyType { SP, LTD, LLC, PLC, INC, GMBH, CORP, JSC }

extension CompanyTypeExtension on CompanyType {
  String get name {
    switch (this) {
      case CompanyType.SP:
        return LocalizationManager.instance.appLocalization.companyType_SP;
      case CompanyType.CORP:
        return LocalizationManager.instance.appLocalization.companyType_Corp;
      case CompanyType.LLC:
        return LocalizationManager.instance.appLocalization.companyType_LLC;
      case CompanyType.PLC:
        return LocalizationManager.instance.appLocalization.companyType_PLC;
      case CompanyType.INC:
        return LocalizationManager.instance.appLocalization.companyType_INC;
      case CompanyType.GMBH:
        return LocalizationManager.instance.appLocalization.companyType_GmbH;
      case CompanyType.JSC:
        return LocalizationManager.instance.appLocalization.companyType_JSC;
      case CompanyType.LTD:
        return LocalizationManager.instance.appLocalization.companyType_LTD;
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

  String get translatedName {
    switch (this) {
      case InvoiceCategory.Food:
        return LocalizationManager.instance.appLocalization.category_food;
      case InvoiceCategory.Clothing:
        return LocalizationManager.instance.appLocalization.category_clothing;
      case InvoiceCategory.Electronics:
        return LocalizationManager.instance.appLocalization.category_electronics;
      case InvoiceCategory.Health:
        return LocalizationManager.instance.appLocalization.category_health;
      case InvoiceCategory.Education:
        return LocalizationManager.instance.appLocalization.category_education;
      case InvoiceCategory.Transportation:
        return LocalizationManager.instance.appLocalization.category_transportation;
      case InvoiceCategory.Entertainment:
        return LocalizationManager.instance.appLocalization.category_entertainment;
      case InvoiceCategory.Shopping:
        return LocalizationManager.instance.appLocalization.category_shopping;
      case InvoiceCategory.Others:
        return LocalizationManager.instance.appLocalization.category_others;
    }
  }

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

enum PriceUnit {
  EUR,
  USD,
  TRY,
  GBP,
  JPY,
  CNY,
  RUB,
  AUD,
  CAD,
  Others;

  static PriceUnit? parse(final String category) {
    return PriceUnit.values.firstWhere(
            (final PriceUnit e) => category.contains(e.name), orElse: () {
      //print('Invalid category name: $category');
      return PriceUnit.Others;
    });
  }
}



class InvoiceDataService {
  static final InvoiceDataService _instance = InvoiceDataService._internal();

  factory InvoiceDataService() {
    return _instance;
  }

  InvoiceDataService._internal();

  late final Box<InvoiceData> invoiceDataBox;
  late final Box<int> remainingTimeBox;

  Future<void> initialize() async {
    invoiceDataBox = await HiveService().openBox<InvoiceData>('InvoiceData');
    remainingTimeBox = await HiveService().openBox<int>('remainingTimeBox');
  }

  Future<void> saveInvoiceData(final InvoiceData invoiceData) async {
    await invoiceDataBox.put(invoiceData.id, invoiceData);
  }

  Future<void> deleteInvoiceData(final List<InvoiceData> invoiceData) async {
    await remainingTimeBox.deleteAll(
        invoiceData.map((final invoiceData) => invoiceData.imagePath));
    await invoiceDataBox
        .deleteAll(invoiceData.map((final invoiceData) => invoiceData.id));
  }

  Future<void> deleteCompany(final String companyName) async {
    final invoices = await getInvoiceList(companyName);
    for (final invoice in invoices) {
      await deleteInvoiceData([invoice]);
    }
  }

  InvoiceData? getInvoiceData(final InvoiceData invoiceData) {
    return invoiceDataBox.get(invoiceData.id);
  }

  Future<List<InvoiceData>> getInvoiceList(final String companyName) async {
    return invoiceDataBox.values
        .where((final element) => companyName == element.companyName)
        .toList();
  }

  Future<List<String>> getCompanyList() async {
    return invoiceDataBox.values
        .map((final item) => item.companyName)
        .toSet()
        .toList();
  }

  Future<List<InvoiceData>> getAllInvoices() async {
    return invoiceDataBox.values.toList();
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

  Future<List<InvoiceData>> getInvoicesBetweenDates(
      final DateTime startDate, final DateTime endDate) async {
    final allInvoices = await getAllInvoices();
    return allInvoices
        .where((final invoice) => isInvoiceBetweenDates(invoice, startDate, endDate))
        .toList();
  }

  bool isInvoiceBetweenDates(final InvoiceData invoice,
      final DateTime startDate, final DateTime endDate) {
    return ((invoice.date.isAfter(startDate) || invoice.date.isAtSameMomentAs(startDate)) &&
        (invoice.date.isBefore(endDate) || invoice.date.isAtSameMomentAs(endDate)));
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