// list_length_state.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListLengthState {
  final int length;

  ListLengthState(this.length);
}

class ListLengthNotifier extends StateNotifier<ListLengthState> {
  ListLengthNotifier() : super(ListLengthState(0));

  void updateLength(final int length) {
    state = ListLengthState(length);
  }
}

final invoicelistLengthProvider = StateNotifierProvider.autoDispose<ListLengthNotifier, ListLengthState>((final ref) => ListLengthNotifier());
final companylistLengthProvider = StateNotifierProvider.autoDispose<ListLengthNotifier, ListLengthState>((final ref) => ListLengthNotifier());
