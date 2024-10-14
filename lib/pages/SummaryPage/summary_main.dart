import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:invoix/models/invoice_data.dart';
import 'package:invoix/pages/CompaniesPage/invox_ai_card.dart';
import 'package:invoix/pages/InvoicesPage/invoice_card.dart';
import 'package:invoix/pages/SummaryPage/indicator.dart';
import 'package:invoix/services/invoice_data_service.dart';
import 'package:invoix/states/invoice_data_state.dart';
import 'package:invoix/widgets/date_range_picker.dart';
import 'package:invoix/widgets/filter_panel.dart';
import 'package:invoix/widgets/status/loading_animation.dart';

part 'summary_main_mixin.dart';

class SummaryMain extends ConsumerStatefulWidget {
  const SummaryMain({super.key});

  @override
  ConsumerState<SummaryMain> createState() => _SummaryMainState();
}

class _SummaryMainState extends ConsumerState<SummaryMain>
    with _SummaryMainMixin, AutomaticKeepAliveClientMixin {
  @override
  Widget build(final BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
        actions: [
          ValueListenableBuilder(
            valueListenable: filterPanelVisibleNotifier,
            builder: (final BuildContext context, final value, final Widget? child) {
              return IconButton(
                icon: const Icon(Icons.filter_list),
                color: value
                    ? Theme.of(context).colorScheme.primary
                    : null,
                onPressed: () {
                  filterPanelVisibleNotifier.value =
                  !filterPanelVisibleNotifier.value;
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: filterPanelVisibleNotifier,
            builder: (final BuildContext context, value, final Widget? child) {
              return FilterPanel(
                isExpanded: value,
                onToggle: () {
                  setState(() {
                    value = !value;
                  });
                },
                children: [
                  CustomDateRangePicker(
                    initialTimeRange: initialDateTime,
                    onDateRangeChanged:
                        (final DateTime startDate, final DateTime endDate) {
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
                  DropdownButtonFormField<PriceUnit>(
                    value: priceUnit,
                    alignment: Alignment.centerRight,
                    menuMaxHeight: 225,
                    hint: const Text("Unit"),
                    iconSize: 0,
                    items: PriceUnit.values.map((final PriceUnit value) {
                      return DropdownMenuItem<PriceUnit>(
                        value: value,
                        child: Text(value.name),
                      );
                    }).toList(),
                    onChanged: (final PriceUnit? value) {
                      setState(() {
                        priceUnit = value ?? PriceUnit.Others;
                        topCategoriesFuture =
                            calculateTopCategories(startDate, endDate);
                      });
                    },
                  ),
                ],
              );
            },
          ),
          Expanded(
            child: ValueListenableBuilder<Box>(
                valueListenable: invoiceDataService.invoiceDataBox.listenable(),
                builder: (final BuildContext context, final value,
                    final Widget? child) {
                  topCategoriesFuture =
                      calculateTopCategories(startDate, endDate);
                  return FutureBuilder<Map<InvoiceCategory, double>>(
                      future: topCategoriesFuture,
                      builder: (final BuildContext context,
                          final AsyncSnapshot<Map<InvoiceCategory, double>>
                              snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasError || snapshot.data!.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InvoixAICard(
                                    onPressed: () {
                                      setState(() {
                                        topCategoriesFuture =
                                            calculateTopCategories(
                                                startDate, endDate);
                                      });
                                    },
                                    children: const <Widget>[
                                      Text(
                                          "Invoice data couldn't be found.\n"
                                          "\nTry to change filter settings.",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          } else if (snapshot.hasData) {
                            final bool isLandscape =
                                MediaQuery.of(context).orientation ==
                                    Orientation.landscape;
                            final bool shouldScroll = isLandscape ||
                                MediaQuery.of(context).size.height <
                                    600; // Adjust the width as needed
                            return shouldScroll
                                ? SingleChildScrollView(
                                    child: buildContent(
                                        context, isLandscape, snapshot.data!))
                                : buildContent(
                                    context, isLandscape, snapshot.data!);
                          }
                        }
                        return const LoadingAnimation();
                      });
                }),
          ),
        ],
      ),
    );
  }

  Widget buildContent(final BuildContext context, final bool isLandscape,
      final Map<InvoiceCategory, double> categoryTotals) {
    return StatefulBuilder(builder: (final BuildContext context,
        final void Function(void Function()) setModalState) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 1.15,
        child: Column(
          children: <Widget>[
            chartSection(context, categoryTotals),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text("Top 5 Invoices",
                        style: Theme.of(context).textTheme.titleLarge),
                  ),
                  sortType(setModalState),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(left: 20, right: 20),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isLandscape ? 2 : 1,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  childAspectRatio: 2.60,
                ),
                itemCount: selected5Invoices.take(5).toList().length,
                itemBuilder: (final BuildContext context, final int index) {
                  final invoiceData =
                      selected5Invoices.take(5).toList().elementAt(index);
                  return InvoiceCard(
                      invoiceData: invoiceData, selectionMode: false);
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Row chartSection(final BuildContext context,
      final Map<InvoiceCategory, double> categoryTotals) {
    return Row(
      children: [
        Flexible(
          child: AspectRatio(
            aspectRatio: MediaQuery.of(context).size.height < 600 ? 2 : 0.9,
            child: ValueListenableBuilder<double>(
              valueListenable: touchedPercentageNotifier,
              builder: (final BuildContext context, final double touchedIndex,
                  final Widget? child) {
                return PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback:
                          (final FlTouchEvent event, final pieTouchResponse) {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null ||
                            pieTouchResponse.touchedSection!.touchedSection ==
                                null) {
                          touchedPercentageNotifier.value = -1;
                          return;
                        }
                        touchedPercentageNotifier.value = pieTouchResponse
                            .touchedSection!.touchedSection!.value;
                      },
                    ),
                    centerSpaceRadius:
                        MediaQuery.of(context).size.height * 0.025,
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
      final Map<InvoiceCategory, double> categoryTotals,
      final double touchedIndex) {
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

  Widget sortType(final void Function(void Function() p1) setModalState) {
    return SegmentedButton<SortType>(
      showSelectedIcon: false,
      segments: const <ButtonSegment<SortType>>[
        ButtonSegment<SortType>(
          value: SortType.amount,
          label: Text('Amount'),
        ),
        ButtonSegment<SortType>(
          value: SortType.date,
          label: Text('Date'),
        ),
      ],
      selected: _selection,
      onSelectionChanged: (final Set<SortType> newSelection) {
        setModalState(() {
          _selection = newSelection;
        });
        switch (_selection.first) {
          case SortType.amount:
            selectedInvoices.sort(
                (final a, final b) => b.totalAmount.compareTo(a.totalAmount));
            break;
          case SortType.date:
            selectedInvoices
                .sort((final a, final b) => b.date.compareTo(a.date));
            break;
        }

        selected5Invoices = selectedInvoices.take(5).toList();
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
