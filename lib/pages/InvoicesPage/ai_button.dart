import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:invoix/models/invoice_analysis.dart';
import 'package:invoix/utils/ai_mode/gemini_api.dart';
import 'package:invoix/utils/ai_mode/prompts.dart';
import 'package:invoix/widgets/loading_animation.dart';
import 'package:invoix/widgets/toast.dart';
import 'package:invoix/widgets/warn_icon.dart';

class AIButton extends StatelessWidget {
  const AIButton({super.key, required this.invoiceImage});

  final File invoiceImage;

  @override
  Widget build(final BuildContext context) {
    return IconButton.outlined(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.black.withOpacity(0.35),
        side: const BorderSide(width: 1.5, color: Colors.orangeAccent),
      ),
      onPressed: () async {
        final Box<int> box = await Hive.openBox<int>('remainingTimeBox');
        int remainingTime = box.get(invoiceImage.path) ?? 0;

        if (remainingTime == 0) {
          Timer.periodic(const Duration(seconds: 1), (final t) async {
            remainingTime += 1;

            if (remainingTime >= 30) {
              remainingTime = 0;
              t.cancel();
            }
            await box.put(invoiceImage.path, remainingTime);
          });

          await showModalBottomSheet<void>(
            showDragHandle: true,
            context: context,
            builder: (final BuildContext context) {
              return SizedBox(
                height: 425,
                width: double.infinity,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 24, bottom: 24, right: 24),
                  child: LayoutBuilder(
                    builder: (final BuildContext context,
                        final BoxConstraints constraints) {
                      return Card(
                          color: const Color(0xff442a22),
                          elevation: 16,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: FutureBuilder(
                              future: GeminiAPI().describeImage(
                                  imgFile: invoiceImage,
                                  prompt: describeInvoicePrompt),
                              builder: (final BuildContext context,
                                  final AsyncSnapshot<String> snapshot) {
                                if (snapshot.hasData) {
                                  final Map<String, dynamic> decodedData =
                                      jsonDecode(snapshot.data!);
                                  final InvoiceAnalysis invoiceAnalysis =
                                      InvoiceAnalysis.fromJson(decodedData);

                                  return describedWidget(invoiceAnalysis);
                                } else if (snapshot.hasError) {
                                  return const Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(Icons.phonelink_erase_rounded,
                                          size: 92, color: Colors.red),
                                      Text('No Internet Connection',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  );
                                }
                                return Column(
                                  children: [
                                    LoadingAnimation(
                                        customHeight:
                                            constraints.maxHeight - 72),
                                    const Text(
                                        'The invoice is being analyzed...',
                                        textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  ],
                                );
                              },
                            ),
                          ));
                    },
                  ),
                ),
              );
            },
          );
        } else {
          Toast(context,
              text: "Please wait ${30 - remainingTime} seconds before analyze the invoice again.");
        }
      },
      icon: const Text("✨", style: TextStyle(fontSize: 17)),
      tooltip: 'Analyze it with AI',
    );
  }

  //This is ridiculous, I know, but I did it this way to improve the application.
  Widget describedWidget(final InvoiceAnalysis invoiceAnalysis) {
    return ListView(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Purchased products",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left),
            WarnIcon(
                message:
                    "The information provided may sometimes be incorrect. Please take this into consideration and pay attention to the recommendations.")
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: RichText(
            text: TextSpan(
              children: invoiceAnalysis.whichItemsBought
                  .map((final e) => TextSpan(
                        text: "● ${e.name}\n",
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                        children: <TextSpan>[
                          TextSpan(
                            text: "- ${e.price}\n",
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.normal),
                          ),
                        ],
                      ))
                  .toList(),
            ),
          ),
        ),
        ExpansionTile(
          initiallyExpanded: true,
          title: const Text(
              "Are the products purchased harmful to human health?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
              child: Text(invoiceAnalysis.anyHealthProblem,
                  style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        ExpansionTile(
          title: const Text(
              "Are the purchased products harmful to the environment?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
              child: Text(invoiceAnalysis.anyHabitatProblem,
                  style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        ExpansionTile(
          title: const Text(
              "What are the alternatives to the products purchased?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
              child: RichText(
                text: TextSpan(
                  children: invoiceAnalysis.alternatives
                      .map((final e) => TextSpan(
                            text: "● ${e.name}\n",
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                            children: <TextSpan>[
                              TextSpan(
                                text: "- ${e.description}\n",
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: const Text(
              "What can be suggested for more conscious consumption?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
              child: Text(invoiceAnalysis.consciousConsumption,
                  style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        ExpansionTile(
          title: const Text(
              "What is the market value of the products purchased? How has this value changed in the last year?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
              child: Text(invoiceAnalysis.marketResearch,
                  style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ],
    );
  }
}
