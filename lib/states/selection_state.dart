import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoix/models/invoice_data.dart';
import 'package:invoix/services/invoice_data_service.dart';
import 'package:invoix/states/invoice_data_state.dart';

class SelectionState {
  bool isSelectionMode;
  bool selectAll;
  Map<String, List<InvoiceData>> selectedItems;

  SelectionState(this.isSelectionMode, this.selectAll, this.selectedItems);
}

class SelectionNotifier extends StateNotifier<SelectionState> {
  final Ref _ref;

  SelectionNotifier(this._ref) : super(SelectionState(false, false, {}));

  InvoiceDataService get _invoiceDataService => _ref.read(invoiceDataServiceProvider);

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

    final realLength = invoiceData == null
        ? await _invoiceDataService.getCompanyList()
        : await _invoiceDataService.getInvoiceList(company);
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
        await _invoiceDataService.getInvoiceList(company);
      } else {
        state.selectedItems = Map.fromIterable(
            await _invoiceDataService.getCompanyList(),
            value: (final _) => []
        );
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
        (ref) => SelectionNotifier(ref));
final invoiceProvider =
StateNotifierProvider.autoDispose<SelectionNotifier, SelectionState>(
        (ref) => SelectionNotifier(ref));