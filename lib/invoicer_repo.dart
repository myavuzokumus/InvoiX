import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class InvoicerRepo{

  final Image InvoiceImage;
  final String id;
  final String CompanyName;
  final String InvoiceNo;
  final DateTime Date;
  final double Amount;

  const InvoicerRepo({
    required this.id,
    required this.InvoiceImage,
    required this.CompanyName,
    required this.InvoiceNo,
    required this.Date,
    required this.Amount

  });

}

class InvoicerList extends Notifier<List<InvoicerRepo>>{

  @override
  List<InvoicerRepo> build() => [];

  void add({required Image InvoiceImage, required String CompanyName, required String InvoiceNo, required DateTime Date, required double Amount}) {
    state = [
      ...state,
      InvoicerRepo(
        id: _uuid.v4(),
        InvoiceImage: InvoiceImage,
        CompanyName: CompanyName,
        InvoiceNo: InvoiceNo,
        Date: Date,
        Amount: Amount,
      ),
    ];
  }

  void remove(InvoicerRepo target) {
    state = state.where((Invoicer) => Invoicer.id != target.id).toList();
  }
}

final InvoicerListProvider = NotifierProvider<InvoicerList, List<InvoicerRepo>>(InvoicerList.new);