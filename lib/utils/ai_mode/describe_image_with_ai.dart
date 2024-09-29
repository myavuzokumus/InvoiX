import 'dart:io';

import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoix/states/firebase_state.dart';
import 'package:invoix/utils/ai_mode/prompts.dart';

enum ProcessType {
  scan,
  describe,
}

Future<String> describeImageWithAI({required final File imgFile, required final ProcessType type}) async {

  final firebaseService = ProviderContainer().read(firebaseServiceProvider);

  final String prompt;
  final Map<String, dynamic> checkUsage;

    if (type == ProcessType.scan) {
      prompt = identifyInvoicePrompt;
      checkUsage = await firebaseService.checkUsageRights("aiInvoiceReads", decrease: true);
    } else {
      prompt = describeInvoicePrompt;
      checkUsage = await firebaseService.checkUsageRights("aiInvoiceAnalyses", decrease: true);
    }

    if (!checkUsage["success"]) {
      throw Exception(checkUsage.toString());
    }

  final response = await (firebaseService.model.generateContent([
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
