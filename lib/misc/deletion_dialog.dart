import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoix/models/selection_state.dart';
import 'package:invoix/utils/invoice_data_service.dart';
import 'package:invoix/widgets/toast.dart';

class DeletionDialog extends ConsumerStatefulWidget {
  const DeletionDialog(
      {super.key,
      required this.type,
      this.companyName,
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
  late final selectedItems;

  @override
  void initState() {
    selectedItems = ref.read(widget.selectionProvider).selectedItems;
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    return AlertDialog(
      title: Text("Delete ${widget.type.name}(s)"),
      content: widget.type == ListType.company
          ? Text(
              "Are you sure you want to delete ${selectedItems.length.toString()} ${widget.type.name}(s)?")
          : Text(
              "Are you sure you want to delete ${selectedItems[widget.companyName].length.toString()} ${widget.type.name}(s)?"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),
        _isDeleting
            ? const CircularProgressIndicator()
            : TextButton(
                onPressed: () async {
                  setState(() {
                    _isDeleting = true;
                  });

                  Toast(
                    context,
                    text:
                        "${selectedItems.length.toString()} ${widget.type.name}(s) deleted successfully!",
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
                            .read(companyProvider.notifier)
                            .toggleSelectionMode();
                      }
                    case ListType.invoice:
                      await InvoiceDataService().deleteInvoiceData(
                          selectedItems[widget.companyName]!);
                      if ((await InvoiceDataService()
                              .getInvoiceList(widget.companyName!))
                          .isEmpty) {
                      }
                  }
                  Navigator.pop(context);
                  setState(() {
                    _isDeleting = false;
                  });
                },
                child: const Text("Delete"),
              ),
      ],
    );
  }
}
