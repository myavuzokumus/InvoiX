import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:invoix/models/invoice_data.dart';
import 'package:invoix/models/selection_state.dart';
import 'package:invoix/pages/InvoiceEditPage/invoice_edit.dart';
import 'package:invoix/pages/InvoicesPage/ai_button.dart';

class InvoiceCard extends ConsumerWidget {
  const InvoiceCard({super.key, required this.invoiceData});

  final InvoiceData invoiceData;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {

    final selectionState = ref.watch(invoiceProvider);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.3, 0.5, 0.7],
          colors: [Color(0xFF846AFF), Color(0xFF755EE8), Color(0xFF846AFF)],
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onLongPress: () {
            if (!selectionState.isSelectionMode) {
              selectionState.isSelectionMode = !selectionState.isSelectionMode;
              ref.read(invoiceProvider.notifier).toggleItemSelection(company: invoiceData.companyName, invoiceData: invoiceData);
            }
          },
          onTap: () {
            selectionState.isSelectionMode
                ? ref.read(invoiceProvider.notifier).toggleItemSelection(company: invoiceData.companyName, invoiceData: invoiceData)
                    :
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (final context) =>
                        InvoiceEditPage(
                          imageFile: XFile(invoiceData.imagePath),
                              invoiceData: invoiceData,
                        )));
          },
          splashColor: Colors.blue,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      Text("Invoice No\n${invoiceData.invoiceNo}"),
                      const Divider(height: 2),
                      Text("Date\n${DateFormat("dd-MM-yyyy").format(invoiceData.date)}"),
                      const Divider(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total\n${invoiceData.totalAmount}"),
                          Text("Tax\n${invoiceData.taxAmount}"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Stack(
                children: [
                  Hero(
                    tag: invoiceData.imagePath,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(File(
                          XFile(invoiceData.imagePath).path),
                        width: 144,
                        fit: BoxFit.cover,
                        frameBuilder: (final BuildContext context, final Widget child, final int? frame, final bool wasSynchronouslyLoaded) {
                          if (wasSynchronouslyLoaded) {
                            return child;
                          }
                          return AnimatedOpacity(
                            opacity: frame == null ? 0 : 1,
                            duration: const Duration(seconds: 1),
                            curve: Curves.easeOut,
                            child: child,
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(right: 0, bottom: 0,
                      child: AIButton(invoiceImage: File(invoiceData.imagePath))
                  ),
                  if (selectionState.isSelectionMode)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Checkbox(
                          onChanged: (final bool? x) => ref.read(invoiceProvider.notifier).toggleItemSelection(company: invoiceData.companyName, invoiceData: invoiceData),
                          value: selectionState.selectedItems[invoiceData.companyName]?.contains(invoiceData) ?? false,
                    ))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
