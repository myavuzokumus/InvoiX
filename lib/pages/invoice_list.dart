import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../main.dart';
import '../models/invoice_data.dart';
import '../utils/company_name_filter.dart';
import '../widgets/toast.dart';
import 'invoice_edit.dart';

class InvoicePage extends StatefulWidget {
  const InvoicePage({super.key, required this.companyName});

  final String companyName;

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {

  @override
  Widget build(final BuildContext context) {

    final String companyName = widget.companyName;

    return Scaffold(
      appBar: AppBar(
          title: Hero(
            tag: "InvoiX",
            child: RichText(text: TextSpan(
                text: "InvoiX\n",
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                children: <TextSpan>[
                  TextSpan(
                      text: companyName,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal))
                ])),
          ),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.table_chart),
              tooltip: 'Export all data to Excel',
              onPressed: () => showSnackBar(context,
                  text: "Files are saved in " "Download" " file."),
            ),
          ]),
      body: InvoiceList(companyName: companyName),
    );
  }
}

class InvoiceList extends StatelessWidget {
  const InvoiceList({super.key, required this.companyName});

  final String companyName;

  @override
  Widget build(final BuildContext context) {
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box('InvoiceData').listenable(),
      builder: (final BuildContext context, final Box<dynamic> value,
          final Widget? child) {
        return FutureBuilder<List<InvoiceData>>(
            future: getInvoiceDataList(ListType.invoice,
                invoiceDataBox.cast<InvoiceData>(), companyName),
            builder: (final BuildContext context,
                final AsyncSnapshot<List<InvoiceData>> invoice) {
              if (invoice.hasData) {
                return GridView.builder(
                  // Create a grid with 2 columns. If you change the scrollDirection to
                  // horizontal, this produces 2 rows.
                  // Generate 100 widgets that display their index in the List.
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: invoice.data!.length,
                  itemBuilder: (final BuildContext context, final int index) {
                    final invoiceData = invoice.data!.elementAt(index);

                    return InkWell(
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
                      child: ListTile(
                        title: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Container(
                            color: Colors.grey,
                            child: Center(
                              child: Column(
                                children: [
                                  Flexible(
                                    child: Container(
                                      margin: const EdgeInsets.all(15),
                                      color: Colors.blueGrey,
                                      child: Image.file(File(
                                          XFile(invoiceData.ImagePath).path)),
                                    ),
                                  ),
                                  ListView(
                                    shrinkWrap: true,
                                    children: <Widget>[
                                      ListTile(
                                        visualDensity:
                                        const VisualDensity(vertical: -4),
                                        title: const Text("Invoice No:",
                                            style: TextStyle(fontSize: 20)),
                                        trailing: Text(invoiceData.invoiceNo,
                                            style: const TextStyle(
                                                fontSize: 16)),
                                      ),
                                      ListTile(
                                        visualDensity:
                                        const VisualDensity(vertical: -4),
                                        title: const Text("Date:",
                                            style: TextStyle(fontSize: 20)),
                                        trailing: Text(
                                            DateFormat("dd-MM-yyyy")
                                                .format(invoiceData.date),
                                            style: const TextStyle(
                                                fontSize: 16)),
                                      ),
                                      ListTile(
                                        visualDensity:
                                        const VisualDensity(vertical: -4),
                                        title: const Text("Amount:",
                                            style: TextStyle(fontSize: 20)),
                                        trailing: Text(
                                            invoiceData.amount.toString(),
                                            style: const TextStyle(
                                                fontSize: 16)),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else {
                return const CircularProgressIndicator();
              }
            });
      },
    );
  }
}
