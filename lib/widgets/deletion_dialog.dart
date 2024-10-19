import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoix/l10n/localization_extension.dart';
import 'package:invoix/services/invoice_data_service.dart';
import 'package:invoix/states/invoice_data_state.dart';
import 'package:invoix/states/selection_state.dart';
import 'package:invoix/widgets/toast.dart';

class DeletionDialog extends ConsumerStatefulWidget {
  const DeletionDialog(
      {super.key,
      this.companyName,
      required this.type,
      required this.selectionProvider})
      : assert(
            type != ListType.invoice ||
                (type == ListType.invoice && companyName != null),
            'companyName must be provided when type is ListType.invoice');

  final ListType type;
  final String? companyName;
  final AutoDisposeStateNotifierProvider<SelectionNotifier, SelectionState>
      selectionProvider;

  @override
  ConsumerState<DeletionDialog> createState() => _DeletionDialogState();
}

class _DeletionDialogState extends ConsumerState<DeletionDialog> {
  bool _isDeleting = false;
  late final dynamic selectedItems;
  late final InvoiceDataService invoiceDataService;

  @override
  void initState() {
    invoiceDataService = ref.read(invoiceDataServiceProvider);
    selectedItems = widget.type == ListType.company
        ? ref.read(widget.selectionProvider).selectedItems
        : ref.read(widget.selectionProvider).selectedItems[widget.companyName];

    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.selectionMode_delete_title(widget.type.name)),
      content: Text(context.l10n.selectionMode_delete_message(widget.type.name, selectedItems.length,)),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(context.l10n.button_cancel),
        ),
        _isDeleting
            ? const CircularProgressIndicator()
            : TextButton(
                onPressed: () async {
                  setState(() {
                    _isDeleting = true;
                  });

                  showToast(
                    text:
                        context.l10n.selectionMode_delete_success(widget.type.name, selectedItems.length),
                    color: Colors.green,
                  );

                  switch (widget.type) {
                    case ListType.company:
                      final companyList = List.from(selectedItems.keys);
                      for (final String company in companyList) {
                        await InvoiceDataService().deleteCompany(company);
                        selectedItems.remove(company);
                      }

                      // If the company list is empty, exit selection mode
                      if ((await InvoiceDataService().getCompanyList())
                          .isEmpty) {
                        ref
                            .read(companySelectionProvider.notifier)
                            .toggleSelectionMode();
                      }
                    case ListType.invoice:
                      await InvoiceDataService().deleteInvoiceData(
                          selectedItems);
                      if ((await InvoiceDataService()
                              .getInvoiceList(widget.companyName!))
                          .isEmpty) {
                        ref
                            .read(invoiceSelectionProvider.notifier)
                            .toggleSelectionMode();

                      }
                  }
                  Navigator.of(context)
                      .popUntil((final route) => route.isFirst);
                  setState(() {
                    _isDeleting = false;
                  });
                },
                child: Text(context.l10n.button_delete),
              ),
      ],
    );
  }
}
