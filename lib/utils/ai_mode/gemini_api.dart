import 'dart:io';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';

class GeminiAPI {

  Future<String> describeImage({required final File imgFile, required final String prompt}) async {

    final model =  FirebaseVertexAI.instanceFor(
      appCheck: FirebaseAppCheck.instanceFor(app: Firebase.app()),
    ).generativeModel(
      model: 'gemini-1.5-flash',
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );

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
