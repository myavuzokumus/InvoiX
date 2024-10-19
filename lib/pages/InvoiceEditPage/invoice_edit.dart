import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoix/l10n/localization_extension.dart';
import 'package:invoix/models/invoice_data.dart';
import 'package:invoix/pages/CompaniesPage/company_list.dart';
import 'package:invoix/services/firebase_service.dart';
import 'package:invoix/services/invoice_data_service.dart';
import 'package:invoix/states/firebase_state.dart';
import 'package:invoix/states/invoice_data_state.dart';
import 'package:invoix/states/loading_state.dart';
import 'package:invoix/utils/blur_detector.dart';
import 'package:invoix/utils/date_parser.dart';
import 'package:invoix/utils/image_filter.dart';
import 'package:invoix/utils/legacy_mode/invoice_parser.dart';
import 'package:invoix/utils/legacy_mode/text_extraction.dart';
import 'package:invoix/utils/legacy_mode/text_to_invoicedata_regex.dart';
import 'package:invoix/utils/read_mode.dart';
import 'package:invoix/utils/status/current_status_checker.dart';
import 'package:invoix/widgets/status/loading_animation.dart';
import 'package:invoix/widgets/toast.dart';
import 'package:invoix/widgets/warn_icon.dart';
import 'package:string_similarity/string_similarity.dart';

part 'invoice_edit_mixin.dart';

class InvoiceEditPage extends ConsumerStatefulWidget {
  const InvoiceEditPage(
      {super.key, required this.imageFile, this.readMode, this.invoiceData});

  final ReadMode? readMode;
  final XFile imageFile;
  final InvoiceData? invoiceData;

  @override
  ConsumerState<InvoiceEditPage> createState() => _InvoiceEditPageState();
}

class _InvoiceEditPageState extends ConsumerState<InvoiceEditPage>
    with _InvoiceEditPageMixin {
  @override
  Widget build(final BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        endDrawerEnableOpenDragGesture: false,
        endDrawer: NavigationDrawer(
          children: [
            CompanyList(
              onTap: (String item) {
                _scaffoldKey.currentState!.closeEndDrawer();
                item = item.replaceAll(companyRegex, "");
                setState(() {
                  companyTextController.text = item;
                  companySuffix = invoiceDataService.companyTypeFinder(item);
                });
              },
            )
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: CustomScrollView(slivers: [
            SliverAppBar(
              actions: [
                Tooltip(
                  triggerMode: TooltipTriggerMode.tap,
                  showDuration: const Duration(seconds: 3),
                  message: context.l10n.page_editinvoice_zoom,
                  child: const Icon(Icons.zoom_out_map, size: 28),
                )
              ],
              expandedHeight: 350,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  margin: const EdgeInsets.all(24),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Theme.of(context).indicatorColor,
                    borderRadius: const BorderRadius.all(Radius.circular(25)),
                  ),
                  child: InteractiveViewer(
                    child: Hero(
                      tag: imageFile.path,
                      child: AspectRatio(
                          aspectRatio: 1,
                          child: Image.file(
                            File(imageFile.path),
                            fit: BoxFit.fitHeight,
                            width: double.maxFinite,
                          )),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: FutureBuilder(
                  future: _future,
                  builder: (final BuildContext context,
                      final AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError) {
                        Future(() {
                          showToast(text: snapshot.error.toString(),
                              color: Colors.red);
                        });
                      }

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Divider(height: 1),
                          Form(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            key: _formKey,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, right: 20, top: 10),
                              child: Wrap(
                                runSpacing: 16.0,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          maxLength: 100,
                                          controller: companyTextController,
                                          decoration: InputDecoration(
                                              labelText: context.l10n.invoice_companyName,
                                              suffixIconConstraints:
                                                  const BoxConstraints(
                                                      maxWidth: 82, maxHeight: 30),
                                              suffixIcon: Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      right: 8),
                                                  child: DropdownButtonFormField<
                                                      CompanyType>(
                                                    value: companySuffix,
                                                    alignment: Alignment.center,
                                                    menuMaxHeight: 225,
                                                    hint: Text(context.l10n.invoice_companyType),
                                                    iconSize: 0,
                                                    items: CompanyType.values.map(
                                                        (final CompanyType value) {
                                                      return DropdownMenuItem<
                                                          CompanyType>(
                                                        value: value,
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
                                                  ),
                                                ),
                                              )),
                                          validator: (final value) {
                                            if (value == null || value.isEmpty) {
                                              return context.l10n.error_pleaseEnterText;
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      IconButton.filledTonal(
                                          onPressed: () {
                                            _scaffoldKey.currentState!.openEndDrawer();
                                          },
                                          icon: const Icon(Icons.search)),
                                    ],
                                  ),
                                  TextFormField(
                                    maxLength: 50,
                                    controller: companyIdTextController,
                                    decoration: InputDecoration(
                                        labelText: context.l10n.invoice_companyId),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          maxLength: 50,
                                          controller: invoiceNoTextController,
                                          decoration: InputDecoration(
                                              labelText: context.l10n.invoice_invoiceNo,
                                              suffixIcon: WarnIcon(
                                                  message: context.l10n.error_validInput(context.l10n.invoice_invoiceNo))),
                                          validator: (final value) {
                                            if (value == null || value.isEmpty) {
                                              return context.l10n.error_pleaseEnterText;
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Flexible(
                                        child: DropdownButtonFormField<
                                            PriceUnit>(
                                          value: priceUnit,
                                          menuMaxHeight: 225,
                                          hint: Text(context.l10n.invoice_unit),
                                          iconSize: 0,
                                          items: PriceUnit.values.map(
                                                  (final PriceUnit value) {
                                                return DropdownMenuItem<
                                                    PriceUnit>(
                                                  value: value,
                                                  child: Text(value.name),
                                                );
                                              }).toList(),
                                          onChanged:
                                              (final PriceUnit? value) {
                                                priceUnit =
                                                value ?? PriceUnit.Others;
                                          },
                                          decoration: InputDecoration(
                                            labelText: context.l10n.invoice_unit,
                                            isDense: true,
                                            filled: true,
                                          ),
                                          validator: (final value) {
                                            if (value == null) {
                                              return context.l10n.error_pleaseSelect(context.l10n.invoice_unit);
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        child: TextFormField(
                                          maxLength: 50,
                                          controller: dateTextController,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                              labelText: context.l10n.invoice_date,
                                              suffixIcon: WarnIcon(
                                                  message:
                                                      context.l10n.error_validInput(context.l10n.invoice_date))),
                                          onTap: () async {
                                            final DateTime today =
                                                DateTime.now();
                                            final DateTime? pickedDate =
                                                await showDatePicker(
                                                    context: context,
                                                    initialDate: today,
                                                    //get today's date
                                                    firstDate: DateTime(1900),
                                                    //DateTime.now() - not to allow to choose before today.
                                                    lastDate: DateTime(
                                                        today.year,
                                                        today.month,
                                                        today.day));

                                            if (pickedDate != null) {
                                              final String formattedDate =
                                                  dateFormat.format(
                                                      pickedDate); // format date in required form here we use yyyy-MM-dd that means time is removed

                                              setState(() {
                                                dateTextController.text =
                                                    formattedDate; //set formatted date to TextField value.
                                              });
                                            }
                                          },
                                          validator: (final value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "";
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Flexible(
                                        child: DropdownButtonFormField<
                                            InvoiceCategory>(
                                          value: invoiceCategory,
                                          menuMaxHeight: 225,
                                          hint: Text(context.l10n.invoice_category, overflow: TextOverflow.ellipsis),
                                          iconSize: 0,
                                          items: InvoiceCategory.values.map(
                                              (final InvoiceCategory value) {
                                            return DropdownMenuItem<
                                                InvoiceCategory>(
                                              value: value,
                                              child: Text(value.translatedName, overflow: TextOverflow.ellipsis),
                                            );
                                          }).toList(),
                                          onChanged:
                                              (final InvoiceCategory? value) {
                                            invoiceCategory =
                                                value ?? InvoiceCategory.Others;
                                          },

                                          decoration: InputDecoration(
                                            labelText: context.l10n.invoice_category,
                                            isDense: true,
                                            filled: true,
                                          ),
                                          validator: (final value) {
                                            if (value == null) {
                                              return context.l10n.error_pleaseSelect(context.l10n.invoice_category);
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: TextFormField(
                                          maxLength: 50,
                                          controller: totalAmountTextController,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'[0-9.]')),
                                          ],
                                          // Only numbers can be entered
                                          validator: (final value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "";
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                              labelText: context.l10n.invoice_totalAmount,
                                              suffixIcon: WarnIcon(
                                                  message:
                                                      context.l10n.error_validInput(context.l10n.invoice_totalAmount))),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Flexible(
                                        child: TextFormField(
                                          maxLength: 50,
                                          controller: taxAmountTextController,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'[0-9.]')),
                                          ],
                                          // Only numbers can be entered
                                          validator: (final value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "";
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                              labelText: context.l10n.invoice_taxAmount,
                                              suffixIcon: WarnIcon(
                                                  message:
                                                      context.l10n.error_validInput(context.l10n.invoice_taxAmount))),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          ValueListenableBuilder(
                            valueListenable: _saveButtonState,
                            builder: (final BuildContext context,
                                    final bool value, final Widget? child) =>
                                value == true
                                    ? ElevatedButton(
                                        onPressed: saveInvoice,
                                        child:
                                            const Icon(Icons.save_as_rounded))
                                    : const CircularProgressIndicator(),
                          ),
                        ],
                      );
                    }

                    return LoadingAnimation(
                        customHeight: MediaQuery.of(context).size.height - 375);
                  }),
            ),
          ]),
        ),
      ),
    );
  }
}
