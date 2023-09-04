import 'package:fastinvoicereader/Models/invoice_data.dart';
import 'package:flutter/material.dart';

import '../company_name_filter.dart';
import '../main.dart';

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
        future: getInvoiceDataList(listType.company ,invoiceDataBox.cast<InvoiceData>()),
        builder: (final BuildContext context, final AsyncSnapshot<List<InvoiceData>> invoice) {

          if (invoice.hasData) {
            return GridView.builder(
            // Create a grid with 2 columns. If you change the scrollDirection to
            // horizontal, this produces 2 rows.

            padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
            // Generate 100 widgets that display their index in the List.
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 0.60,
            ),
            itemCount: invoice.data!.length,
            itemBuilder: (final BuildContext context, final int index) {

              final invoiceData = invoice.data!.elementAt(index);

              return ClipRRect(
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
                            child: Image.memory(invoiceData.invoiceImageData),
                          ),
                        ),
                        Text(
                          "No: ${invoiceData.invoiceNo}"
                          "Date: ${invoiceData.date}"
                          "Amount: ${invoiceData.amount}",
                          style: Theme
                              .of(context)
                              .textTheme
                              .headlineSmall,
                        ),
                      ],
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
