import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoix/models/invoice_data.dart';
import 'package:invoix/pages/InvoicesPage/invoice_list.dart';
import 'package:invoix/pages/SelectionState.dart';
import 'package:invoix/utils/export_to_excel.dart';
import 'package:invoix/utils/invoice_data_service.dart';
import 'package:invoix/widgets/general_page_scaffold.dart';
import 'package:invoix/widgets/toast.dart';

class InvoicePage extends ConsumerWidget {
  final String companyName;

  const InvoicePage({required this.companyName, super.key});


  void onDelete(final context, final SelectionState selectionData) {

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
  Widget build(final BuildContext context, final WidgetRef ref) {
    final selectionData = ref.read(invoiceSelectionProvider);
    return GeneralPage(
      selectionProvider: invoiceSelectionProvider,
      title: "InvoiX\n",
      companyName: companyName,
      body: InvoiceList(companyName: companyName),
      onExcelExport: () => exportToExcel(companyName: companyName, listType: ListType.invoice),
      onDelete: () {},
    );
  }
}
