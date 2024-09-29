import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoix/pages/InvoicesPage/invoice_list.dart';
import 'package:invoix/pages/list_page_scaffold.dart';
import 'package:invoix/services/invoice_data_service.dart';
import 'package:invoix/states/selection_state.dart';


class InvoicePage extends ConsumerWidget {
  final String companyName;

  const InvoicePage({required this.companyName, super.key});

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
      child: ListPageScaffold(
          selectionProvider: invoiceSelectionProvider,
          title: "InvoiX\n",
          type: ListType.invoice,
          companyName: companyName,
          body: InvoiceList(companyName: companyName),
    ));
  }
}
