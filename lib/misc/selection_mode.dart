import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoix/misc/deletion_dialog.dart';
import 'package:invoix/models/selection_state.dart';
import 'package:invoix/utils/export_to_excel.dart';
import 'package:invoix/utils/invoice_data_service.dart';
import 'package:invoix/widgets/toast.dart';

part 'selection_mode_mixin.dart';

class SelectionMode extends ConsumerStatefulWidget {
  final String title;
  final String? companyName;
  final ListType type;

  final Widget body;
  final Widget? floatingActionButton;

  final AutoDisposeStateNotifierProvider<SelectionNotifier, SelectionState> selectionProvider;

  const SelectionMode({super.key, required this.title, this.companyName, required this.body, this.floatingActionButton, required this.selectionProvider, required this.type});

  @override
  ConsumerState<SelectionMode> createState() => _GeneralPageState();
}

class _GeneralPageState extends ConsumerState<SelectionMode> with _SelectionModeMixin{

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
                valueListenable: _excelExportingNotifier,
                builder: (final BuildContext context, final value, final Widget? child) { return IconButton(
                    icon: value
                        ? const CircularProgressIndicator()
                        : const Icon(Icons.table_chart),
                    tooltip: "Export all data to Excel",
                    onPressed: value
                        ? null
                        : () => onExcelOutput());}),
            ValueListenableBuilder(
              valueListenable: _deleteProcessingNotifier,
              builder: (final BuildContext context, final value, final Widget? child) {
                return IconButton(
                icon: value
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.restore_from_trash_outlined),
                tooltip: "Delete Items",
                onPressed: value
                    ? null
                    : () =>
                  onDelete()
                ,
              ); },
            ),
            Checkbox(
              value: selectionState.selectAll,
              onChanged: (final bool? x) => ref.read(widget.selectionProvider.notifier).selectAll(widget.companyName),
            ),
          ]
          //else add Icons for other actions
        ],
      ),
      body: widget.body,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
