import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../Models/invoice_data.dart';

class InvoiceCaptureScreen extends ConsumerStatefulWidget {
  InvoiceCaptureScreen({required this.imageFile, super.key});

  final XFile imageFile;

  @override
  ConsumerState<InvoiceCaptureScreen> createState() =>
      _InvoiceCaptureScreenState();
}

class _InvoiceCaptureScreenState extends ConsumerState<InvoiceCaptureScreen> {
  late List<String> scannedText;

  bool _isLoading = true;

  //TextLabelControllers
  TextEditingController CompanyTextController = TextEditingController();
  TextEditingController InvoiceNoTextController = TextEditingController();
  TextEditingController DateTextController = TextEditingController();
  TextEditingController AmountTextController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  //TextLabelStyle
  InputDecoration TextFieldDecoration = InputDecoration(
      border: OutlineInputBorder(),
      isDense: true,
      labelText: "",
      labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      counterStyle: TextStyle(fontSize: 0)
  );

  //TODO: INFO OVERLAY WILL BE ADDED.
  //TODO: Company name selection screen will be added.
  //TODO: Invoice Type detection will be added.

  //Regex
  //RegExp NameRegex = RegExp(r"\b([A-ZÀ-ÿ][-,a-z. ']+[ ]*)+", caseSensitive: false);

  RegExp CompanyRegex =
      RegExp(r"(?:LTD\.|ŞT(İ|Í)\.|A\.Ş\.)", caseSensitive: false);
  RegExp DateRegex = RegExp(
      r"(0[1-9]|[12][0-9]|3[01])(\/|-)(0[1-9]|1[1,2])(\/|-)(19|20)\d{2}",
      caseSensitive: false);
  RegExp AmountRegex = RegExp(
      r"^(\$|\₺|€)(0|[1-9][0-9]{0,2})(,\d{1,4})*(\.\d{1,2})?$|^(0|[1-9][0-9]{0,2})(,\d{1,4})*(\.\d{1,2})?(\$|\₺| TL|TL|€)$",
      caseSensitive: false);

  //To get readed text
  getRecognisedText(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    textRecognizer.close();
    setState(() {
      scannedText = recognizedText.text.split("\n");
    });
    print(scannedText);
  }

  // The function that calculate which is company
  getInvoiceThing(List ListText) {
    CompanyTextController.text = ListText[0];

    // I know, this section so suck. I will try improve here when I found time.
    // For every each text in ListText
    ListText.forEach((i) {
      // Text if match with CompanyRegex
      if (CompanyRegex.hasMatch(i)) {
        // Set text to CompanyTextController.text
        CompanyTextController.text = i;
      }
      // Text if match with DateRegex
      else if (DateRegex.hasMatch(i)) {
        // Set text to DateTextController.text
        DateTextController.text = i;
      }
      // If text lenght is 16
      else if (i.length == 16) {
        // set text to InvoiceNoTextController.text
        InvoiceNoTextController.text = i;
      }
      // Text if match with AmountRegex
      else if (AmountRegex.hasMatch(i)) {
        // Set text to AmountTextController.text
        AmountTextController.text = i;
      }
    });
    _isLoading = false;
  }

  FieldFiller() async {
    await getRecognisedText(widget.imageFile);
    getInvoiceThing(scannedText);
  }

  @override
  void initState() {
    FieldFiller();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                  ? CircularProgressIndicator()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Divider(height: 20),
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
                                  controller: CompanyTextController,
                                  decoration: TextFieldDecoration.copyWith(labelText: "Company name:"),
                                  validator: (value) {
                                    if (value == null ||
                                        value.isEmpty ||
                                        !CompanyRegex.hasMatch(value)) {
                                      return 'Please enter some text';
                                    }
                                    return null;
                                  },
                                ),
                                TextFormField(
                                  maxLength: 50,
                                  controller: InvoiceNoTextController,
                                  decoration: TextFieldDecoration.copyWith(labelText: "Invoice No:"),
                                  validator: (value) {
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
                                  controller: DateTextController,
                                  readOnly: true,
                                  decoration: TextFieldDecoration.copyWith(labelText: "Date:"),
                                  onTap: () async {
                                    DateTime today = DateTime.now();
                                    DateTime? pickedDate = await showDatePicker(
                                        context: context,
                                        initialDate: today,
                                        //get today's date
                                        firstDate: DateTime(1900),
                                        //DateTime.now() - not to allow to choose before today.
                                        lastDate: DateTime(today.year,
                                            today.month, today.day));

                                    if (pickedDate != null) {
                                      print(
                                          pickedDate); //get the picked date in the format => 2022-07-04 00:00:00.000
                                      String formattedDate =
                                          DateFormat('dd-MM-yyyy').format(
                                              pickedDate); // format date in required form here we use yyyy-MM-dd that means time is removed
                                      print(
                                          formattedDate); //formatted date output using intl package =>  2022-07-04
                                      //You can format date as per your need

                                      setState(() {
                                        DateTextController.text =
                                            formattedDate; //set formatted date to TextField value.
                                      });
                                    }
                                    ;
                                  },
                                  validator: (value) {
                                    if (value == null ||
                                        value.isEmpty ||
                                        !DateRegex.hasMatch(value)) {
                                      return "";
                                    }
                                    return null;
                                  },
                                ),
                                TextFormField(
                                  maxLength: 50,
                                  controller: AmountTextController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  // Only numbers can be entered
                                  validator: (value) {
                                    if (value == null ||
                                        value.isEmpty) {
                                      return "";
                                    }
                                    return null;
                                  },
                                  decoration: TextFieldDecoration.copyWith(labelText: "Amount:"),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ElevatedButton(
                            child: Icon(Icons.save_as_rounded),
                            onPressed: () {
                              // Validate returns true if the form is valid, or false otherwise.
                              if (_formKey.currentState!.validate()) {
                                // If the form is valid, display a snackbar. In the real world,
                                // you'd often call a server or save the information in a database.
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Processing Data')),
                                );

                                final InvoiceDataBox = Hive.box('InvoiceData');

                                //For state management
                                //ref.read(InvoicerListProvider.notifier).add(
                                // InvoiceImage: Image.file(File(widget.imageFile.path)),
                                // CompanyName: CompanyTextController.text,
                                // InvoiceNo: InvoiceNoTextController.text,
                                // Date: DateFormat("dd-MM-yyyy").parse(DateTextController.text),
                                // Amount: double.parse(AmountTextController.text));

                                final data = InvoiceData(
                                    InvoiceImage:
                                        Image.file(File(widget.imageFile.path)),
                                    CompanyName: CompanyTextController.text,
                                    InvoiceNo: InvoiceNoTextController.text,
                                    Date: DateFormat("dd-MM-yyyy")
                                        .parse(DateTextController.text),
                                    Amount: double.parse(
                                        AmountTextController.text));
                                InvoiceDataBox.add(data);
                              }
                            }),
                      ],
                    ),
            ),
          ]),
        ),
      ),
    );
  }
}