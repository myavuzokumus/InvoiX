import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
//import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'invoice_data.g.dart';

@HiveType(typeId: 0)
class InvoiceData extends HiveObject {
  @HiveField(0)
  final String ImagePath;
  @HiveField(1)
  final String id = const Uuid().toString();
  @HiveField(2)
  final String companyName;
  @HiveField(3)
  final String invoiceNo;
  @HiveField(4)
  final DateTime date;
  @HiveField(5)
  final double totalAmount;
  @HiveField(6, defaultValue: 0.0)
  final double taxAmount;

  InvoiceData(
      {required this.ImagePath,
      required this.companyName,
      required this.invoiceNo,
      required this.date,
      required this.totalAmount,
      required this.taxAmount});

  InvoiceData.fromJson(final Map<String, dynamic> json)
      : ImagePath = json['ImagePath'],
        companyName = json['companyName'],
        invoiceNo = json['invoiceNo'],
        date = json['date'],
        totalAmount = json['totalAmount'],
        taxAmount = json['taxAmount'];

}

//final Uint8List ImagePath;
//import 'dart:typed_data';

//Under section will be useless in the future.
// class InvoicerList extends Notifier<List<InvoicerData>>{
//
//   @override
//   List<InvoicerData> build() => [];
//
//   void add({required Image InvoiceImage, required String CompanyName, required String InvoiceNo, required DateTime Date, required double Amount}) {
//     state = [
//       ...state,
//       InvoicerData(
//         id: _uuid.v4(),
//         InvoiceImage: InvoiceImage,
//         CompanyName: CompanyName,
//         InvoiceNo: InvoiceNo,
//         Date: Date,
//         Amount: Amount,
//       ),
//     ];
//   }
//
//   void remove(InvoicerData target) {
//     state = state.where((Invoicer) => Invoicer.id != target.id).toList();
//   }
// }
//
// final InvoicerListProvider = NotifierProvider<InvoicerList, List<InvoicerData>>(InvoicerList.new);
