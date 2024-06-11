part of 'summary_main.dart';

mixin _SummaryMainMixin on State<SummaryMain> {

  final ValueNotifier<int> touchedIndexNotifier = ValueNotifier<int>(-1);

  late DateTimeRange initialDateTime;
  late List<InvoiceData> top5Invoices;
  late Future<Map<InvoiceCategory, double>> topCategoriesFuture;
  late DateTime startDate;
  late DateTime endDate;

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
    super.initState();
  }
// Calculate total amounts on filtered invoices and find the 5 invoice categories with the highest amounts
  Future<Map<InvoiceCategory, double>> calculateTopCategories(final DateTime startDate,
      final DateTime endDate) async {
    final List<InvoiceData> invoices = await InvoiceDataService().getInvoicesBetweenDates(
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

    final List<InvoiceData> sortedInvoices = invoices
      ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    top5Invoices = sortedInvoices.take(5).toList();

    return categoryTotals;
  }

  List<Widget> getIndicators(final Map<InvoiceCategory, double> categoryTotals) {
    // Toplam tutarı hesapla
    final double totalAmount = categoryTotals.values.reduce((final a, final b) => a + b);

    // Her bir kategori için bir Indicator widget'ı oluştur
    final List<Widget> indicators = [];
    categoryTotals.forEach((final category, final amount) {
      final double percentage = (amount / totalAmount) * 100;
      indicators.add(Indicator(
        color: category.color, // Burada her bir kategori için farklı bir renk belirleyebilirsiniz
        text: '${category.name}: ${percentage.toStringAsFixed(2)}%',
        isSquare: true,
      ));
    });

    // Yüzde oranına göre azalan sıralama için indicators listesini sırala
    indicators.sort((final a, final b) {
      final aPercentage = double.parse((a as Indicator).text.split(': ')[1].replaceAll('%', ''));
      final bPercentage = double.parse((b as Indicator).text.split(': ')[1].replaceAll('%', ''));
      return bPercentage.compareTo(aPercentage);
    });

    return indicators;
  }

}
