import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoix/models/invoice_data.dart';
import 'package:invoix/utils/invoice_data_service.dart';

class SelectionState {
  bool isSelectionMode;
  bool selectAll;
  int listLength;
  List<bool> selectedItems;
  List<InvoiceData> selectedInvoices;
  List<String> selectedCompanies;

  SelectionState(
    this.isSelectionMode,
    this.selectAll,
    this.listLength,
    this.selectedItems,
    this.selectedInvoices,
    this.selectedCompanies,
  );
}

class SelectionNotifier extends StateNotifier<SelectionState> {
  SelectionNotifier() : super(SelectionState(false, false, 0, [], [], []));

  void selectionItemToggle({
    required final int index,
    final String? company,
    final InvoiceData? invoiceData,
  }) {
    if (state.isSelectionMode) {
      state.selectedItems[index] = !state.selectedItems[index];
      if (state.selectedItems[index]) {
        if (company != null) {
          state.selectedCompanies.add(company);
        }
        if (invoiceData != null) {
          state.selectedInvoices.add(invoiceData);
        }
      } else {
        if (company != null) {
          state.selectedCompanies.remove(company);
        }
        if (invoiceData != null) {
          state.selectedInvoices.remove(invoiceData);
        }
      }
    }
  }

  void toggleSelectionMode() {
    state.isSelectionMode = !state.isSelectionMode;
    if (!state.isSelectionMode) {
      state.selectedInvoices.clear();
      state.selectedCompanies.clear();
      state.selectedItems.clear();
    }
  }

  Future<void> toggleSelectAll() async {
    state.selectAll = !state.selectAll;

    if (state.selectAll) {
      if (state.selectedCompanies.length == 1) {
        state.selectedInvoices =
        await InvoiceDataService.getInvoiceList(state.selectedCompanies[0]);
      } else {
        for (final String company in state.selectedCompanies) {
          state.selectedInvoices = [
            ...state.selectedInvoices,
            ...await InvoiceDataService.getInvoiceList(company)
          ];
        }
      }
    } else {
      state.selectedInvoices = [];
    }
    state.selectedItems = List<bool>.filled(state.listLength, state.selectAll);
  }

  void setListLength(final int length) {
    state.listLength = length;
    state.selectedItems = List<bool>.generate(state.listLength, (final _) => false);
  }
}

final companySelectionProvider = StateNotifierProvider<SelectionNotifier, SelectionState>((ref) => SelectionNotifier());

final invoiceSelectionProvider = StateNotifierProvider<SelectionNotifier, SelectionState>((ref) => SelectionNotifier());