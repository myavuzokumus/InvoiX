import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:invoix/models/invoice_data.dart';
import 'package:invoix/services/invoice_data_service.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

Future<void> exportToExcel(final Map<String, dynamic> params) async {

  final ListType listType = params['listType'];
  final String? companyName = params['companyName'];

  final Map<String, List<InvoiceData>> inputList = Map.from({});

  for (final entry in params['inputList'].entries) {
    final key = entry.key;
    final value = entry.value;
    inputList[key] = value.map<InvoiceData>((final e) {
      return InvoiceData.fromJson(e);
    }).toList();
  }

  print(inputList);
  final String path = params['path'];

  // PermissionStatus status = await Permission.manageExternalStorage.status;
  //
  // if (status.isPermanentlyDenied) {
  //   // The user opted to never again see the permission request dialog for this
  //   // app. The only way to change the permission's status now is to let the
  //   // user manually enable it in the system settings.
  //   unawaited(openAppSettings());
  //   throw Exception('Storage permission not granted.');
  // } else if (!status.isGranted) {
  //   status = await Permission.manageExternalStorage.request();
  //   if (!status.isGranted) {
  //     throw Exception('Storage permission not granted.');
  //   }
  // }

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
    final companies = inputList.keys.toList();

    for (final String companyName in companies) {
      final Worksheet sheet;

      if (companies.elementAt(0) == companyName) {
        sheet = workbook.worksheets[0];
        sheet.name = companyName;
      } else {
        // Create a new worksheet for each company
        sheet = workbook.worksheets.addWithName(companyName);
      }

      await _importInvoiceData(sheet, titleStyle, cellStyle, inputList[companyName]!);
    }
  } else if (listType == ListType.invoice) {
    if (companyName == null) {
      throw ArgumentError('companyName cannot be null for invoice list type.');
    }

    final Worksheet sheet = workbook.worksheets[0];

    await _importInvoiceData(sheet, titleStyle, cellStyle, inputList[companyName]!);
  }
  try {
    // Save the Excel file.
    final List<int> bytes = workbook.saveAsStream();

    final String fileName = ListType.invoice == listType
        ? "InvoiX-$companyName-${DateTime.now()}.xlsx".replaceAll(":", ".")
        : "InvoiX-All-${DateTime.now()}.xlsx".replaceAll(":", ".");

    // Write the Excel file to the documents directory.
    await File('$path/$fileName').writeAsBytes(bytes);
  } catch (e) {
    throw Exception('Failed to retrieve downloads folder path. $e');
  } finally {
    workbook.dispose();
  }
}

Future<void> _importInvoiceData(
    final Worksheet sheet,
    final titleStyle,
    final cellStyle,
    final List<InvoiceData> invoices) async {

  sheet.getRangeByName('A1:G1').cellStyle = titleStyle;

  // Create Excel headers
  sheet.getRangeByName('A1').setText('Invoice Number');
  sheet.getRangeByName('B1').setText('Date');
  sheet.getRangeByName('C1').setText('Total Amount');
  sheet.getRangeByName('D1').setText('Tax Amount');
  sheet.getRangeByName('E1').setText('Company Id');
  sheet.getRangeByName('F1').setText('Unit');
  sheet.getRangeByName('G1').setText('Image');

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

    sheet.getRangeByName('E${i + 2}')
      ..setText(invoices[i].companyId)
      ..cellStyle = cellStyle;

    sheet.getRangeByName('F${i + 2}')
      ..setText(invoices[i].unit)
      ..cellStyle = cellStyle;

    sheet.pictures.addStream(i + 2, 7, image)
      ..height = 344
      ..width = 216;
    sheet.getRangeByName('G${i + 2}')
      ..columnWidth = 32
      ..rowHeight = 256
      ..cellStyle = cellStyle;
    // ... add more data as needed
  }

  sheet
    ..autoFitColumn(1)
    ..autoFitColumn(2)
    ..autoFitColumn(3)
    ..autoFitColumn(4)
    ..autoFitColumn(5)
    ..autoFitColumn(6);
}
