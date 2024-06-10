import 'package:flutter_riverpod/flutter_riverpod.dart';

class QueryState extends StateNotifier<String> {
  QueryState() : super('');

  void updateQuery(final String newQuery) {
    state = newQuery;
  }

  void clearQuery() {
    state = '';
  }
}

final queryProvider = StateNotifierProvider<QueryState, String>((final ref) => QueryState());