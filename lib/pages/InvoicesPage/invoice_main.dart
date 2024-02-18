import 'package:flutter/material.dart';
import 'package:invoix/models/invoice_data.dart';
import 'package:invoix/pages/InvoicesPage/invoice_list.dart';
import 'package:invoix/pages/general_page_scaffold.dart';
import 'package:invoix/utils/export_to_excel.dart';
import 'package:invoix/utils/invoice_data_service.dart';
import 'package:invoix/widgets/toast.dart';

class InvoicePage extends StatelessWidget {
  final String companyName;

  const InvoicePage({required this.companyName, super.key});

  void onDelete(final context) {

    final selectionData = SelectionData.of(context);
    selectionData.selectedCompanies.add(companyName);

    final selectedItems = selectionData.selectedInvoices;

    if (selectedItems.isNotEmpty) {
      for (final InvoiceData invoiceData in selectedItems) {
        InvoiceDataService.deleteInvoiceData(invoiceData);
      }
      Toast(context,
        text: "${selectedItems.length} invoice(s) deleted successfully!",
        color: Colors.green,
      );
    } else {
      Toast(context,
        text: "No invoices selected for deletion!",
        color: Colors.redAccent,
      );
    }
  }

  @override
  Widget build(final BuildContext context) {
    return GeneralPage(
      title: "InvoiX\n",
      companyName: companyName,
      body: InvoiceList(companyName: companyName),
      onExcelExport: () => exportToExcel(companyName: companyName, listType: ListType.invoice),
      onDelete: () => onDelete(context),
    );
  }
}
