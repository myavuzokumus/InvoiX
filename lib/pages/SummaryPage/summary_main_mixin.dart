part of 'summary_main.dart';

mixin _SummaryMainMixin on ConsumerState<SummaryMain> {

  final ValueNotifier<double> touchedPercentageNotifier = ValueNotifier<double>(-1);

  late DateTimeRange initialDateTime;
  late List<InvoiceData> selectedInvoices;
  late List<InvoiceData> selected5Invoices;
  late Future<Map<InvoiceCategory, double>> topCategoriesFuture;
  late DateTime startDate;
  late DateTime endDate;

  late final InvoiceDataService invoiceDataService;
  Set<SortType> _selection = {SortType.amount};

  @override
  void initState() {
    final DateTime today = DateTime.now();
    initialDateTime = DateTimeRange(
      start: today.subtract(const Duration(days: 30)),
      end: today,
    );
    startDate = DateTime(1900);
    endDate = today;
    topCategoriesFuture = calculateTopCategories(today.subtract(const Duration(days: 30)), today);

    invoiceDataService = ref.read(invoiceDataServiceProvider);

    super.initState();
  }

  // Calculate total amounts on filtered invoices and find the 5 invoice categories with the highest amounts
  Future<Map<InvoiceCategory, double>> calculateTopCategories(final DateTime startDate,
      final DateTime endDate) async {

    final invoiceDataService = ref.read(invoiceDataServiceProvider);

    final List<InvoiceData> invoices = await invoiceDataService.getInvoicesBetweenDates(
        startDate, endDate);

    final Map<InvoiceCategory, double> categoryTotals = {};
    for (final invoice in invoices) {
      final InvoiceCategory category = InvoiceCategory.values.firstWhere((final InvoiceCategory e) => e.name.contains(invoice.category));
      if (!categoryTotals.containsKey(category)) {
        categoryTotals[category] = invoice.totalAmount;
      }
      else {
        categoryTotals[category] =
            categoryTotals[category]! + invoice.totalAmount;
      }
    }

    selectedInvoices = invoices;

    final List<InvoiceData> sortedInvoices;
    switch (_selection.first) {
      case SortType.amount:
        sortedInvoices = selectedInvoices..sort((final a, final b) => b.totalAmount.compareTo(a.totalAmount));
        break;
      case SortType.date:
        sortedInvoices = selectedInvoices..sort((final a, final b) => b.date.compareTo(a.date));
        break;
    }

    selected5Invoices = sortedInvoices.take(5).toList();

    return categoryTotals;
  }


  List<Widget> getIndicators(final Map<InvoiceCategory, double> categoryTotals) {

    // Calculate total amount
    //final double totalAmount = categoryTotals.values.reduce((final a, final b) => a + b);

    // Create indicator for each category
    final List<Widget> indicators = [];
    categoryTotals.forEach((final category, final amount) {
      //final double percentage = (amount / totalAmount) * 100;
      indicators.add(Indicator(
        color: category.color,
        text: '${category.name}: ${amount.toStringAsFixed(2)}',
        isSquare: true,
      ));
    });

    // Sort the list of indicators for descending sorting by percentage
    indicators.sort((final a, final b) {
      final aPercentage = double.parse((a as Indicator).text.split(': ')[1].replaceAll('%', ''));
      final bPercentage = double.parse((b as Indicator).text.split(': ')[1].replaceAll('%', ''));
      return bPercentage.compareTo(aPercentage);
    });

    return indicators;
  }

}

enum SortType { amount, date }