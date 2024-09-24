import 'dart:io';

import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoix/states/firebase_state.dart';

Future<String> describeImageWithAI({required final File imgFile, required final String prompt}) async {

  final model = ProviderContainer().read(firebaseServiceProvider).model;

  final response = await (model.generateContent([
    Content.multi([
      TextPart(prompt),
      DataPart('image/jpeg', imgFile.readAsBytesSync())
    ])
  ]));

  return response.text!;

}

//Future<String> cacheContent({required final File imgFile, required final String prompt}) async {
//
//    return describeImageWithAI(imgFile: imgFile, prompt: prompt);
//
//}


// Using Gemini, invoice diagnosis is made with certain prompts and the output is returned to the user.
// This class performs invoice identification using the Google Generative AI package.
