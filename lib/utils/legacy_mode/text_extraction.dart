import 'package:cross_file/cross_file.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

final TextRecognizer textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

Future<List<String>> getScannedText(final XFile image) async {

  final inputImage = InputImage.fromFilePath(image.path);

  final RecognizedText extractedText =
  await textRecognizer.processImage(inputImage);

  await textRecognizer.close();

  return extractedText.text.split("\n");

}
