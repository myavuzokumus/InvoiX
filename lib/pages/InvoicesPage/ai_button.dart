import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoix/models/invoice_analysis.dart';
import 'package:invoix/models/invoice_data.dart';
import 'package:invoix/services/firebase_service.dart';
import 'package:invoix/states/firebase_state.dart';
import 'package:invoix/states/invoice_data_state.dart';
import 'package:invoix/utils/cooldown.dart';
import 'package:invoix/utils/status/current_status_checker.dart';
import 'package:invoix/widgets/status/loading_animation.dart';
import 'package:invoix/widgets/status/show_current_status.dart';
import 'package:invoix/widgets/toast.dart';
import 'package:invoix/widgets/warn_icon.dart';

class AIButton extends ConsumerWidget {
  AIButton({super.key, required this.invoice});

  final InvoiceData invoice;

  late Future<String> _future;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    return IconButton.outlined(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.black.withOpacity(0.35),
        side: const BorderSide(width: 1.5, color: Colors.orangeAccent),
      ),
      onPressed: () async {
        final invoiceDataService = ref.read(invoiceDataServiceProvider);
        final firebaseService = ref.read(firebaseServiceProvider);

        final int remainingTime =
            invoiceDataService.remainingTimeBox.get(invoice.imagePath) ?? 0;

        if (remainingTime == 0 || invoice.contentCache.isNotEmpty) {
          if (invoice.contentCache.isEmpty) {
            await cooldown(
                remainingTime, invoice.imagePath, invoiceDataService);
          }

          _future = invoice.contentCache.isEmpty
              ? firebaseService.describeImageWithAI(
                  imgFile: File(invoice.imagePath), type: ProcessType.describe)
              : Future.value(jsonEncode(invoice.contentCache));

          await showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            enableDrag: true,
            showDragHandle: true,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            builder: (final BuildContext context) {
              return LayoutBuilder(
                builder: (final BuildContext context,
                    final BoxConstraints constraints) {
                  return StatefulBuilder(builder: (final BuildContext context,
                      final void Function(void Function()) setModalState) {
                    return SizedBox(
                      height: constraints.maxHeight - 38,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 24, bottom: 24, right: 24),
                        child: Card(
                            color: const Color(0xff442a22),
                            elevation: 16,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: FutureBuilder(
                                future: _future,
                                builder: (final BuildContext context,
                                    final AsyncSnapshot<String> snapshot) {
                                  if (snapshot.connectionState !=
                                      ConnectionState.done) {
                                    return Column(
                                      children: [
                                        LoadingAnimation(
                                            message:
                                                "The invoice is being analyzed...",
                                            customHeight:
                                                constraints.maxHeight - 110),
                                      ],
                                    );
                                  } else if (snapshot.hasData &&
                                      snapshot.connectionState ==
                                          ConnectionState.done) {
                                    try {
                                      final Map<String, dynamic> decodedData =
                                          jsonDecode(snapshot.data!);

                                      invoice.contentCache = decodedData;
                                      invoiceDataService
                                          .saveInvoiceData(invoice);

                                      final InvoiceAnalysis invoiceAnalysis =
                                          InvoiceAnalysis.fromJson(decodedData);

                                      return describedWidget(
                                          context,
                                          invoiceAnalysis,
                                          firebaseService,
                                          setModalState);
                                    } on Exception catch (e) {
                                      return FutureBuilder<Status>(
                                        future: currentStatusChecker(
                                            "aiInvoiceAnalyses"),
                                        builder: (final context,
                                            final statusSnapshot) {
                                          if (statusSnapshot.connectionState ==
                                              ConnectionState.done) {
                                            return ShowCurrentStatus(
                                                status: statusSnapshot.data!,
                                                customHeight:
                                                    constraints.maxHeight - 72);
                                          }
                                          return const LoadingAnimation();
                                        },
                                      );
                                    }
                                  } else if (snapshot.hasError) {
                                    return FutureBuilder<Status>(
                                      future: currentStatusChecker(
                                          "aiInvoiceAnalyses"),
                                      builder: (final context,
                                          final statusSnapshot) {
                                        if (statusSnapshot.connectionState ==
                                            ConnectionState.done) {
                                          return ShowCurrentStatus(
                                              status: statusSnapshot.data!,
                                              customHeight:
                                                  constraints.maxHeight - 72);
                                        }
                                        return const LoadingAnimation();
                                      },
                                    );
                                  }
                                  return Column(
                                    children: [
                                      LoadingAnimation(
                                          message:
                                              "The invoice is being analyzed...",
                                          customHeight:
                                              constraints.maxHeight - 72),
                                    ],
                                  );
                                },
                              ),
                            )),
                      ),
                    );
                  });
                },
              );
            },
          );
        } else {
          Toast(context,
              text:
                  "Please wait ${30 - remainingTime} seconds before analyze the invoice again.");
        }
      },
      icon: const Text("✨", style: TextStyle(fontSize: 17)),
      tooltip: 'Analyze the invoice with AI',
    );
  }

  //This is ridiculous, I know, but I did it this way to improve the application.
  Widget describedWidget(
      final context,
      final InvoiceAnalysis invoiceAnalysis,
      final firebaseService,
      final void Function(void Function() p1) setModalState) {
    return ListView(
      shrinkWrap: true,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Purchased products",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const WarnIcon(
                    message:
                        "The information provided may sometimes be incorrect.\nPlease take this into consideration and pay attention to the recommendations."),
                IconButton(
                    onPressed: () {
                      setModalState(() {
                        _future = firebaseService.describeImageWithAI(
                            imgFile: File(invoice.imagePath),
                            type: ProcessType.describe);
                      });
                    },
                    icon: const Icon(Icons.refresh_outlined)),
              ],
            ),
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
