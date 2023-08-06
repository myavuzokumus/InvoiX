import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class InvoiceCaptureScreen extends StatefulWidget {
  InvoiceCaptureScreen({required this.imageFile,super.key});

  final XFile? imageFile;

  @override
  State<InvoiceCaptureScreen> createState() => _InvoiceCaptureScreenState();
}

class _InvoiceCaptureScreenState extends State<InvoiceCaptureScreen> {
  String scannedText = "Yazı bulunamadı.";

  getRecognisedText(XFile image) async{
    final inputImage = InputImage.fromFilePath(image.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    scannedText = recognizedText.text;
    textRecognizer.close();
    for (TextBlock block in recognizedText.blocks) {
      print(block.boundingBox);
      print(block.cornerPoints);
      print(block.text);
      print(block.recognizedLanguages);

      for (TextLine line in block.lines) {
        print(line.text);
        for (TextElement element in line.elements) {
          print(element.text);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inverseSurface.withOpacity(0.5),
            iconTheme: IconThemeData(
                size: 30.0,
                color: Colors.white,
                opacity: 10.0
            ),
          ),
          body: Center(
            child: Column(
              children: [
                Container(
                  width: 512,
                  height: 512,
                  child: Image.file(File(widget.imageFile!.path)),
                ),
                Container(
                  width: 256,
                  child: Text(
                      scannedText
                  ),
                ),
                FloatingActionButton(onPressed: () {})
              ],
            ),
          ),
    ));
  }
}
