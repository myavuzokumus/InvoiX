import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoix/misc/deletion_dialog.dart';
import 'package:invoix/models/list_length_state.dart';
import 'package:invoix/models/selection_state.dart';
import 'package:invoix/utils/export_to_excel.dart';
import 'package:invoix/utils/invoice_data_service.dart';
import 'package:invoix/widgets/loading_animation.dart';
import 'package:invoix/widgets/search_bar.dart';
import 'package:invoix/widgets/sub_status.dart';
import 'package:invoix/widgets/toast.dart';

part 'list_page_scaffold_mixin.dart';

class ListPageScaffold extends ConsumerStatefulWidget {
  final String title;
  final String? companyName;
  final ListType type;

  final Widget body;
  final Widget? floatingActionButton;

  final AutoDisposeStateNotifierProvider<SelectionNotifier, SelectionState>
      selectionProvider;

  const ListPageScaffold(
      {super.key,
      required this.title,
      this.companyName,
      required this.body,
      this.floatingActionButton,
      required this.selectionProvider,
      required this.type});

  @override
  ConsumerState<ListPageScaffold> createState() => _GeneralPageState();
}

class _GeneralPageState extends ConsumerState<ListPageScaffold>
    with _ListPageScaffoldMixin {
  @override
  Widget build(final BuildContext context) {
    final selectionState = ref.watch(widget.selectionProvider);
    final listLengthState = ref.watch(invoicelistLengthProvider);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
            centerTitle: widget.type != ListType.company,
            title: selectionState.isSelectionMode
                ? widget.type != ListType.company
                    ? Text(widget.companyName!,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.normal))
                    : const Text("InvoiX",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold))
                : widget.type != ListType.company
                    ? Text(widget.companyName!,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.normal))
                    : CompanySearchBar(),
            actions: <Widget>[
              if (selectionState.isSelectionMode) ...[
                ValueListenableBuilder(
                    valueListenable: _excelExportingNotifier,
                    builder: (final BuildContext context, final value,
                        final Widget? child) {
                      return IconButton(
                          icon: value
                              ? const CircularProgressIndicator()
                              : const Icon(Icons.table_chart),
                          tooltip: "Export all data to Excel",
                          onPressed: value ? null : () => onExcelOutput());
                    }),
                ValueListenableBuilder(
                  valueListenable: _deleteProcessingNotifier,
                  builder: (final BuildContext context, final value,
                      final Widget? child) {
                    return IconButton(
                      icon: value
                          ? const CircularProgressIndicator()
                          : const Icon(Icons.restore_from_trash_outlined),
                      tooltip: "Delete Items",
                      onPressed: value ? null : () => onDelete(),
                    );
                  },
                ),
                Checkbox(
                  value: selectionState.selectAll,
                  onChanged: (final bool? x) => ref
                      .read(widget.selectionProvider.notifier)
                      .selectAll(widget.companyName),
                ),
              ]
              //else add Icons for other actions
              else ...[
                if (widget.type != ListType.company)
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Badge(
                        label: Text(
                          listLengthState.length.toString(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                        largeSize: 24),
                  ),
              ],
            ]),
        body: Column(
          children: [
            SubStatus(
              errorState: ref.watch(errorProvider),
              subsControl: true,
            ),
            Expanded(child: widget.body),
          ],
        ),
        floatingActionButton: widget.floatingActionButton,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
