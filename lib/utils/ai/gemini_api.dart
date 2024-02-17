import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiAPI {
  final model = GenerativeModel(
      model: 'gemini-pro-vision',
      apiKey: dotenv.env['GEMINI_API_KEY']!
  );

  Future<String> describeImage({required final File imgFile, required final String prompt}) async {

    final response = await (model.generateContent([
          Content.multi([
            TextPart(prompt),
            DataPart('image/jpeg', imgFile.readAsBytesSync())
          ])
        ]));

    return response.text!.replaceAll("```", "")
        .replaceFirst("json", "");

  }
}
