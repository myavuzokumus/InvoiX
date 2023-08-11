

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InvoicerRepo{

  final String CompanyName;
  final String InvoiceNo;
  final DateTime Date;
  final double Amount;
  final Image InvoiceImage;

  const InvoicerRepo({required this.InvoiceImage, required this.CompanyName, required this.InvoiceNo, required this.Date, required this.Amount});

}

class InvoicerList extends Notifier<List<InvoicerRepo>>{

  @override
  List<InvoicerRepo> build() => [];

  void add({required Image InvoiceImage, required String CompanyName, required String InvoiceNo, required DateTime Date, required double Amount}) {
    state = [
      ...state,
      InvoicerRepo(
        InvoiceImage: InvoiceImage,
        CompanyName: CompanyName,
        InvoiceNo: InvoiceNo,
        Date: Date,
        Amount: Amount,
      ),
    ];
  }

  void remove(InvoicerRepo target) {
    state = state.where((Invoicer) => Invoicer.CompanyName != target.CompanyName).toList();
  }
}