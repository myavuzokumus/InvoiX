import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invoix/models/invoice_data.dart';
import 'package:invoix/pages/invoice_edit.dart';
import 'package:invoix/widgets/ai_button.dart';

import '../widgets/loading_animation.dart';

class InvoiceCard extends StatelessWidget {
  const InvoiceCard({super.key, required this.invoiceData, required this.index});

  final InvoiceData invoiceData;
  final int index;

  @override
  Widget build(final BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (final context) =>
                      InvoiceCaptureScreen(
                        editIndex: index,
                        imageFile: XFile(invoiceData.ImagePath),
                      )));
        },
        splashColor: Colors.blue,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.only(left: 16),
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.3, 0.5, 0.7],
                colors: [ Color(0xFF846AFF), Color(0xFF755EE8), Color(0xFF846AFF)],
              ),
          ),// Adds a gradient background and rounded corners to the container
          child: Row(
            children: [
              Expanded(
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
                        Text("Total Amount\n${invoiceData.totalAmount}"),
                        Text("Tax Amount\n${invoiceData.taxAmount}"),
                      ],
                    ),
                  ],
                ),
              ),
              Stack(
                children: [
                  Hero(
                    tag: invoiceData.ImagePath,
                    child: Image.file(File(
                        XFile(invoiceData.ImagePath).path),
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
                  const Positioned(right: 0, bottom: 0,
                      child: AIButton()
                  )
                ],
              ), // Adds a price to the bottom of the card
            ],
          ),
        ),
      ),
    );
  }
}
