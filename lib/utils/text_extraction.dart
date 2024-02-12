import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

final TextRecognizer textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

Future<List<String>> getScannedText(final XFile image) async {

  img.Image adjustedImage = img.decodeImage(await File(image.path).readAsBytes())!;

  const int newWidth = 512;
  final int newHeight = (adjustedImage.height * newWidth) ~/ adjustedImage.width; // Oranı koruyun

  adjustedImage = img.copyResize(adjustedImage, width: newWidth, height: newHeight);

  img.smooth(adjustedImage, weight: 3);
  img.adjustColor(adjustedImage, brightness: 1.17);

  final Directory tempDir = await getTemporaryDirectory();
  final File imageFile = await File('${tempDir.path}/image.jpg').create();

  final pngBytes = await compute(img.encodePng, adjustedImage);
  await imageFile.writeAsBytes(pngBytes);

  final inputImage = InputImage.fromFile(File(image.path));
  final RecognizedText extractedText =
  await textRecognizer.processImage(inputImage);
  await textRecognizer.close();

  //For test
  print(extractedText.text.split("\n"));

  return extractedText.text.split("\n");

}
