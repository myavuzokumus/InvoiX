import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
//import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'invoice_data.g.dart';

@HiveType(typeId: 0)
class InvoiceData extends HiveObject{

  @HiveField(0)
  final Image InvoiceImage;
  @HiveField(1)
  final String id = Uuid() as String;
  @HiveField(2)
  final String CompanyName;
  @HiveField(3)
  final String InvoiceNo;
  @HiveField(4)
  final DateTime Date;
  @HiveField(5)
  final double Amount;

  InvoiceData({
    required this.InvoiceImage,
    required this.CompanyName,
    required this.InvoiceNo,
    required this.Date,
    required this.Amount
  }
  );

}


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