import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invoix/models/invoice_data.dart';
import 'package:invoix/pages/CompaniesPage/mode_selection.dart';
import 'package:invoix/pages/InvoiceEditPage/invoice_edit_page.dart';
import 'package:invoix/pages/InvoicesPage/ai_button.dart';
import 'package:invoix/pages/general_page_scaffold.dart';

class InvoiceCard extends StatefulWidget {
  const InvoiceCard({super.key, required this.invoiceData, required this.index});

  final int index;
  final InvoiceData invoiceData;

  @override
  State<InvoiceCard> createState() => _InvoiceCardState();
}

class _InvoiceCardState extends State<InvoiceCard> {

  final BorderRadius borderRadiusValue = BorderRadius.circular(16);

  @override
  Widget build(final BuildContext context) {
    final selectionData = SelectionData.of(context);
    final int index = widget.index;
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
          onLongPress: () {
            if (!selectionData.isSelectionMode) {
              setState(() {
                selectionData.selectedList[index] = true;
              });
              selectionData.onSelectionChange(true);
            }
          },
          onTap: () {
            selectionData.isSelectionMode
                ? selectionData.selectionToggle(index: index, invoiceData: widget.invoiceData)
                :
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (final context) =>
                        InvoiceEditPage(
                          imageFile: XFile(widget.invoiceData.ImagePath),
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
                      Text("Invoice No\n${widget.invoiceData.invoiceNo}"),
                      const Divider(height: 2),
                      Text("Date\n${DateFormat("dd-MM-yyyy").format(widget.invoiceData.date)}"),
                      const Divider(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total Amount\n${widget.invoiceData.totalAmount}"),
                          Text("Tax Amount\n${widget.invoiceData.taxAmount}"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Stack(
                children: [
                  Hero(
                    tag: widget.invoiceData.ImagePath,
                    child: ClipRRect(
                      borderRadius: borderRadiusValue,
                      child: Image.file(File(
                          XFile(widget.invoiceData.ImagePath).path),
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
                      child: AIButton(invoiceImage: File(widget.invoiceData.ImagePath))
                  ),
                  if (selectionData.isSelectionMode)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Checkbox(
                          onChanged: (final bool? x) {
                            selectionData.selectionToggle(index: index, invoiceData: widget.invoiceData);
                          },
                          value: selectionData.selectedList[index]),
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
