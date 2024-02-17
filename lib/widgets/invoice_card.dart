import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invoix/models/invoice_data.dart';
import 'package:invoix/pages/company_list.dart';
import 'package:invoix/pages/invoice_edit.dart';
import 'package:invoix/widgets/ai_button.dart';

class InvoiceCard extends StatelessWidget {
  InvoiceCard({super.key, required this.invoiceData});

  final InvoiceData invoiceData;
  final BorderRadius borderRadiusValue = BorderRadius.circular(16);

  @override
  Widget build(final BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadiusValue,
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
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (final context) =>
                        InvoiceCaptureScreen(
                          imageFile: XFile(invoiceData.ImagePath),
                          readMode: ReadMode.legacy,
                        )));
          },
          splashColor: Colors.blue,
          borderRadius: borderRadiusValue,
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
                          Text("Total Amount\n${invoiceData.totalAmount}"),
                          Text("Tax Amount\n${invoiceData.taxAmount}"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Stack(
                children: [
                  Hero(
                    tag: invoiceData.ImagePath,
                    child: ClipRRect(
                      borderRadius: borderRadiusValue,
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
                  ),
                  Positioned(right: 0, bottom: 0,
                      child: AIButton(invoiceImage: File(invoiceData.ImagePath))
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
