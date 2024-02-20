import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:invoix/models/invoice_data.dart';
import 'package:invoix/pages/InvoicesPage/invoice_card.dart';
import 'package:invoix/pages/SelectionState.dart';
import 'package:invoix/utils/invoice_data_service.dart';
import 'package:invoix/widgets/loading_animation.dart';

class InvoiceList extends ConsumerWidget {
  const InvoiceList({super.key, required this.companyName});

  final String companyName;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {

    return ValueListenableBuilder<Box>(
      valueListenable: invoiceDataBox.listenable(),
      builder: (final BuildContext context, final Box<dynamic> value,
          final Widget? child) {
        return FutureBuilder<List<InvoiceData>>(
            future: InvoiceDataService().getInvoiceList(companyName),
            builder: (final BuildContext context,
                final AsyncSnapshot<List<InvoiceData>> invoice) {

              if (invoice.hasData) {

                final List<InvoiceData> invoiceList = List.from(invoice.data!);
                ref.read(invoiceSelectionProvider).listLength = invoiceList.length;

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
                              invoiceData: invoiceData, index: index
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
