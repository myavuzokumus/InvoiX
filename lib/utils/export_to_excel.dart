import 'dart:async';
import 'dart:io';

import 'package:downloadsfolder/downloadsfolder.dart';
import 'package:flutter/foundation.dart';
import 'package:invoix/main.dart';
import 'package:invoix/models/invoice_data.dart';
import 'package:invoix/utils/company_name_filter.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

Future<void> exportToExcel({required final ListType listType, final String? companyName}) async {

/*  PermissionStatus status = await Permission.storage.status;

  if (status.isPermanentlyDenied) {
    // The user opted to never again see the permission request dialog for this
    // app. The only way to change the permission's status now is to let the
    // user manually enable it in the system settings.
    unawaited(openAppSettings());
    throw Exception('Storage permission not granted');
  } else if (!status.isGranted) {
    status = await Permission.storage.request();
    if (!status.isGranted) {
      throw Exception('Storage permission not granted');
    }
  }*/

  // Create a new Excel document.
  final Workbook workbook = Workbook();

  final titleStyle = workbook.styles.add('titleStyle');
  titleStyle
    ..fontSize = 16
    ..italic = true
    ..bold = true
    ..underline = true
    ..hAlign = HAlignType.center
    ..vAlign = VAlignType.center
    ..borders.all.lineStyle = LineStyle.medium
    ..borders.all.color = '#7a2922';

  final cellStyle = workbook.styles.add('cellStyle');
  cellStyle
    ..fontSize = 12
    ..hAlign = HAlignType.center
    ..vAlign = VAlignType.center
    ..borders.all.lineStyle = LineStyle.medium
    ..borders.all.color = '#e7bdb2';

  if (listType == ListType.company) {
    // Get all companies from Hive box
    final companies = await getInvoiceDataList(
        ListType.company, invoiceDataBox.values.cast<InvoiceData>());

    for (dynamic company in companies) {
      final Worksheet sheet;

      if (companies.elementAt(0) == company) {
        sheet = workbook.worksheets[0];
        sheet.name = company.companyName;
        company = company.companyName;
      }
      else {
        // Create a new worksheet for each company
        company = company.companyName;
        sheet = workbook.worksheets.addWithName(company);
      }

      await importInvoiceData(sheet, company, titleStyle, cellStyle);
    }
  } else if (listType == ListType.invoice) {

    if (companyName == null) {
      throw ArgumentError('companyName cannot be null for invoice list type.');
    }

    final Worksheet sheet = workbook.worksheets[0];

    await importInvoiceData(sheet, companyName, titleStyle, cellStyle);
  }

  final String? downloadDirectoryPath = await getDownloadDirectoryPath();

  if (downloadDirectoryPath != null) {
    // Save the Excel file.
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final String fileName;

    ListType.invoice == listType
        ? fileName = "InvoiX-$companyName-${DateTime.now()}.xlsx".replaceAll(":", ".")
        : fileName = "InvoiX-All-${DateTime.now()}.xlsx".replaceAll(":", ".");

    // Write the Excel file to the documents directory.
    await File('$downloadDirectoryPath/$fileName').writeAsBytes(bytes);
  } else {
    workbook.dispose();
    throw Exception('Failed to retrieve downloads folder path.');
  }

}

Future<void> importInvoiceData(final Worksheet sheet, final String company, final titleStyle, final cellStyle) async {
  sheet.getRangeByName('A1:D1').cellStyle = titleStyle;

  // Get all invoices for the current company
  final invoices = await getInvoiceDataList(ListType.invoice,
      invoiceDataBox.values.cast<InvoiceData>(), company);

  // Create Excel headers
  sheet.getRangeByName('A1').setText('Invoice Number');
  sheet.getRangeByName('B1').setText('Date');
  sheet.getRangeByName('C1').setText('Amount');
  sheet.getRangeByName('D1').setText('Image');

  // Fill the worksheet with invoice data
  for (var i = 0; i < invoices.length; i++) {
    final Uint8List image = await File(invoices[i].ImagePath).readAsBytes();

    sheet.getRangeByName('A${i + 2}')
      ..setText(invoices[i].invoiceNo.toString())
      ..cellStyle = cellStyle;

    sheet.getRangeByName('B${i + 2}')
      ..setDateTime(invoices[i].date)
      ..cellStyle = cellStyle;

    sheet.getRangeByName('C${i + 2}')
      ..setNumber(invoices[i].amount)
      ..cellStyle = cellStyle;

    sheet.pictures.addStream(i + 2, 4, image)
      ..height = 344
      ..width = 216;
    sheet.getRangeByName('D${i + 2}')
      ..columnWidth = 32
      ..rowHeight = 256
      ..cellStyle = cellStyle;
    // ... add more data as needed
  }

  sheet..autoFitColumn(1)..autoFitColumn(2)..autoFitColumn(3);
}
