import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:invoix/main.dart';
import 'package:invoix/models/invoice_data.dart';
import 'package:invoix/utils/ai/geminiAPI.dart';
import 'package:invoix/utils/ai/prompts.dart';
import 'package:invoix/utils/image_filter.dart';
import 'package:invoix/utils/text_extraction.dart';
import 'package:invoix/widgets/date_format.dart';
import 'package:invoix/widgets/loading_animation.dart';
import 'package:string_similarity/string_similarity.dart';

import '../pages/company_list.dart';
import '../utils/company_name_filter.dart';
import '../utils/image_to_text_regex.dart';
import '../widgets/toast.dart';
import '../widgets/warn_icon.dart';

class InvoiceCaptureScreen extends StatefulWidget {

  const InvoiceCaptureScreen(
      {this.editIndex, required this.imageFile, required this.readMode, super.key});

  final ReadMode readMode;
  final XFile imageFile;
  final int? editIndex;

  @override
  State<InvoiceCaptureScreen> createState() => _InvoiceCaptureScreenState();
}

class _InvoiceCaptureScreenState extends State<InvoiceCaptureScreen> {

  late bool _saveButtonState;

  late final XFile imageFile;
  late final int? editIndex;

  //TextLabelControllers
  late final TextEditingController companyTextController;
  late final TextEditingController invoiceNoTextController;
  late final TextEditingController dateTextController;
  late final TextEditingController totalAmountTextController;
  late final TextEditingController taxAmountTextController;

  late final GlobalKey<ScaffoldState> _scaffoldKey;
  late final GlobalKey<FormState> _formKey;

  late Future<dynamic> _future;



  @override
  void initState() {

    _saveButtonState = true;

    editIndex = widget.editIndex;
    imageFile = widget.imageFile;

    companyTextController = TextEditingController();
    invoiceNoTextController = TextEditingController();
    dateTextController = TextEditingController();
    totalAmountTextController = TextEditingController();
    taxAmountTextController = TextEditingController();

    _scaffoldKey = GlobalKey<ScaffoldState>();
    _formKey = GlobalKey<FormState>();

    _future =
        editIndex == null ? collectReadData() : fetchInvoiceData();

    super.initState();
  }

  @override
  void dispose() {
    companyTextController.dispose();
    invoiceNoTextController.dispose();
    dateTextController.dispose();
    totalAmountTextController.dispose();
    _scaffoldKey.currentState?.dispose();
    _formKey.currentState?.dispose();

    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        endDrawerEnableOpenDragGesture: false,
        endDrawer: NavigationDrawer(
          children: [
            CompanyList(
              onTap: (final item) {
                _scaffoldKey.currentState!.closeEndDrawer();
                setState(() {
                  companyTextController.text = item;
                });
              },
            )
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: CustomScrollView(
              slivers: [
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
                  child: AspectRatio(
                      aspectRatio: 1,
                      child: Hero(
                        tag: imageFile.path,
                        child: Image.file(
                          File(imageFile.path),
                          fit: BoxFit.fitHeight,
                          width: double.maxFinite,
                        ),
                      )),
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

                      return Center(
                        child: Column(
                          children: [
                            const Divider(),
                            Text("Error:\n${snapshot.error}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 18)),
                            FilledButton.tonal(
                              onPressed: () {
                                setState(() {
                                  _future = editIndex == null
                                      ? collectReadData()
                                      : fetchInvoiceData();
                                });
                              },
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                      );
                    }

                    else {
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
                                    maxLength: 50,
                                    controller: companyTextController,
                                    decoration: const InputDecoration(
                                        labelText: "Company name:",
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
                                  TextFormField(
                                    maxLength: 50,
                                    controller: invoiceNoTextController,
                                    decoration: const InputDecoration(
                                        labelText: "Invoice No:",
                                        suffixIcon: WarnIcon(
                                            message:
                                            "You must enter a valid invoice no.")),
                                  ),
                                  TextFormField(
                                    maxLength: 50,
                                    controller: dateTextController,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                        labelText: "Date:",
                                        suffixIcon: WarnIcon(
                                            message:
                                            "You must enter a valid date.")),
                                    onTap: () async {
                                      final DateTime today = DateTime.now();
                                      final DateTime? pickedDate =
                                      await showDatePicker(
                                          context: context,
                                          initialDate: today,
                                          //get today's date
                                          firstDate: DateTime(1900),
                                          //DateTime.now() - not to allow to choose before today.
                                          lastDate: DateTime(today.year,
                                              today.month, today.day));

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
                                      if (value == null || value.isEmpty) {
                                        return "";
                                      }
                                      return null;
                                    },
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: TextFormField(
                                          maxLength: 50,
                                          controller: totalAmountTextController,
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                                          ],
                                          // Only numbers can be entered
                                          validator: (final value) {
                                            if (value == null || value.isEmpty) {
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
                                                  fontSize: 15, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Flexible(
                                        child: TextFormField(
                                          maxLength: 50,
                                          controller: taxAmountTextController,
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                                          ],
                                          // Only numbers can be entered
                                          validator: (final value) {
                                            if (value == null || value.isEmpty) {
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
                                                  fontSize: 15, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _saveButtonState ? saveInvoice : null,
                            child: _saveButtonState
                                ? const Icon(Icons.save_as_rounded)
                                : const CircularProgressIndicator(),
                          ),
                        ],
                      );
                    }
                  } else {
                    return LoadingAnimation(customHeight: MediaQuery.of(context).size.height - 350);
                  }
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> collectReadData() async {

    if( widget.readMode == ReadMode.legacy) {
      await imageFilter(imageFile);
      getInvoiceData(await getScannedText(imageFile));
      await Future.delayed(const Duration(seconds: 2));
    }
    else if ( widget.readMode == ReadMode.ai) {
      await GeminiAPI().describeImage(imgFile: File(imageFile.path), prompt: identifyInvoicePrompt);
    }

  }

  // Get Invoice Data from scanned text with Regex
  void getInvoiceData(final List listText) {
    companyTextController.text = listText[0];

    String invoiceNo = "";

    // For every each text in ListText
    for (String i in listText) {
      // Text if match with CompanyRegex
      if (companyRegex.hasMatch(i)) {
        // Set text to CompanyTextController.text
        if (i.contains("A.S.")) {
          i = i.replaceAll("A.S.", "A.Ş.");
        }
        companyTextController.text = i;
      }
      // Text if match with DateRegex

      else if (dateRegex.hasMatch(i)) {
        // Set text to DateTextController.text
        final RegExpMatch? matchedDate = dateRegex.firstMatch(i);
        if (matchedDate != null) {
          i = i.substring(matchedDate.start, matchedDate.end);
        }

        late final DateTime? parsedDate;

        for (final DateFormat format in dateFormats) {
          try {
            parsedDate = format.parse(i);
            print('Parsed Date with format $format: $parsedDate');
            break;
          } catch (e) {
            print('Failed to parse date with format $format');
          }
        }

        dateTextController.text = parsedDate != null ? dateFormat.format(parsedDate) : "";
      }
      // If text length is 16
      else if (invoiceNoRegex.hasMatch(i)) {
        // set text to InvoiceNoTextController.text
        i = i.replaceAll(" ", "");
        if (i.contains(":")) {
          i = i.split(":").last;
        }

        invoiceNoTextController.text = i;

      }
      // Text if match with AmountRegex
      else if (amountRegex.hasMatch(i)) {
        // Set text to AmountTextController.text
        i = i.replaceAll(RegExp(r'[^0-9.,]'), "").replaceAll(",", ".");
        totalAmountTextController.text = double.parse(i).toString();
      }

      if (i.toUpperCase().contains("NO")) {
        if (listText.length != listText.indexOf(i) + 1) {
          i = listText.elementAt(listText.indexOf(i) + 1);
          i = i.replaceAll(" ", "");
          if (i.contains(":")) {
            i = i.split(":").last;
          }
          invoiceNo = i;
        }
      }

    }
    if (invoiceNoTextController.text.isEmpty) {
      invoiceNoTextController.text = invoiceNo;
    }
  }

  Future<void> fetchInvoiceData([final String? aioutput]) async {

    final InvoiceData item;

    if (editIndex != null) {
      item = invoiceDataBox.getAt(editIndex!);
    }
    else {
      item = InvoiceData.fromJson(jsonDecode(aioutput!));
    }

    companyTextController.text = item.companyName;
    invoiceNoTextController.text = item.invoiceNo;
    dateTextController.text = dateFormat.format(item.date);
    totalAmountTextController.text = item.totalAmount.toString();
    taxAmountTextController.text = item.taxAmount.toString();

  }

  Future<void> saveInvoice() async {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      setState(() {
        _saveButtonState = false;
      });

      // If the form is valid, display a snack bar. In the real world,
      // you'd often call a server or save the information in a database.

      final List<InvoiceData> companyList = await getInvoiceDataList(
          ListType.company, invoiceDataBox.values.cast<InvoiceData>());

      if (editIndex == null) {
        for (final element in companyList) {
          final companyName = element.companyName;

          // If the company name is the same as the company name in the database, bypass to similarity check
          if (companyTextController.text == companyName) {
            break;
          }
          final double similarity =
              (companyTextController.text).similarityTo(companyName);

          if (similarity >= 0.4) {
            if (mounted) {
              await showDialog<bool>(
                barrierDismissible: false,
                context: context,
                builder: (final BuildContext context) => AlertDialog(
                  title: const Text(
                    'Similar Company Found!',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  content: Text(
                    'Do you want to merge with it?'
                    '\n${companyTextController.text} -> $companyName',
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Yes!'),
                    ),
                  ],
                ),
              ).then((final value) {
                if (value == true) {
                  setState(() {
                    companyTextController.text = companyName;
                  });
                }
              });
            }
            break;
          }
        }
      }

      if (mounted) {
        toast(context,
            text: "Processing Data...", color: Colors.yellowAccent);
      }

      try {
        final data = InvoiceData(
            ImagePath: imageFile.path,
            companyName: companyTextController.text,
            invoiceNo: invoiceNoTextController.text,
            date: dateFormat.parse(dateTextController.text),
            totalAmount: double.parse(totalAmountTextController.text),
            taxAmount: double.parse(taxAmountTextController.text));

        editIndex == null
            ? await invoiceDataBox.add(data)
            : await invoiceDataBox.putAt(editIndex!, data);

        if (mounted) {
          toast(context,
              text: "Data Processed!", color: Colors.greenAccent);
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          toast(context,
              text: "Something went wrong.\n"
                  "${e}",
              color: Colors.redAccent);
        }
      } finally {
        setState(() {
          _saveButtonState = true;
        });
      }
    }
  }
}
