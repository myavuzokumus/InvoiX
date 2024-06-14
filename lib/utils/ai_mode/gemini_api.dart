import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiAPI {
  final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: dotenv.env['GEMINI_API_KEY']!,
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
  );

  Future<String> describeImage({required final File imgFile, required final String prompt}) async {

    final response = await (model.generateContent([
          Content.multi([
            TextPart(prompt),
            DataPart('image/jpeg', imgFile.readAsBytesSync())
          ])
        ]));

    return response.text!;

  }
}

// Using Gemini, invoice diagnosis is made with certain prompts and the output is returned to the user.
// This class performs invoice identification using the Google Generative AI package.
