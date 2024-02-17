import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:invoix/models/invoice_data.dart';
import 'package:invoix/utils/invoice_data_service.dart';
import 'package:invoix/widgets/toast.dart';

class GeneralPage extends StatefulWidget {
  final String title;
  final String companyName;
  final Widget body;
  final Function onExcelExport;
  final Function onDelete;
  final FloatingActionButton? floatingActionButton;

  const GeneralPage({
    required this.title,
    required this.companyName,
    required this.body,
    required this.onExcelExport,
    required this.onDelete,
    this.floatingActionButton,
    super.key,
  });

  @override
  State<GeneralPage> createState() => _GeneralPageState();
}

class _GeneralPageState extends State<GeneralPage> {

  bool isSelectionMode = false;
  List<bool> _selected = [];
  List<InvoiceData> _selectedInvoices = [];
  bool _selectAll = false;
  int _listLength = 0;
  final List<String> _selectedCompanies = [];

  late bool _excelExporting;

  @override
  void initState() {
    super.initState();
    _excelExporting = false;
  }

  void _selectionToggle({required final int index, final String? company, final InvoiceData? invoiceData}) {
    if (isSelectionMode) {
      setState(() {
        _selected[index] = !_selected[index];
        if (company != null) {
          _selectedCompanies.add(company);
        }
        if (invoiceData != null) {
          _selectedInvoices.add(invoiceData);
        }
      });
    }
  }

  void _onSelectionChange(final bool x) {
    setState(() {
      isSelectionMode = x;
    });
  }

  Future<void> _onSelectAll() async {

    _selectAll = !_selectAll;

    if (_selectAll) {
      if (_selectedCompanies.length == 1) {
        _selectedInvoices =
        await InvoiceDataService.getInvoiceList(_selectedCompanies[0]);
      }
      else {
        for (final String company in _selectedCompanies) {
          _selectedInvoices = [
            ..._selectedInvoices,
            ...await InvoiceDataService.getInvoiceList(company)
          ];
        }
      }
    } else {
      _selectedInvoices = [];
    }
    setState(() {
      _selected = List<bool>.filled(_listLength, _selectAll);
      //check it
    });
  }

  void _setListLength(final int length) {
    setState(() {
      _listLength = length;
      _selected = List<bool>.generate(_listLength, (final _) => false);
    });
  }

  @override
  Widget build(final BuildContext context) {
    return SelectionData(
      isSelectionMode: isSelectionMode,
      selectedList: _selected,
      selectedInvoices: _selectedInvoices,
      selectedCompanies: _selectedCompanies,
      selectionToggle: _selectionToggle,
      onSelectionChange: _onSelectionChange,
      setListLength: _setListLength,
      child: Scaffold(
        appBar: AppBar(
          title: Hero(
            tag: widget.companyName,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: widget.title,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: widget.companyName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ),
          centerTitle: true,
          leading: isSelectionMode
              ? IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                isSelectionMode = false;
              });
              _selected = List<bool>.generate(_listLength, (final _) => false);
            },
          )
              : const SizedBox(),
          actions: <Widget>[
            if (isSelectionMode)
              ...[
              IconButton(
                  onPressed: widget.onDelete(),
                  icon: const Icon(Icons.restore_from_trash_outlined),
              ),
              Checkbox(
                  value: !_selectAll,
                  onChanged: (final bool? x) => _onSelectAll(),
              )]
            else
            IconButton(
              icon: _excelExporting ? const CircularProgressIndicator() : const Icon(Icons.table_chart),
              tooltip: "Export all data to Excel",
              onPressed: _excelExporting ? null : () {
                setState(() {
                  _excelExporting = true;
                });

                widget.onExcelExport()
                  ..catchError((final Object e) => Toast(
                      text: e.toString(), color: Colors.redAccent))
                  ..then((final _) => Toast(
                      text: "${widget.companyName}'s invoices excel output is saved in the ""Download"" file.",
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
      ),
    );
  }
}

class SelectionData extends InheritedWidget {
  final bool isSelectionMode;

  final List<bool> selectedList;
  final List<InvoiceData> selectedInvoices;
  final List<String> selectedCompanies;

  final void Function({required int index, String? company, InvoiceData? invoiceData}) selectionToggle;
  final void Function(bool x) onSelectionChange;
  final void Function(int index) setListLength;

  const SelectionData({super.key,
    required this.isSelectionMode,
    required this.selectedList,
    required this.selectedInvoices,
    required this.selectedCompanies,
    required this.selectionToggle,
    required this.onSelectionChange,
    required this.setListLength,
    required super.child,
  });

  static SelectionData of(final BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SelectionData>()!;
  }

  @override
  bool updateShouldNotify(final SelectionData oldWidget) {
    return oldWidget.isSelectionMode != isSelectionMode ||
        !listEquals(oldWidget.selectedList, selectedList) ||
        !listEquals(oldWidget.selectedInvoices, selectedInvoices) ||
        !listEquals(oldWidget.selectedCompanies, selectedCompanies) ||
        oldWidget.selectionToggle != selectionToggle ||
        oldWidget.onSelectionChange != onSelectionChange ||
        oldWidget.setListLength != setListLength;

  }
}
