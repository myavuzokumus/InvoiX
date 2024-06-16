import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:invoix/models/invoice_data.dart';
import 'package:invoix/models/list_length_state.dart';
import 'package:invoix/models/search_state.dart';
import 'package:invoix/models/selection_state.dart';
import 'package:invoix/pages/InvoicesPage/invoice_main.dart';
import 'package:invoix/utils/invoice_data_service.dart';
import 'package:invoix/widgets/loading_animation.dart';
import 'package:invoix/widgets/toast.dart';
import 'package:invoix/widgets/warn_icon.dart';
import 'package:string_similarity/string_similarity.dart';

part 'company_list_mixin.dart';

// Return list of companies
class CompanyList extends ConsumerStatefulWidget {
  const CompanyList({super.key, this.onTap});

  final Function(String)? onTap;

  @override
  ConsumerState<CompanyList> createState() => _CompanyListState();
}

class _CompanyListState extends ConsumerState<CompanyList> with _CompanyListMixin{

  @override
  Widget build(final BuildContext context) {

    final selectionState = ref.watch(companyProvider);
    final query = ref.watch(queryProvider).toLowerCase();

    return ProviderScope(
      child: ValueListenableBuilder<Box>(
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

                    final List<String> companyList = searchQuery(query, company);

                    final List<Widget> filterlist = filterList(company.data!);

                    Future(() {
                      ref.read(companylistLengthProvider.notifier).updateLength(companyList.length);
                    });

                    return SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Wrap(
                                  spacing: filterlist.length > 1 ? 5 : 0,
                                  runSpacing: filterlist.length > 1 ? 5 : 0,
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
                                      return false; // Make it visible after swipe process
                                    },
                                    child: ListTile(
                                      title: Text(
                                        companyListName,
                                      ),
                                      onLongPress: () {
                                        if (ModalRoute.of(context)?.settings.name == null) {
                                          return;
                                        }
                                        if (!selectionState.isSelectionMode) {
                                          selectionState.isSelectionMode = !selectionState.isSelectionMode;
                                          ref.read(companyProvider.notifier).toggleItemSelection(company: companyListName);
                                        }
                                      },
                                      onTap: () {
                                        if (widget.onTap != null) {
                                          widget.onTap!(companyListName);
                                          return;
                                        }
                                        else if (selectionState.isSelectionMode) {
                                          ref.read(companyProvider.notifier).toggleItemSelection(company: companyListName);
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
                                          onChanged: (final bool? x) => ref.read(companyProvider.notifier).toggleItemSelection(company: companyListName),
                                          value: selectionState.selectedItems.containsKey(companyListName)) : const SizedBox.shrink(),
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
          }),
    );
  }

  List<Widget> filterList(final List<String> company) {
    return CompanyType.values.where((final CompanyType types) {
      return company.any((final String element) =>
          element.toUpperCase().contains(types.name.toUpperCase()));
    }).map((final CompanyType types) {
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
    }).toList();
  }

  AlertDialog changeCompanyNameDialog(final String companyListName) {

    CompanyType companySuffix = InvoiceDataService().companyTypeFinder(companyListName);
    companyTextController.clear();

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
              controller: companyTextController,
              decoration: InputDecoration(
                  labelText: "New Company name:",
                  labelStyle: const TextStyle(fontSize: 16),
                  hintText: "Enter new company name",
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment:
                    MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 70,
                        height: 35,
                        child: DropdownButtonFormField<
                            CompanyType>(
                          value: companySuffix,
                          alignment: Alignment.center,
                          menuMaxHeight: 225,
                          hint: const Text("Type"),
                          iconSize: 0,
                          items: CompanyType.values.map(
                                  (final CompanyType value) {
                                return DropdownMenuItem<
                                    CompanyType>(
                                  value: value,
                                  alignment: Alignment.center,
                                  child: Text(value.name),
                                );
                              }).toList(),
                          onChanged:
                              (final CompanyType? value) {
                            companySuffix = value!;
                          },
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                            filled: true,
                          ),
                          validator: (final value) {
                            if (value == null) {
                              return 'Please select company type.';
                            }
                            return null;
                          },
                        ),

                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 12.0, left: 4.0),
                        child: WarnIcon(
                            message:
                            "You must choose a company type."),
                      ),
                    ],
                  )),
              validator: (final value) {
                if (value == null ||
                    value.isEmpty) {
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

              try {
                final InvoiceDataService invoiceDataService = InvoiceDataService();

                companyTextController.text = invoiceDataService.companyTypeExtractor(
                    companyTextController.text);

                companyTextController.text = invoiceDataService.invalidCompanyTypeExtractor(companyTextController.text);

                companyTextController.text += " ${companySuffix.name}";

              } catch (e) {
                Toast(context,
                    text: e.toString(),
                    color: Colors.redAccent);
                return;
              }

              for (final InvoiceData element
              in await InvoiceDataService().getInvoiceList(companyListName)) {
                await InvoiceDataService().saveInvoiceData(element.copyWith(
                    companyName: companyTextController.text));
              }
              if (!mounted) {
                return;
              }
              Navigator.pop(context);
              Toast(context,
                  text: "Company name has been changed successfully.",
                  color: Colors.greenAccent);
            } else {
              Toast(context,
                  text: "Please enter a valid company name.",
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
