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

  void toggleItemSelection({
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

    if (state.selectedItems.every((final element) => element == true)) {
      state.selectAll = true;
    }
    else {
      state.selectAll = false;
    }

    // Update the state with the new list
    state = SelectionState(
      state.isSelectionMode,
      state.selectAll,
      state.listLength,
      state.selectedItems,
      state.selectedInvoices,
      state.selectedCompanies,
    );

  }


  //You must set the list length before calling this function
  void toggleSelectionMode() {

    state.isSelectionMode = !state.isSelectionMode;

    if (!state.isSelectionMode) {
      state.selectedInvoices.clear();
      state.selectedCompanies.clear();
      state.selectedItems.clear();
    }
    else {
      state.selectedItems = List<bool>.filled(state.listLength, false, growable: true);
    }

    state = SelectionState(
      state.isSelectionMode,
      state.selectAll,
      state.listLength,
      state.selectedItems,
      state.selectedInvoices,
      state.selectedCompanies,
    );

  }

  Future<void> toggleSelectAll(final String? company) async {

    state.selectAll = !state.selectAll;

    if (state.selectAll) {
      if (company != null) {
        state.selectedInvoices = await InvoiceDataService().getInvoiceList(company);
      } else {
        state.selectedInvoices.clear();
        for (final String company in state.selectedCompanies) {
          state.selectedInvoices = [
            ...state.selectedInvoices,
            ...await InvoiceDataService().getInvoiceList(company)
          ];
        }
      }
    } else {
      state.selectedInvoices = [];
    }

    state.selectedItems = List<bool>.filled(state.listLength, state.selectAll, growable: true);

    state = SelectionState(
      state.isSelectionMode,
      state.selectAll,
      state.listLength,
      state.selectedItems,
      state.selectedInvoices,
      state.selectedCompanies,
    );
  }

}

final companySelectionProvider = StateNotifierProvider.autoDispose<SelectionNotifier, SelectionState>((final ref) => SelectionNotifier());

final invoiceSelectionProvider = StateNotifierProvider.autoDispose<SelectionNotifier, SelectionState>((final ref) => SelectionNotifier());