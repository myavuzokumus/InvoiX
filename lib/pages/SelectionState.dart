import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoix/models/invoice_data.dart';
import 'package:invoix/utils/invoice_data_service.dart';

class SelectionState {
  bool isSelectionMode;
  bool selectAll;
  Map<String, List<InvoiceData>> selectedItems;

  SelectionState(this.isSelectionMode, this.selectAll, this.selectedItems);
}

class SelectionNotifier extends StateNotifier<SelectionState> {
  SelectionNotifier() : super(SelectionState(false, false, {}));

  Future<void> toggleItemSelection({
    required final String company,
    final InvoiceData? invoiceData,
  }) async {
    if (state.isSelectionMode) {
      if (invoiceData == null) {
        if (state.selectedItems.containsKey(company)) {
          state.selectedItems.remove(company);
        } else {
          state.selectedItems[company] = [];
        }
      } else {
        if (state.selectedItems[company] == null) {
          state.selectedItems[company] = [];
        }
        if (state.selectedItems[company]!.contains(invoiceData)) {
          state.selectedItems[company]!.remove(invoiceData);
        } else {
          state.selectedItems[company]!.add(invoiceData);
        }
      }
    }

    final realLength = invoiceData == null ? await InvoiceDataService().getCompanyList() : await InvoiceDataService().getInvoiceList(company);
    final currentLength = invoiceData == null ? state.selectedItems.length : state.selectedItems[company]!.length;
    if (currentLength == realLength.length) {
      state.selectAll = true;
    } else {
      state.selectAll = false;
    }

    // Update the state with the new map
    state = SelectionState(
        state.isSelectionMode, state.selectAll, state.selectedItems);
  }

  Future<void> selectAll(final String? company) async {
    state.selectAll = !state.selectAll;

    if (state.selectAll) {
      if (company != null) {
        state.selectedItems[company] =
            await InvoiceDataService().getInvoiceList(company);
      } else {
        state.selectedItems = Map.fromIterable(await InvoiceDataService().getCompanyList(), value: (_) => []);
        //state.selectedItems.addAll();
      }
    } else {
      state.selectedItems.clear();
    }

    state = SelectionState(
        state.isSelectionMode, state.selectAll, state.selectedItems);
  }

  //You must set the list length before calling this function
  void toggleSelectionMode() {
    state.isSelectionMode = !state.isSelectionMode;

    if (!state.isSelectionMode) {
      state.selectedItems.clear();
    }

    state = SelectionState(
      state.isSelectionMode,
      state.selectAll,
      state.selectedItems,
    );
  }
}

final companyProvider =
    StateNotifierProvider.autoDispose<SelectionNotifier, SelectionState>(
        (final ref) => SelectionNotifier());
final invoiceProvider =
    StateNotifierProvider.autoDispose<SelectionNotifier, SelectionState>(
        (final ref) => SelectionNotifier());
