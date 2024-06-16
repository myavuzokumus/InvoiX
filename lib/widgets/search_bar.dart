import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoix/models/list_length_state.dart';
import 'package:invoix/models/search_state.dart';

class CompanySearchBar extends ConsumerWidget {
  CompanySearchBar({super.key});

  final TextEditingController _controller = TextEditingController();


  @override
  Widget build(final BuildContext context, final ref) {

    final query = ref.watch(queryProvider);
    final listLengthState = ref.watch(companylistLengthProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        controller: _controller,
        autofocus: false,
        onChanged: (final newQuery) {
          ref.read(queryProvider.notifier).updateQuery(newQuery);
        },
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.never,
          label: const Center(
            child: Text("InvoiX", textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0), // Köşeleri yuvarlatma
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          prefixIcon: const Icon(Icons.search),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                query.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    ref.read(queryProvider.notifier).clearQuery();
                    _controller.clear();
                  },
                ) : const SizedBox(),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Badge(
                      label: Text(
                        listLengthState.length.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      largeSize: 24),
                ),

              ],
            ),
          filled: true

        ),
      ),
    );
  }
}
