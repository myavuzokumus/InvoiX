import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:invoix/models/invoice_data.dart';
import 'package:invoix/pages/InvoicesPage/invoice_card.dart';
import 'package:invoix/pages/SummaryPage/indicator.dart';
import 'package:invoix/utils/invoice_data_service.dart';
import 'package:invoix/widgets/date_range_picker.dart';
import 'package:invoix/widgets/loading_animation.dart';

part 'summary_main_mixin.dart';

class SummaryMain extends StatefulWidget {
  const SummaryMain({super.key});

  @override
  State<SummaryMain> createState() => _SummaryMainState();
}

class _SummaryMainState extends State<SummaryMain> with _SummaryMainMixin {
  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: 32, right: 32, top: 16),
            child: CustomDateRangePicker(
              initialTimeRange: initialDateTime,
              onDateRangeChanged: (final DateTime startDate,
                  final DateTime endDate) {
                setState(() {
                  initialDateTime = DateTimeRange(
                    start: startDate,
                    end: endDate,
                  );
                  topCategoriesFuture =
                      calculateTopCategories(startDate, endDate);
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<Map<InvoiceCategory, double>>(
                future: topCategoriesFuture,
                builder: (final BuildContext context,
                    final AsyncSnapshot<Map<InvoiceCategory, double>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError || snapshot.data!.isEmpty) {
                      return Center(
                          child: Column(
                        children: [
                          const Text("Invoice data couldn't be found."),
                          ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  topCategoriesFuture = calculateTopCategories(
                                      DateTime.now()
                                          .subtract(const Duration(days: 30)),
                                      DateTime.now());
                                });
                              },
                              child: const Text('Retry'))
                        ],
                      ));
                    } else if (snapshot.hasData) {
                      return Column(
                        children: <Widget>[
                          AspectRatio(
                            aspectRatio: 1.6,
                            child: PieChart(
                              PieChartData(
                                pieTouchData: PieTouchData(
                                  touchCallback: (final FlTouchEvent event,
                                      final pieTouchResponse) {
                                    setState(() {
                                      if (!event.isInterestedForInteractions ||
                                          pieTouchResponse == null ||
                                          pieTouchResponse.touchedSection == null) {
                                        touchedIndex = -1;
                                        return;
                                      }
                                      touchedIndex = pieTouchResponse
                                          .touchedSection!.touchedSectionIndex;
                                    });
                                  },
                                ),
                                centerSpaceRadius: 40,
                                sections: showingSections(snapshot.data!),
                              ),
                            ),
                          ),
                          Wrap(
                              spacing: 8.0, // gap between adjacent chips
                              runSpacing: 4.0, // gap between lines
                              children: getIndicators(snapshot.data!)),
                          const Divider(),
                          Text("Top 5 Invoices",
                              style: Theme.of(context).textTheme.titleLarge),
                          const Divider(),
                          Expanded(
                            child: GridView.builder(
                              padding: const EdgeInsets.only(left: 20, right: 20),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: MediaQuery.of(context).orientation ==
                                        Orientation.landscape
                                    ? 2
                                    : 1,
                                mainAxisSpacing: 15,
                                crossAxisSpacing: 15,
                                childAspectRatio: 2.60,
                              ),
                              itemCount: top5Invoices.length,
                              itemBuilder:
                                  (final BuildContext context, final int index) {
                                final invoiceData = top5Invoices.elementAt(index);
            
                                return InvoiceCard(invoiceData: invoiceData);
                              },
                            ),
                          ),
                        ],
                      );
                    }
                  }
                  return const LoadingAnimation();

                }),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections(
      final Map<InvoiceCategory, double> categoryTotals) {
    // Calculate total amount
    final double totalAmount =
        categoryTotals.values.reduce((final a, final b) => a + b);

    // Create a PieChartSectionData object for each category
    final List<PieChartSectionData> sections = [];
    categoryTotals.forEach((final category, final amount) {
      final double percentage = (amount / totalAmount) * 100;
      final isTouched = category.index == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      sections.add(PieChartSectionData(
        color: category.color,
        value: percentage,
        title: "${percentage.toStringAsFixed(2)}%",
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      ));
    });

    return sections;
  }
}
