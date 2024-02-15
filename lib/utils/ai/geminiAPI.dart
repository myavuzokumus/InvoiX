import 'dart:io';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_gemini/src/models/candidates/candidates.dart';

class GeminiAPI {

  final gemini = Gemini.instance;

  Future<String> describeImage({required final File imgFile, required final String prompt}) async {

    final Candidates? output = await gemini.textAndImage(
        generationConfig: GenerationConfig(
          maxOutputTokens: 2000,
          temperature: 0.9,
          topP: 0.1,
          topK: 16,
        ),
        text: prompt, /// text
        images: [imgFile.readAsBytesSync()]
    ); /// list of images
    /// output is a list of candidates
    return output!.output!
        .replaceAll("```", "")
        .replaceFirst("json", "");
  }

}