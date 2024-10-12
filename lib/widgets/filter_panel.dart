import 'package:flutter/material.dart';

class FilterPanel extends StatefulWidget {
  final List<Widget> children;

  const FilterPanel({super.key, required this.children});

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {

  final ValueNotifier<bool> isExpanded = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: isExpanded,
        builder: (final BuildContext context, final value, final Widget? child) {
          return ExpansionPanelList(
              expandedHeaderPadding: EdgeInsets.zero,
              elevation: 4,
              expansionCallback: (final int index,  final bool isExpanded) {
                setState(() {
                  this.isExpanded.value = !value;
                });
              },
              children: [
                ExpansionPanel(
                  canTapOnHeader: true,
                  backgroundColor: Theme.of(context).colorScheme.onSecondary,
                  isExpanded: value,
                  body: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    shrinkWrap: true,
                    itemCount: widget.children.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 1 : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 7, // Adjust this value as needed
                    ),
                    itemBuilder: (final BuildContext context, final int index) => widget.children[index],
                  ),
                  headerBuilder:
                      (final BuildContext context, final bool isExpanded) {
                    return Center(child: Text(value ? 'Filtreleri Gizle' : 'Filtreleri Göster', style: Theme.of(context).textTheme.bodyLarge));
                  },
                ),
              ]);}
    );
  }
}
