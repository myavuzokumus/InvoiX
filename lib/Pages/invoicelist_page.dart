import 'dart:io';

import 'package:fastinvoicereader/Models/invoice_data.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../company_name_filter.dart';
import '../main.dart';
import 'captured_page.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key, required this.companyName});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String companyName;

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {

  @override
  Widget build(final BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
          title: Text(widget.companyName),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.table_chart),
              tooltip: 'Tüm verileri indir',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(
                        'Dosyalar "Download" klasörüne kaydedildi.')));
              },
            ),
          ]
      ),
      body: FutureBuilder<List<InvoiceData>>(
        future: getInvoiceDataList(listType.invoice, invoiceDataBox.cast<InvoiceData>(), widget.companyName),
        builder: (final BuildContext context, final AsyncSnapshot<List<InvoiceData>> invoice) {

          if (invoice.hasData) {
            return GridView.builder(
            // Create a grid with 2 columns. If you change the scrollDirection to
            // horizontal, this produces 2 rows.
            // Generate 100 widgets that display their index in the List.
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                    print(index);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (final context) =>
                                InvoiceCaptureScreen(
                                  editIndex: index,
                                  imageFile: XFile(invoiceData.ImagePath),
                                )
                        )
                    );
                  },
                  child: ListTile(
                  title: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Container(
                      color: Colors.grey,
                      child: Center(
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.all(15),
                                color: Colors.blueGrey,
                                child: Image.file(File(XFile(invoiceData.ImagePath).path)),
                              ),
                            ),
                            ListView(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: <Widget>[
                                ListTile(
                                  title: const Text("Invoice No:", style: TextStyle(fontSize: 20)),
                                  trailing: Text(invoiceData.invoiceNo, style: const TextStyle(fontSize: 16)),
                                ),
                                ListTile(
                                  title: const Text("Date:", style: TextStyle(fontSize: 20)),
                                  trailing: Text(invoiceData.date.toLocal().toString().replaceAll("00:00:00.000", ""), style: const TextStyle(fontSize: 16)),
                                ),
                                ListTile(
                                  title: const Text("Amount:", style: TextStyle(fontSize: 20)),
                                  trailing: Text(invoiceData.amount.toString(), style: const TextStyle(fontSize: 16)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },

          );
          }
          else {
            return const CircularProgressIndicator();
          }

        }
      ),
    );
  }
}
