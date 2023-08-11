import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'invoicer_repo.dart';

class InvoiceCaptureScreen extends ConsumerStatefulWidget {
  InvoiceCaptureScreen({required this.imageFile,super.key});

  final XFile imageFile;

  @override
  ConsumerState<InvoiceCaptureScreen> createState() => _InvoiceCaptureScreenState();
}

class _InvoiceCaptureScreenState extends ConsumerState<InvoiceCaptureScreen> {

  late List<String> scannedText;

  TextStyle labelStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 20);

  late String CompanyName;
  late int InvoiceNo;
  late DateTime Date;
  late double Amount;

  TextEditingController CompanyTextController = TextEditingController();
  TextEditingController InvoiceNoTextController = TextEditingController();
  TextEditingController DateTextController = TextEditingController();
  TextEditingController AmountTextController = TextEditingController();

  getRecognisedText(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    textRecognizer.close();
    setState(() {
      scannedText = recognizedText.text.split("\n");
    });
    print(scannedText);

  }

  // Şirket ismi olmasını hesaplayan bir fonksiyon
  void getInvoiceThing(List ListText) {
    CompanyTextController.text = ListText[0];

    //RegExp NameRegex = RegExp(r"\b([A-ZÀ-ÿ][-,a-z. ']+[ ]*)+", caseSensitive: false);

    RegExp CompanyRegex = RegExp(r"(?:LTD\.|ŞT(İ|Í)\.|A\.Ş\.)", caseSensitive: false);
    RegExp DateRegex = RegExp(r"(0[1-9]|[12][0-9]|3[01])(\/|-)(0[1-9]|1[1,2])(\/|-)(19|20)\d{2}", caseSensitive: false);
    RegExp AmountRegex = RegExp(r"^(\$|\₺|€)(0|[1-9][0-9]{0,2})(,\d{1,4})*(\.\d{1,2})?$|^(0|[1-9][0-9]{0,2})(,\d{1,4})*(\.\d{1,2})?(\$|\₺| TL|TL|€)$", caseSensitive: false);

// ListText içindeki her bir metin için
    ListText.forEach((i) {
      // Metin CompanyRegex ile eşleşiyorsa
      if (CompanyRegex.hasMatch(i)) {
        // CompanyTextController.text'e metni ata
        CompanyTextController.text = i;
      }
      // Metin DateRegex ile eşleşiyorsa
      else if (DateRegex.hasMatch(i)) {
        // DateTextController.text'e metni ata
        DateTextController.text = i;
      }
      // Metnin uzunluğu 16 ise
      else if (i.length == 16) {
        // InvoiceNoTextController.text'e metni ata
        InvoiceNoTextController.text = i;
      }
      // Metin AmountRegex ile eşleşiyorsa
      else if (AmountRegex.hasMatch(i)) {
        // AmountTextController.text'e metni ata
        AmountTextController.text = i;
      }
    });

  }

  // Fatura no olmasını hesaplayan bir fonksiyon
  String getInvoiceNo(ListText) {
    RegExp companyRegex = RegExp('(?:LTD\.|ŞT(İ|Í)\.|A\.Ş\.)', caseSensitive: false);

    for(String i in ListText) {
      if (companyRegex.hasMatch(i)) return i;
    }

    return "Şirket bulunamadı.";
  }






  void FieldFiller() async {
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
    final InvoicerList = ref.watch(InvoicerListProvider);

    return SafeArea(
        child: Scaffold(
          appBar: AppBar(),
          body: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 350,
                    width: 312,
                    child: Image.file(File(widget.imageFile.path)),
                  ),
                  Divider(height: 20,),
                  Container(
                    width: 312,
                    height: 236,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextField(
                          maxLength: 50,
                          controller: CompanyTextController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                            labelText: 'Company Name:',
                            labelStyle: labelStyle,
                            counterStyle: TextStyle(fontSize: 0)
                          ),
                        ),
                        TextField(
                          maxLength: 50,
                          controller: InvoiceNoTextController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                            labelText: 'Invoice No:',
                            labelStyle: labelStyle,
                            counterStyle: TextStyle(fontSize: 0)
                          ),
                        ),
                        TextField(
                          maxLength: 50,
                          controller: DateTextController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                            labelText: 'Date:',
                            labelStyle: labelStyle,
                            counterStyle: TextStyle(fontSize: 0)
                          ),
                        ),
                        TextField(
                          maxLength: 50,
                          controller: AmountTextController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                            labelText: 'Amount:',
                            labelStyle: labelStyle,
                            counterStyle: TextStyle(fontSize: 0),
                          ),
                        ),
                      ],
                    ),
                  ),

                  FloatingActionButton(
                      child: Icon(Icons.save_as_rounded),
                      onPressed: () {
                        ref.read(InvoicerListProvider.notifier).add(InvoiceImage: Image.file(File(widget.imageFile.path)), CompanyName: CompanyTextController.text, InvoiceNo: InvoiceNoTextController.text, Date: DateFormat("dd-MM-yyyy").parse(DateTextController.text), Amount: double.parse(AmountTextController.text));
                      })
                ],
              ),
            ),
          ),
    ));
  }
}

final InvoicerListProvider = NotifierProvider<InvoicerList, List<InvoicerRepo>>(InvoicerList.new);