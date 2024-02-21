import 'dart:async';
import 'dart:io';

import 'package:downloadsfolder/downloadsfolder.dart';
import 'package:flutter/foundation.dart';
import 'package:invoix/utils/invoice_data_service.dart';
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
    final companies = await InvoiceDataService().getCompanyList();

    if (companies.isEmpty) {
      throw Exception('No companies found.');
    }

    for (final String companyName in companies) {
      final Worksheet sheet;

      if (companies.elementAt(0) == companyName) {
        sheet = workbook.worksheets[0];
        sheet.name = companyName;
      }
      else {
        // Create a new worksheet for each company
        sheet = workbook.worksheets.addWithName(companyName);
      }

      await importInvoiceData(sheet, companyName, titleStyle, cellStyle);
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

Future<void> importInvoiceData(final Worksheet sheet, final String companyName, final titleStyle, final cellStyle) async {
  sheet.getRangeByName('A1:E1').cellStyle = titleStyle;

  // Get all invoices for the current company
  final invoices = await InvoiceDataService().getInvoiceList(companyName);

  // Create Excel headers
  sheet.getRangeByName('A1').setText('Invoice Number');
  sheet.getRangeByName('B1').setText('Date');
  sheet.getRangeByName('C1').setText('Total Amount');
  sheet.getRangeByName('D1').setText('Tax Amount');
  sheet.getRangeByName('E1').setText('Image');

  // Fill the worksheet with invoice data
  for (var i = 0; i < invoices.length; i++) {
    final Uint8List image = await File(invoices[i].imagePath).readAsBytes();

    sheet.getRangeByName('A${i + 2}')
      ..setText(invoices[i].invoiceNo.toString())
      ..cellStyle = cellStyle;

    sheet.getRangeByName('B${i + 2}')
      ..setDateTime(invoices[i].date)
      ..cellStyle = cellStyle
      ..numberFormat = 'dd/mm/yyyy';

    sheet.getRangeByName('C${i + 2}')
      ..setNumber(invoices[i].totalAmount)
      ..cellStyle = cellStyle;

    sheet.getRangeByName('D${i + 2}')
      ..setNumber(invoices[i].taxAmount)
      ..cellStyle = cellStyle;

    sheet.pictures.addStream(i + 2, 5, image)
      ..height = 344
      ..width = 216;
    sheet.getRangeByName('E${i + 2}')
      ..columnWidth = 32
      ..rowHeight = 256
      ..cellStyle = cellStyle;
    // ... add more data as needed
  }

  sheet..autoFitColumn(1)..autoFitColumn(2)..autoFitColumn(3)..autoFitColumn(4);
}
