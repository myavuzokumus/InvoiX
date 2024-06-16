import 'dart:convert';

import 'package:invoix/utils/date_parser.dart';
import 'package:invoix/utils/invoice_data_service.dart';
import 'package:invoix/utils/legacy_mode/text_to_invoicedata_regex.dart';

String parseInvoiceData(final List<String> listText) {
  final alphabetRegex = RegExp(r"[a-z]", caseSensitive: false);

  String? invoiceCompany = listText[0];
  String? invoiceNo;
  String? invoiceDate;
  double? totalAmount;
  double? taxAmount;

  for (final String i in listText) {
    if (companyRegex.hasMatch(i)) {
      invoiceCompany = assignCompany(i);
    } else if (dateRegex.hasMatch(i.replaceAll(" ", ""))) {
      invoiceDate = assignDate(i.replaceAll(" ", ""), dateRegex);
    } else if (invoiceNoRegex.hasMatch(i)) {
      invoiceNo = assignInvoiceNo(i);
    } else if (amountRegex.hasMatch(i.replaceAll(" ", "")) && !alphabetRegex.hasMatch(i)) {
      final List<double> amounts = assignAmount(i, listText);
      totalAmount = amounts[0];
      taxAmount = amounts[1];
    }

    // If invoiceNo is still null, try to find it from the list
    if (invoiceNo == null && i.toUpperCase().contains("NO")) {
      invoiceNo = assignInvoiceNoFromList(i, listText);
    }
  }

  final Map<String, Object?> value = {
    "companyName": invoiceCompany ?? "InvoiX",
    "invoiceNo": invoiceNo,
    "date": invoiceDate,
    "totalAmount": totalAmount,
    "taxAmount": taxAmount,
    "category": InvoiceCategory.Others.name
  };

  return jsonEncode(value);

}

String assignCompany(final String text) {
  return text;
}

String assignDate(String date, final RegExp dateRegex) {
  final RegExpMatch? matchedDate = dateRegex.firstMatch(date);
  if (matchedDate != null) {
    date = date.substring(matchedDate.start, matchedDate.end);
  }

  return(dateFormat.format(dateParser(date)));
}



List<double> assignAmount(String amount, final List<String> listText) {
  final nonDigitRegex = RegExp(r'[^0-9.,]');

  String tax = listText.elementAt(listText.indexOf(amount) - 1);

  amount = amount.replaceAll(" ", "").replaceAll(nonDigitRegex, "").replaceAll(",", ".");
  tax = tax.replaceAll(" ", "").replaceAll(nonDigitRegex, "").replaceAll(",", ".");

  final double totalAmount = double.parse(amount);
  final double taxAmount = double.tryParse(tax) ?? 0.0;

  return [totalAmount, taxAmount];
}


String assignInvoiceNo(String invoiceNo) {
  invoiceNo = invoiceNo.replaceAll(" ", "");
  if (invoiceNo.contains(":")) {
    invoiceNo = invoiceNo.split(":").last;
  }

  return invoiceNo;
}

String assignInvoiceNoFromList(String invoiceNo, final List<String> listText) {
  if (listText.length != listText.indexOf(invoiceNo) + 1) {
    invoiceNo = listText.elementAt(listText.indexOf(invoiceNo) + 1);
    invoiceNo = invoiceNo.replaceAll(" ", "");
    if (invoiceNo.contains(":")) {
      invoiceNo = invoiceNo.split(":").last;
    }
  }
  else {
    invoiceNo = "";
  }

  return invoiceNo;
}