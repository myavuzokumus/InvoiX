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

  Future<void> onDelete(final context, final SelectionState selectionState) async {

    final selectedItems = List.from(selectionState.selectedInvoices);

    if (selectedItems.isNotEmpty) {

      await showDialog(context: context, builder: (final BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Invoice(s)"),
          content: Text("Are you sure you want to delete ${selectedItems.length.toString()} invoice(s)?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                for (final InvoiceData invoiceData in selectedItems) {
                  await InvoiceDataService().deleteInvoiceData(invoiceData);
                  selectionState.selectedInvoices.remove(invoiceData);
                  selectionState.listLength -= 1;
                }

                if ((await InvoiceDataService().getInvoiceList(companyName)).isEmpty) {
                Navigator.pop(context);
                }

                Toast(context,
                text: "${selectedItems.length.toString()} invoice(s) deleted successfully!",
                color: Colors.green,
                );
              },
              child: const Text("Delete"),
            ),
          ],
        );
      });




    } else {
      Toast(context,
        text: "No invoices selected for deletion!",
        color: Colors.redAccent,
      );
    }
  }

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {

    final selectionState = ref.watch(invoiceSelectionProvider);

    return PopScope(
      canPop: !selectionState.isSelectionMode,
      onPopInvoked: (final bool bool) {
        if (selectionState.isSelectionMode) {
          ref.read(invoiceSelectionProvider.notifier).toggleSelectionMode();
        }
      },
      child: GeneralPage(
        selectionProvider: invoiceSelectionProvider,
        title: "InvoiX\n",
        companyName: companyName,
        body: InvoiceList(companyName: companyName),
        onExcelExport: () => exportToExcel(companyName: companyName, listType: ListType.invoice),
        onDelete: () => onDelete(context, selectionState),
      ),
    );
  }
}
