import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoix/models/selection_state.dart';
import 'package:invoix/pages/InvoicesPage/invoice_list.dart';
import 'package:invoix/pages/list_page_scaffold.dart';
import 'package:invoix/utils/invoice_data_service.dart';


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
      child: ListPageScaffold(
          selectionProvider: invoiceProvider,
          title: "InvoiX\n",
          type: ListType.invoice,
          companyName: companyName,
          body: InvoiceList(companyName: companyName),
    ));
  }
}
