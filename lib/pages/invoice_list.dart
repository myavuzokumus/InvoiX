import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:invoix/models/invoice_data.dart';
import 'package:invoix/widgets/invoice_card.dart';

import '../main.dart';
import '../utils/company_name_filter.dart';
import '../widgets/toast.dart';

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
            child: RichText(textAlign: TextAlign.center, text: TextSpan(
                text: "InvoiX\n",
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                children: <TextSpan>[
                  TextSpan(
                      text: companyName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
                ])),
          ),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.table_chart),
              tooltip: "Export all data to Excel",
              onPressed: () => showSnackBar(context,
                  text: "Excel files are saved in " "Download" " file.",
                  color: Colors.green),
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
                invoiceDataBox.values.cast<InvoiceData>(), companyName),
            builder: (final BuildContext context,
                final AsyncSnapshot<List<InvoiceData>> invoice) {

              if (invoice.hasData) {

                final List<InvoiceData> invoiceList = invoice.data!;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10, top: 10),
                      child: FilledButton(
                        onPressed: () {},
                        child: Text(invoiceList.length.toString()),
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 15,
                        childAspectRatio: 2.60,
                      ),
                      itemCount: invoiceList.length,
                      itemBuilder: (final BuildContext context, final int index) {

                        return InvoiceCard(
                            invoiceData: invoiceList.elementAt(index),
                            index: invoiceDataBox.values.cast<InvoiceData>().toList().indexOf(invoiceList.elementAt(index))
                        );

                      },
                    ),
                  ],
                );
              } else {
                return const CircularProgressIndicator();
              }
            });
      },
    );
  }
}
