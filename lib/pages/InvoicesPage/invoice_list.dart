import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:invoix/models/invoice_data.dart';
import 'package:invoix/pages/InvoicesPage/invoice_card.dart';
import 'package:invoix/services/invoice_data_service.dart';
import 'package:invoix/states/invoice_data_state.dart';
import 'package:invoix/states/list_length_state.dart';
import 'package:invoix/widgets/amount_range_slider.dart';
import 'package:invoix/widgets/date_range_picker.dart';
import 'package:invoix/widgets/status/loading_animation.dart';

part 'invoice_list_mixin.dart';

class InvoiceList extends ConsumerStatefulWidget {
  const InvoiceList({super.key, required this.companyName});

  final String companyName;

  @override
  ConsumerState<InvoiceList> createState() => _InvoiceListState();
}

class _InvoiceListState extends ConsumerState<InvoiceList>
    with _InvoiceListMixin {

  ValueNotifier<bool> isExpanded = ValueNotifier(false);

  @override
  Widget build(final BuildContext context) {

    return Column(
      children: [

        const SizedBox(
          height: 10,
        ),
        Expanded(
          child: FutureBuilder<List<InvoiceData>>(
              future: filteredInvoicesFuture,
              builder: (final BuildContext context,
                      final AsyncSnapshot<List<InvoiceData>> invoice) =>
                  futureInvoiceList(invoice)),
        ),
      ],
    );
  }

  Widget filterPanel() {
    return ValueListenableBuilder(
        valueListenable: isExpanded,
        builder: (final BuildContext context, final value, final Widget? child) {
          return ExpansionPanelList(
              expandedHeaderPadding: EdgeInsets.zero,
              elevation: 4,
              expansionCallback: (final int index,  final bool isExpanded) {
                setState(() {
                  this.isExpanded.value = !value;
                });
              },
              children: [
                ExpansionPanel(
                  backgroundColor: Theme.of(context).colorScheme.onSecondary,
                  isExpanded: value,
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 48),
                      child: Column(
                        children: [
                          CustomDateRangePicker(
                            initialTimeRange: initialDateTime,
                            onDateRangeChanged: (final DateTime startDate,
                                final DateTime endDate) {
                              setState(() {
                                this.startDate = startDate;
                                this.endDate = endDate;
                                initialDateTime = DateTimeRange(
                                  start: startDate,
                                  end: endDate,
                                );
                                originalInvoicesFuture =
                                    retrieveInvoicesAccordingDate(
                                        startDate, endDate, widget.companyName);
                                filteredInvoicesFuture = originalInvoicesFuture;
                              });
                            },
                          ),
                          const Divider(
                            height: 32,
                            color: Colors.white,
                            thickness: 1,
                          ),
                          AmountRangeSlider(
                            minAmount: minAmount,
                            maxAmount: maxAmount,
                            onAmountRangeChanged:
                                (final double minAmount, final double maxAmount) {
                              setState(() {
                                filteredInvoicesFuture = originalInvoicesFuture
                                    .then((final List<InvoiceData> invoices) =>
                                    invoices.where((final invoice) {
                                      return (invoice.totalAmount >=
                                          minAmount &&
                                          invoice.totalAmount <= maxAmount);
                                    }).toList());
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  headerBuilder:
                      (final BuildContext context, final bool isExpanded) {
                    return Center(child: Text(value ? 'Filtreleri Gizle' : 'Filtreleri Göster', style: Theme.of(context).textTheme.bodyLarge));
                  },
                ),
              ]);}
    );
  }

  Widget futureInvoiceList(final AsyncSnapshot<List<InvoiceData>> invoice) {
    if (invoice.connectionState == ConnectionState.done && invoice.hasData) {
      final List<InvoiceData> invoiceList = invoice.data!;

      Future(() {
        ref
            .read(invoicelistLengthProvider.notifier)
            .updateLength(invoiceList.length);
      });

      if (invoiceList.isEmpty) {
        return const Center(
          child: Text('No invoices found.'),
        );
      }

      return GridView.builder(
        padding: const EdgeInsets.only(left: 20, right: 20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:
              MediaQuery.of(context).orientation == Orientation.landscape
                  ? 2
                  : 1,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: 3.25,
        ),
        itemCount: invoiceList.length,
        itemBuilder: (final BuildContext context, final int index) {
          final InvoiceData invoiceData = invoiceList.elementAt(index);
          return ValueListenableBuilder<Box>(
            valueListenable: invoiceDataService.invoiceDataBox.listenable(),
            builder: (final BuildContext context, final Box<dynamic> value,
                final Widget? child) {
              final newInvoiceData = value.get(invoiceData.id);
              if (newInvoiceData == null ||
                  !invoiceDataService.isSameInvoice(
                      invoiceData, newInvoiceData)) {
                WidgetsBinding.instance.addPostFrameCallback((final _) {
                  setState(() {
                    originalInvoicesFuture = retrieveInvoicesAccordingDate(
                        startDate, endDate, widget.companyName);
                    filteredInvoicesFuture = originalInvoicesFuture;
                  });
                });
              }

              // If newInvoiceData is null, use the original invoiceData
              final displayInvoiceData = newInvoiceData ?? invoiceData;
              return InvoiceCard(invoiceData: displayInvoiceData);
            },
          );
        },
      );
    }
    return const LoadingAnimation();
  }
}