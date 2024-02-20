import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:invoix/models/invoice_data.dart';
import 'package:invoix/pages/InvoicesPage/invoice_main.dart';
import 'package:invoix/pages/SelectionState.dart';
import 'package:invoix/utils/invoice_data_service.dart';
import 'package:invoix/utils/text_to_invoicedata_regex.dart';
import 'package:invoix/widgets/loading_animation.dart';
import 'package:invoix/widgets/toast.dart';
import 'package:invoix/widgets/warn_icon.dart';

// Return list of companies
class CompanyList extends ConsumerStatefulWidget {
  const CompanyList({super.key, this.onTap});

  final Function(String)? onTap;

  @override
  ConsumerState<CompanyList> createState() => _CompanyListState();
}

class _CompanyListState extends ConsumerState<CompanyList> {
  late Set<String> filters;
  late final TextEditingController companyNameTextController;
  late final GlobalKey<FormState> _companyNameformKey;

  @override
  void initState() {
    filters = <String>{};
    companyNameTextController = TextEditingController();
    _companyNameformKey = GlobalKey<FormState>();
    super.initState();
  }

  @override
  void dispose() {
    companyNameTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {

    final selectionState = ref.watch(companySelectionProvider);

    return ValueListenableBuilder<Box>(
        valueListenable: invoiceDataBox.listenable(),
        builder: (final BuildContext context, final Box<dynamic> value,
            final Widget? child) {
          // Check if there is any invoice data
          if (invoiceDataBox.values.isEmpty) {
            return const Center(
              child: Text(
                "No invoice added yet.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28),
              ),
            );
          } else {
            return FutureBuilder<List<String>>(
              future: InvoiceDataService().getCompanyList(),
              builder: (final BuildContext context,
                  final AsyncSnapshot<List<String>> company) {
                if (company.hasData) {
                  // Create a list of companies with copy of company data
                  final List<String> companyList = List.from(company.data!);
                  ref.read(companySelectionProvider).listLength = companyList.length;

                  if (filters.length == 1) {
                    companyList.removeWhere(
                            (final String element) => !filters.every((final e) {
                          return element
                              .toUpperCase()
                              .contains(e.toUpperCase());
                        }));
                  } else if (filters.length > 1) {
                    companyList.removeWhere(
                            (final String element) => !filters.any((final e) {
                          return element
                              .toUpperCase()
                              .contains(e.toUpperCase());
                        }));
                  }

                  final List<Widget> filterlist = filterList(company.data!);

                  return SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10, top: 10),
                          child: FilledButton(
                            onPressed: () {},
                            child: Text(companyList.length.toString()),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Wrap(
                                spacing: 10.0,
                                children: filterlist.length > 1
                                    ? filterlist
                                    : const [SizedBox()]),
                          ),
                        ),
                        Flexible(
                            child: ListView.separated(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, top: 20),
                              itemCount: companyList.length,
                              separatorBuilder:
                                  (final BuildContext context, final int index) =>
                              const Divider(),
                              itemBuilder:
                                  (final BuildContext context, final int index) {
                                final companyListName =
                                companyList.elementAt(index);

                                return Dismissible(
                                  key: ValueKey<int>(index),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    color: Theme.of(context).colorScheme.primary,
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.only(left: 20.0),
                                          child: Icon(Icons.published_with_changes, color: Colors.white),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(right: 20.0),
                                          child: Icon(Icons.published_with_changes, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                  confirmDismiss: (final direction) async {
                                    unawaited(showDialog(
                                        context: context,
                                        builder: (final BuildContext context) {
                                          return changeCompanyNameDialog(
                                              companyListName);
                                        }));
                                    return false; // Kaydırma işlemi sonrasında widget'ın kaybolmamasını sağlar
                                  },
                                  child: ListTile(
                                    title: Text(
                                      companyListName,
                                    ),
                                    onLongPress: () {
                                      if (ModalRoute.of(context)?.settings.name == null) return;
                                      if (!selectionState.isSelectionMode) {
                                        ref.read(companySelectionProvider.notifier).toggleSelectionMode();
                                        ref.read(companySelectionProvider.notifier).toggleItemSelection(index: index, company: companyListName);
                                      }
                                    },
                                    onTap: () {
                                      if (widget.onTap != null) {
                                        widget.onTap!(companyListName);
                                        return;
                                      }
                                      else if (selectionState.isSelectionMode) {
                                        ref.read(companySelectionProvider.notifier).toggleItemSelection(index: index, company: companyListName);
                                      }
                                      else {
                                        Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                                pageBuilder: (final BuildContext context, final Animation<double> animation, final Animation<double> secondaryAnimation) => InvoicePage(
                                                    companyName: companyListName),
                                              transitionDuration: const Duration(milliseconds: 250),
                                              transitionsBuilder: (final context, animation, final animationTime, final child) {
                                                animation = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
                                                return FadeTransition(
                                                  opacity: animation,
                                                  child: child,
                                                );
                                              },

                                            ));
                                      }
                                    },
                                    trailing: selectionState.isSelectionMode
                                        ? Checkbox(
                                        onChanged: (final bool? x) => ref.read(companySelectionProvider.notifier).toggleItemSelection(index: index, company: companyListName),
                                        value: selectionState.selectedItems[index])
                                        : const SizedBox.shrink(),
                                  ),
                                );
                              },
                            )),
                      ],
                    ),
                  );
                } else {
                  return const LoadingAnimation();
                }
              },
            );
          }
        });
  }

  List<Widget> filterList(final List<String> company) {
    return CompanyType.values.map((final CompanyType types) {
      if (company.any((final String element) =>
          element.toUpperCase().contains(types.name.toUpperCase()))) {
        return FilterChip(
          label: Text(types.name),
          selected: filters.contains(types.name),
          onSelected: (final bool selected) {
            setState(() {
              if (selected) {
                filters.add(types.name);
              } else {
                filters.remove(types.name);
              }
            });
          },
        );
      } else {
        return const SizedBox();
      }
    }).toList();
  }

  AlertDialog changeCompanyNameDialog(final String companyListName) {
    return AlertDialog(
      title: Text(companyListName),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("What would you like to change new company name?"),
          const SizedBox(height: 12),
          Form(
            key: _companyNameformKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: TextFormField(
              maxLength: 100,
              controller: companyNameTextController,
              decoration: const InputDecoration(
                  labelText: "New company name:",
                  labelStyle: TextStyle(fontSize: 16),
                  hintText: "Enter new company name",
                  suffixIcon: WarnIcon(
                      message:
                      "You must enter a valid company name.\nNeed include 'LTD., ŞTİ., A.Ş., LLC, PLC, INC, GMBH'")),
              validator: (final value) {
                if (value == null ||
                    value.isEmpty ||
                    !companyRegex.hasMatch(value)) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            if (_companyNameformKey.currentState!.validate()) {
              for (final InvoiceData element
              in await InvoiceDataService().getInvoiceList(companyListName)) {
                await InvoiceDataService().saveInvoiceData(element.copyWith(
                    companyName: companyNameTextController.text));
              }
              if (!mounted) return;
              Navigator.pop(context);
              Toast(context,
                  text: "Company name has been changed successfully.",
                  color: Colors.greenAccent);
            } else {
              Toast(context,
                  text: "Please enter a valid company name.\nNeed include 'LTD., ŞTİ., A.Ş., LLC, PLC, INC, GMBH'",
                  color: Colors.redAccent
              );
            }
          },
          child: const Text("Change"),
        ),
      ],
    );
  }
}
