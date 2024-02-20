import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoix/pages/SelectionState.dart';
import 'package:invoix/utils/invoice_data_service.dart';
import 'package:invoix/widgets/toast.dart';

class GeneralPage extends ConsumerStatefulWidget {
  final String title;
  final String? companyName;

  final Widget body;
  final Widget? floatingActionButton;

  final Function onExcelExport;
  final Function onDelete;

  final AutoDisposeStateNotifierProvider<SelectionNotifier, SelectionState> selectionProvider;

  const GeneralPage({super.key, required this.title, this.companyName, required this.body, this.floatingActionButton, required this.onExcelExport, required this.onDelete, required this.selectionProvider});

  @override
  ConsumerState<GeneralPage> createState() => _GeneralPageState();
}

class _GeneralPageState extends ConsumerState<GeneralPage> {

  final ValueNotifier<bool> _excelExportingNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _deleteProcessingNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _excelExportingNotifier.value = false;
    _deleteProcessingNotifier.value = false;
  }

  @override
  Widget build(final BuildContext context) {

    final selectionState = ref.watch(widget.selectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: widget.title,
            style:
                const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            children: [
              TextSpan(
                text: widget.companyName,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          if (selectionState.isSelectionMode) ...[
            ValueListenableBuilder(
              valueListenable: _deleteProcessingNotifier,
              builder: (final BuildContext context, final value, final Widget? child) {
                return IconButton(
                icon: value
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.restore_from_trash_outlined),
                tooltip: "Export all data to Excel",
                onPressed: value
                    ? null
                    : () {
                  _deleteProcessingNotifier.value = true;
                  widget.onDelete().whenComplete(() => _deleteProcessingNotifier.value = false);
                },
              ); },
            ),
            Checkbox(
              value: selectionState.selectAll,
              onChanged: (final bool? x) => ref.read(widget.selectionProvider.notifier).toggleSelectAll(widget.companyName),
            )
          ]
          else
          ValueListenableBuilder(
            valueListenable: _excelExportingNotifier,
            builder: (final BuildContext context, final value, final Widget? child) { return IconButton(
              icon: value
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.table_chart),
              tooltip: "Export all data to Excel",
              onPressed: value
                  ? null
                  : () async {
                _excelExportingNotifier.value = true;
                final String text = widget.companyName != null ? "${widget.companyName!}'s" : (await InvoiceDataService().getCompanyList()).length.toString();
                widget.onExcelExport()
                  ..catchError((final Object e) {
                    return Toast(context,
                        text: e.toString(), color: Colors.redAccent);
                  })
                  ..then((final _) => Toast(context,
                      text:
                      "$text invoices excel output is saved in the "
                          "Download"
                          " file.",
                      color: Colors.green))
                  ..whenComplete(() => _excelExportingNotifier.value = false);
              },
            ); },
          ),
        ],
      ),
      body: widget.body,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
