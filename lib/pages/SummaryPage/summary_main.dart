import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
        centerTitle: true,
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
                  this.startDate = startDate;
                  this.endDate = endDate;
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
            child: ValueListenableBuilder<Box>(
              valueListenable: invoiceDataBox.listenable(),
              builder: (final BuildContext context, final value, final Widget? child) {
                topCategoriesFuture =
                    calculateTopCategories(startDate, endDate);
                return FutureBuilder<Map<InvoiceCategory, double>>(
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
                                    topCategoriesFuture =
                                        calculateTopCategories(startDate, endDate);
                                  });
                                },
                                child: const Text('Retry'))
                          ],
                        ));
                      } else if (snapshot.hasData) {

                        final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
                        final bool shouldScroll = isLandscape || MediaQuery.of(context).size.height < 600; // Adjust the width as needed
                        return shouldScroll ? SingleChildScrollView(child: buildContent(context, isLandscape, snapshot.data!)) : buildContent(context, isLandscape, snapshot.data!);
                      }
                    }
                    return const LoadingAnimation();

                  });}
            ),
          ),
        ],
      ),
    );
  }

  Widget buildContent(final BuildContext context, final bool isLandscape, final Map<InvoiceCategory, double> categoryTotals) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 1.15,
      child: Column(
        children: <Widget>[
          chartSection(context, categoryTotals),
          const Divider(),
          Text("Top 5 Invoices", style: Theme.of(context).textTheme.titleLarge),
          const Divider(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.only(left: 20, right: 20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isLandscape ?
                2 : 1,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 2.60,
              ),
              itemCount: top5Invoices.length,
              itemBuilder: (final BuildContext context, final int index) {
                final invoiceData = top5Invoices.elementAt(index);
                return InvoiceCard(invoiceData: invoiceData, selectionMode: false);
              },
            ),
          ),
        ],
      ),
    );
  }

  Row chartSection(final BuildContext context, final Map<InvoiceCategory, double> categoryTotals) {
    return Row(
          children: [
            Flexible(
              child: AspectRatio(
                aspectRatio: MediaQuery.of(context).size.height < 600 ? 2 : 0.9,
                child: ValueListenableBuilder<double>(
                  valueListenable: touchedPercentageNotifier,
                  builder: (final BuildContext context, final double touchedIndex, final Widget? child) {
                    return PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (final FlTouchEvent event, final pieTouchResponse) {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null ||
                                pieTouchResponse.touchedSection!.touchedSection == null) {
                              touchedPercentageNotifier.value = -1;
                              return;
                            }
                            touchedPercentageNotifier.value = pieTouchResponse.touchedSection!.touchedSection!.value;
                          },
                        ),
                        centerSpaceRadius: MediaQuery.of(context).size.height * 0.025,
                        sections: showingSections(categoryTotals, touchedIndex),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 20),
            Flexible(
              child: Wrap(
                spacing: 12.0, // gap between adjacent chips
                runSpacing: 12.0, // gap between lines
                children: getIndicators(categoryTotals),
              ),
            ),
          ],
        );
  }

  List<PieChartSectionData> showingSections(
      final Map<InvoiceCategory, double> categoryTotals, final double touchedIndex) {
    // Calculate total amount
    final double totalAmount =
        categoryTotals.values.reduce((final a, final b) => a + b);

    // Create a PieChartSectionData object for each category
    final List<PieChartSectionData> sections = [];
    categoryTotals.forEach((final category, final amount) {
      final double percentage = (amount / totalAmount) * 100;

      final isTouched = percentage == touchedIndex;
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
