import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoix/pages/SelectionState.dart';
import 'package:invoix/widgets/toast.dart';

class GeneralPage extends ConsumerStatefulWidget {
  final String title;
  final String companyName;

  final Widget body;
  final Widget? floatingActionButton;

  final Function onExcelExport;
  final Function onDelete;

  final AutoDisposeStateNotifierProvider<SelectionNotifier, SelectionState> selectionProvider;

  const GeneralPage({super.key, required this.title, required this.companyName, required this.body, this.floatingActionButton, required this.onExcelExport, required this.onDelete, required this.selectionProvider});

  @override
  ConsumerState<GeneralPage> createState() => _GeneralPageState();
}

class _GeneralPageState extends ConsumerState<GeneralPage> {

  late bool _excelExporting;

  @override
  void initState() {
    super.initState();
    _excelExporting = false;
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
            IconButton(
              onPressed: () {widget.onDelete();},
              icon: const Icon(Icons.restore_from_trash_outlined),
            ),
            Checkbox(
              value: selectionState.selectAll,
              onChanged: (final bool? x) => ref.read(widget.selectionProvider.notifier).toggleSelectAll(),
            )
          ]
          else
          IconButton(
              icon: _excelExporting
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.table_chart),
              tooltip: "Export all data to Excel",
              onPressed: _excelExporting
                  ? null
                  : () {
                      setState(() {
                        _excelExporting = true;
                      });
                      widget.onExcelExport()
                        ..catchError((final Object e) {
                          return Toast(context,
                              text: e.toString(), color: Colors.redAccent);
                        })
                        ..then((final _) => Toast(context,
                            text:
                                "${widget.companyName}'s invoices excel output is saved in the "
                                "Download"
                                " file.",
                            color: Colors.green))
                        ..whenComplete(() => setState(() {
                              _excelExporting = false;
                            }));
                    },
            ),
        ],
      ),
      body: widget.body,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
