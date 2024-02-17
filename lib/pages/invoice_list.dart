import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:invoix/models/invoice_data.dart';
import 'package:invoix/utils/invoice_data_service.dart';
import 'package:invoix/utils/export_to_excel.dart';
import 'package:invoix/widgets/invoice_card.dart';
import 'package:invoix/widgets/loading_animation.dart';

import '../main.dart';
import '../widgets/toast.dart';

class InvoicePage extends StatefulWidget {
  const InvoicePage({super.key, required this.companyName});

  final String companyName;

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {

  late bool _excelExporting;
  late final String companyName;

  @override
  initState() {

    _excelExporting = false;
    companyName = widget.companyName;

    super.initState();
  }

  @override
  Widget build(final BuildContext context) {

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
              icon: _excelExporting ? const CircularProgressIndicator() : const Icon(Icons.table_chart),
              tooltip: "Export all data to Excel",
              onPressed: _excelExporting ? null : () {
                setState(() {
                  _excelExporting = true;
                });

                exportToExcel(companyName: companyName, listType: ListType.invoice)
                  ..catchError((final Object e) => toast(context,
                      text: e.toString(), color: Colors.redAccent))
                  ..then((final _) => toast(context,
                      text: "$companyName's invoices excel output is saved in the ""Download"" file.",
                      color: Colors.green))
                  ..whenComplete(() => setState(() {
                    _excelExporting = false;
                  }));
              },
            ),
            IconButton(onPressed: () {
              toast(context,
                  text: "Company deletion very soon!",
                  color: Colors.redAccent);
            }, icon: const Icon(Icons.restore_from_trash_outlined))
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
            future: InvoiceDataService.getInvoiceList(companyName),
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
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: MediaQuery.of(context).orientation == Orientation.landscape ? 2 : 1,
                          mainAxisSpacing: 15,
                          crossAxisSpacing: 15,
                          childAspectRatio: 2.60,
                        ),
                        itemCount: invoiceList.length,
                        itemBuilder: (final BuildContext context, final int index) {

                          final invoiceData = invoiceList.elementAt(index);

                          return InvoiceCard(
                              invoiceData: invoiceData
                          );
                        },
                      ),
                    ),
                  ],
                );
              } else {
                return const LoadingAnimation();
              }
            });
      },
    );
  }
}
