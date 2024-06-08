import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoix/pages/InvoicesPage/invoice_list.dart';
import 'package:invoix/pages/SelectionState.dart';
import 'package:invoix/utils/export_to_excel.dart';
import 'package:invoix/utils/invoice_data_service.dart';
import 'package:invoix/widgets/deletion_dialog.dart';
import 'package:invoix/widgets/general_page_scaffold.dart';
import 'package:invoix/widgets/toast.dart';

class InvoicePage extends ConsumerWidget {
  final String companyName;

  const InvoicePage({required this.companyName, super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {

    final selectionState = ref.watch(invoiceProvider);

    return PopScope(
      canPop: !selectionState.isSelectionMode,
      onPopInvoked: (final bool bool) {
        if (selectionState.isSelectionMode) {
          ref.read(invoiceProvider.notifier).toggleSelectionMode();
        }
      },
      child: GeneralPage(
          selectionProvider: invoiceProvider,
          title: "InvoiX\n",
          companyName: companyName,
          body: InvoiceList(companyName: companyName),
          onExcelExport: () => exportToExcel(
              companyName: companyName, listType: ListType.invoice),
          onDelete: () async {
            try {
                if (selectionState.selectedItems.isNotEmpty)
                  {
                    showDialog(
                      context: context,
                      builder: (final BuildContext context) {
                        return DeletionDialog(
                            type: ListType.invoice, companyName: companyName, selectionProvider: invoiceProvider);
                      },
                    );
                  }
                else
                  {
                    Toast(
                      context,
                      text: "No company selected for deletion!",
                      color: Colors.redAccent,
                    );
                  }
              } catch (e) {
                Toast(
                  context,
                  text: "An error occurred while deleting company! $e",
                  color: Colors.redAccent,
                );
              }
              },
    ));
  }
}
