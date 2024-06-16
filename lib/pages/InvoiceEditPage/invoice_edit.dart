import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:invoix/models/invoice_data.dart';
import 'package:invoix/pages/CompaniesPage/company_list.dart';
import 'package:invoix/pages/InvoiceEditPage/date_format.dart';
import 'package:invoix/utils/ai_mode/gemini_api.dart';
import 'package:invoix/utils/ai_mode/prompts.dart';
import 'package:invoix/utils/blur_detector.dart';
import 'package:invoix/utils/date_parser.dart';
import 'package:invoix/utils/image_filter.dart';
import 'package:invoix/utils/invoice_data_service.dart';
import 'package:invoix/utils/legacy_mode/invoice_parser.dart';
import 'package:invoix/utils/legacy_mode/text_extraction.dart';
import 'package:invoix/utils/legacy_mode/text_to_invoicedata_regex.dart';
import 'package:invoix/utils/network_check.dart';
import 'package:invoix/utils/read_mode.dart';
import 'package:invoix/widgets/loading_animation.dart';
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
                  companySuffix = InvoiceDataService().companyTypeFinder(item);
                });
              },
            )
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: CustomScrollView(slivers: [
            SliverAppBar(
              actions: const [
                Tooltip(
                  triggerMode: TooltipTriggerMode.tap,
                  showDuration: Duration(seconds: 3),
                  message: "Zoom in and out to see the image details.",
                  child: Icon(Icons.zoom_out_map, size: 28),
                )
              ],
              expandedHeight: 350,
              flexibleSpace: FlexibleSpaceBar(
                background: InteractiveViewer(
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
            SliverToBoxAdapter(
              child: FutureBuilder(
                  future: _future,
                  builder: (final BuildContext context,
                      final AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {

                      if (snapshot.hasError) {
                        Future(() {Toast(context, text: snapshot.error.toString(), color: Colors.red);});
                      }

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton.filledTonal(
                                  onPressed: () {
                                    _scaffoldKey.currentState!.openEndDrawer();
                                  },
                                  icon: const Icon(Icons.search)),
                              DateFormatSegmented(onChange: (final value) {
                                if (value == DateFormatSegment.uk) {
                                  dateTextController.text =
                                      DateFormat("dd-MM-yyyy").format(
                                          DateFormat("MM-dd-yyyy")
                                              .parse(dateTextController.text));
                                } else if (value == DateFormatSegment.us) {
                                  dateTextController.text =
                                      DateFormat("MM-dd-yyyy").format(
                                          DateFormat("dd-MM-yyyy")
                                              .parse(dateTextController.text));
                                }
                              }),
                            ],
                          ),
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
                                  TextFormField(
                                    maxLength: 100,
                                    controller: companyTextController,
                                    decoration: InputDecoration(
                                        labelText: "Company name:",
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
                                                decoration:
                                                    const InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 4,
                                                          horizontal: 12),
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
                                              padding: EdgeInsets.only(
                                                  right: 12.0, left: 4.0),
                                              child: WarnIcon(
                                                  message:
                                                      "You must choose a company type."),
                                            ),
                                          ],
                                        )),
                                    validator: (final value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter some text';
                                      }
                                      return null;
                                    },
                                  ),
                                  TextFormField(
                                    maxLength: 50,
                                    controller: invoiceNoTextController,
                                    decoration: const InputDecoration(
                                        labelText: "Invoice No:",
                                        suffixIcon: WarnIcon(
                                            message:
                                                "You must enter a valid invoice no.")),
                                    validator: (final value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter some text';
                                      }
                                      return null;
                                    },
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
                                          decoration: const InputDecoration(
                                              labelText: "Date:",
                                              suffixIcon: WarnIcon(
                                                  message:
                                                      "You must enter a valid date.")),
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
                                      Expanded(
                                        child: DropdownButtonFormField<
                                            InvoiceCategory>(
                                          value: invoiceCategory,
                                          alignment: Alignment.centerRight,
                                          menuMaxHeight: 225,
                                          hint: const Text("Type"),
                                          iconSize: 0,
                                          items: InvoiceCategory.values.map(
                                              (final InvoiceCategory value) {
                                            return DropdownMenuItem<
                                                InvoiceCategory>(
                                              value: value,
                                              child: Text(value.name),
                                            );
                                          }).toList(),
                                          onChanged:
                                              (final InvoiceCategory? value) {
                                            invoiceCategory = value ?? InvoiceCategory.Others;
                                          },
                                          decoration: const InputDecoration(
                                            isDense: true,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: -8.0),
                                            suffixIcon: WarnIcon(
                                                message:
                                                    "You must choose a invoice category."),
                                            filled: true,
                                          ),
                                          validator: (final value) {
                                            if (value == null) {
                                              return 'Please select invoice category.';
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
                                          decoration: const InputDecoration(
                                              labelText: "Total Amount:",
                                              suffixIcon: WarnIcon(
                                                  message:
                                                      "You must enter a valid amount."),
                                              labelStyle: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold)),
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
                                          decoration: const InputDecoration(
                                              labelText: "Tax Amount:",
                                              suffixIcon: WarnIcon(
                                                  message:
                                                      "You must enter a valid amount."),
                                              labelStyle: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold)),
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
                        customHeight: MediaQuery.of(context).size.height - 350, subsControl: true);
                  }),
            ),
          ]),
        ),
      ),
    );
  }
}
