import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:string_similarity/string_similarity.dart';

import '../Models/invoice_data.dart';
import '../company_name_filter.dart';
import '../toast.dart';

class InvoiceCaptureScreen extends StatefulWidget {
  const InvoiceCaptureScreen(
      {this.editIndex, required this.imageFile, super.key});

  final XFile imageFile;
  final int? editIndex;

  @override
  State<InvoiceCaptureScreen> createState() => _InvoiceCaptureScreenState();
}

class _InvoiceCaptureScreenState extends State<InvoiceCaptureScreen> {
  late List<String> scannedText;

  bool _isLoading = true;

  bool _saveButtonState = true;

  //TextLabelControllers
  TextEditingController companyTextController = TextEditingController();
  TextEditingController invoiceNoTextController = TextEditingController();
  TextEditingController dateTextController = TextEditingController();
  TextEditingController amountTextController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final DateFormat dateFormat = DateFormat("dd-MM-yyyy");

  //TextLabelStyle
  InputDecoration textFieldDecoration(final text, final message) =>
      InputDecoration(
          border: const OutlineInputBorder(),
          isDense: true,
          labelText: text,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          counterStyle: const TextStyle(fontSize: 0),
          errorStyle: const TextStyle(fontSize: 0),
          suffixIcon: Tooltip(
              triggerMode: TooltipTriggerMode.tap,
              showDuration: const Duration(seconds: 3),
              message: message,
              child: const Icon(
                Icons.info_outline,
                size: 24,
              )));

  //TODO: Company name selection screen will be added.
  //TODO: Invoice Type detection will be added.

  //Regex
  //RegExp NameRegex = RegExp(r"\b([A-ZÀ-ÿ][-,a-z. ']+[ ]*)+", caseSensitive: false);

  // I need to find a different solution here, because it is not working perfectly.
  // I inspected some similar projects and they are working perfectly but they are not open source. They probably using OCR.
  // I am open to contributions.
  // Google ML Text Recognition is not working perfectly, so it can’t read everything properly.
  // OCR can be used here, but there are a lot of projects already available (GCS also has invoice recognition but it needs a price to use).
  // So I wanna make my own parser or reader for the best use of Google ML Text Recognition.

  final RegExp companyRegex =
      RegExp(r"(?:LTD\.|ŞT(İ|Í)\.|A\.Ş\.|A\.S\.)", caseSensitive: false);
  final RegExp dateRegex = RegExp(
      r"(0[1-9]|[12][0-9]|3[01])(\/|-)(0[1-9]|1[1,2])(\/|-)(19|20)\d{2}",
      caseSensitive: false);
  final RegExp amountRegex = RegExp(
      r"^(\$|\₺|€)(0|[1-9][0-9]{0,2})(,\d{1,4})*(\.\d{1,2})?$|^(0|[1-9][0-9]{0,2})(,\d{1,4})*(\.\d{1,2})?(\$|\₺| TL|TL|€)$",
      caseSensitive: false);

  @override
  void initState() {
    widget.editIndex == null ? fieldFiller() : fetchInvoiceData();
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: CustomScrollView(slivers: [
            SliverAppBar(
              expandedHeight: 375,
              flexibleSpace: FlexibleSpaceBar(
                background: InteractiveViewer(
                  child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.file(
                        File(widget.imageFile.path),
                        fit: BoxFit.fitHeight,
                        width: double.maxFinite,
                      )),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Divider(height: 20),
                        Form(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
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
                                  decoration: textFieldDecoration(
                                      "Company name:",
                                      "You must enter a valid company name. Need include 'A.S., LTD. etc.'"),
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
                                  decoration: textFieldDecoration("Invoice No:",
                                      "You must enter a valid invoice no. Need 16 character."),
                                  validator: (final value) {
                                    if (value == null ||
                                        value.isEmpty ||
                                        value.length != 16) {
                                      return "";
                                    }
                                    return null;
                                  },
                                ),
                                TextFormField(
                                  maxLength: 50,
                                  controller: dateTextController,
                                  readOnly: true,
                                  decoration: textFieldDecoration(
                                      "Date:", "You must enter a valid date."),
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
                                TextFormField(
                                  maxLength: 50,
                                  controller: amountTextController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  // Only numbers can be entered
                                  validator: (final value) {
                                    if (value == null || value.isEmpty) {
                                      return "";
                                    }
                                    return null;
                                  },
                                  decoration: textFieldDecoration("Amount:",
                                      "You must enter a valid amount."),
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
                    ),
            ),
          ]),
        ),
      ),
    );
  }

  //To get readed text
  Future<void> getRecognisedText(final XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    await textRecognizer.close();
    setState(() {
      scannedText = recognizedText.text.split("\n");
    });

    //For test
    print(scannedText);
  }

  // The function that calculate which is company
  void getInvoiceThing(final List listText) {
    companyTextController.text = listText[0];

    // For every each text in ListText
    for (final i in listText) {
      // Text if match with CompanyRegex
      if (companyRegex.hasMatch(i)) {
        // Set text to CompanyTextController.text
        companyTextController.text = i;
      }
      // Text if match with DateRegex
      else if (dateRegex.hasMatch(i)) {
        // Set text to DateTextController.text
        dateTextController.text = dateFormat.format(dateFormat.parse(i));
      }
      // If text length is 16
      else if (i.length == 16) {
        // set text to InvoiceNoTextController.text
        invoiceNoTextController.text = i;
      }
      // Text if match with AmountRegex
      else if (amountRegex.hasMatch(i)) {
        // Set text to AmountTextController.text
        amountTextController.text = i;
      }
    }
    _isLoading = false;
  }

  Future<void> fieldFiller() async {
    await getRecognisedText(widget.imageFile);
    getInvoiceThing(scannedText);
  }

  Future<void> fetchInvoiceData() async {
    final InvoiceData item = Hive.box('InvoiceData').getAt(widget.editIndex!);

    companyTextController.text = item.companyName;
    invoiceNoTextController.text = item.invoiceNo;
    dateTextController.text = dateFormat.format(item.date);
    amountTextController.text = item.amount.toString();

    _isLoading = false;
  }

  Future<void> saveInvoice() async {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      setState(() {
        _saveButtonState = false;
      });

      // If the form is valid, display a snack bar. In the real world,
      // you'd often call a server or save the information in a database.

      final invoiceDataBox = Hive.box('InvoiceData');

      final List<InvoiceData> companyList = await getInvoiceDataList(
          listType.company, invoiceDataBox.values.cast<InvoiceData>());

      if (widget.editIndex == null) {
        for (final element in companyList) {
          final companyName = element.companyName;
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
                    style: const TextStyle(color: Colors.black),
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
        showSnackBar(context,
            text: "Processing Data...", color: Colors.deepOrangeAccent);
      }

      //For state management
      //ref.read(InvoiceListProvider.notifier).add(
      // InvoiceImage: Image.file(File(widget.imageFile.path)),
      // CompanyName: CompanyTextController.text,
      // InvoiceNo: InvoiceNoTextController.text,
      // Date: DateFormat("dd-MM-yyyy").parse(DateTextController.text),
      // Amount: double.parse(AmountTextController.text));

      final data = InvoiceData(
          ImagePath: widget.imageFile.path,
          companyName: companyTextController.text,
          invoiceNo: invoiceNoTextController.text,
          date: dateFormat.parse(dateTextController.text),
          amount: double.parse(amountTextController.text));

      widget.editIndex == null
          ? await invoiceDataBox.add(data)
          : await invoiceDataBox.putAt(widget.editIndex!, data);

      if (!mounted) {
        return;
      }

      showSnackBar(context, text: "Data Processed!", color: Colors.greenAccent);

      if (mounted) {
        setState(() {
          _saveButtonState = true;
        });

        Navigator.pop(context);
      }
    }
  }
}
