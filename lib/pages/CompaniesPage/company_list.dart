import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:invoix/l10n/localization_extension.dart';
import 'package:invoix/models/invoice_data.dart';
import 'package:invoix/pages/CompaniesPage/invox_ai_card.dart';
import 'package:invoix/pages/InvoicesPage/invoice_main.dart';
import 'package:invoix/services/invoice_data_service.dart';
import 'package:invoix/states/invoice_data_state.dart';
import 'package:invoix/states/list_length_state.dart';
import 'package:invoix/states/search_state.dart';
import 'package:invoix/states/selection_state.dart';
import 'package:invoix/widgets/status/loading_animation.dart';
import 'package:invoix/widgets/toast.dart';
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

    final selectionState = ref.watch(companySelectionProvider);
    final query = ref.watch(queryProvider).toLowerCase();

    return ValueListenableBuilder<Box>(
        valueListenable: invoiceDataService.invoiceDataBox.listenable(),
        builder: (final BuildContext context, final Box<dynamic> value,
            final Widget? child) {
          // Check if there is any invoice data
          if (invoiceDataService.invoiceDataBox.values.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: InvoixAICard(
                  children: <Widget>[
                    Text(context.l10n.aiinsights_juststart),
                  ],
                ),
              ),
            );
          } else {
            return FutureBuilder<List<String>>(
              future: invoiceDataService.getCompanyList(),
              builder: (final BuildContext context,
                  final AsyncSnapshot<List<String>> company) {
                if (company.hasData) {
                  // Create a list of companies with copy of company data

                  final List<String> companyList = searchQuery(query, company);

                  final List<Widget> filterlist = filterList(company.data!);

                  Future(() {
                    ref.read(companylistLengthProvider.notifier).updateLength(companyList.length);
                  });

                  return Column(
                    children: [
                      Flexible(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Wrap(
                              spacing: filterlist.length > 1 ? 5 : 0,
                              runSpacing: filterlist.length > 1 ? 5 : 0,
                              children: filterlist.length > 1
                                  ? filterlist
                                  : const [SizedBox.shrink()]),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: ListView.separated(
                          clipBehavior: Clip.none,
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 5),
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
                              child: Container(
                                decoration: const BoxDecoration(
                                  border: Border(
                                    right: BorderSide(color: Colors.white, width: 2.5),
                                  ),
                                ),
                                child: ListTile(
                                  leading: const Icon(Icons.business, color: Colors.redAccent),
                                  title: Text(
                                    companyListName,
                                  ),
                                  onLongPress: () {
                                    if (ModalRoute.of(context)?.settings.name == null) {
                                      return;
                                    }
                                    if (!selectionState.isSelectionMode) {
                                      selectionState.isSelectionMode = !selectionState.isSelectionMode;
                                      ref.read(companySelectionProvider.notifier).toggleItemSelection(company: companyListName);
                                    }
                                  },
                                  onTap: () {
                                    if (widget.onTap != null) {
                                      widget.onTap!(companyListName);
                                      return;
                                    }
                                    else if (selectionState.isSelectionMode) {
                                      ref.read(companySelectionProvider.notifier).toggleItemSelection(company: companyListName);
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
                                      onChanged: (final bool? x) => ref.read(companySelectionProvider.notifier).toggleItemSelection(company: companyListName),
                                      value: selectionState.selectedItems.containsKey(companyListName)) : const SizedBox.shrink(),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
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

    CompanyType companySuffix = invoiceDataService.companyTypeFinder(companyListName);
    companyTextController.clear();

    return AlertDialog(
      title: Text(companyListName),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.changeCompanyName_title),
          const SizedBox(height: 12),
          Form(
            key: _companyNameformKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: TextFormField(
              maxLength: 100,
              controller: companyTextController,
              decoration: InputDecoration(
                  labelText: context.l10n.changeCompanyName_label,
                  labelStyle: const TextStyle(fontSize: 16),
                  hintText: context.l10n.changeCompanyName_enterName,
                suffixIconConstraints: const BoxConstraints(
                    maxWidth: 72),
                  suffixIcon: DropdownButtonFormField<
                      CompanyType>(
                    value: companySuffix,
                    isExpanded: true,
                    alignment: Alignment.center,
                    menuMaxHeight: 225,
                    hint: Text(context.l10n.invoice_companyType),
                    iconSize: 0,
                    padding: const EdgeInsets.only(top: 8.0, right: 8.0, bottom: 8.0),
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
                    decoration:
                    const InputDecoration(
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 4),
                      filled: true,
                    ),
                    validator: (final value) {
                      if (value == null) {
                        return context.l10n.error_pleaseSelect(context.l10n.invoice_companyType);
                      }
                      return null;
                    },
                  )),
              validator: (final value) {
                if (value == null ||
                    value.isEmpty) {
                  return context.l10n.error_pleaseEnterText;
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
          child: Text(context.l10n.button_cancel),
        ),
        TextButton(
          onPressed: () async {
            if (_companyNameformKey.currentState!.validate()) {

              try {

                companyTextController.text = invoiceDataService.companyTypeExtractor(
                    companyTextController.text);

                companyTextController.text = invoiceDataService.invalidCompanyTypeExtractor(companyTextController.text);

                companyTextController.text += " ${companySuffix.name}";

              } catch (e) {
                showToast(text: e.toString(),
                    color: Colors.redAccent);
                return;
              }

              for (final InvoiceData element
              in await invoiceDataService.getInvoiceList(companyListName)) {
                await invoiceDataService.saveInvoiceData(element.copyWith(
                    companyName: companyTextController.text));
              }
              if (!mounted) {
                return;
              }
              Navigator.pop(context);
              showToast(text: context.l10n.success_companyNameChanged,
                  color: Colors.greenAccent);
            } else {
              showToast(text: context.l10n.error_validInput(context.l10n.invoice_companyName),
                  color: Colors.redAccent
              );
            }
          },
          child: Text(context.l10n.button_save),
        ),
      ],
    );
  }
}
