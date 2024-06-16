part of 'invoice_list.dart';

mixin _InvoiceListMixin on State<InvoiceList>{

  late Future<List<InvoiceData>> originalInvoicesFuture;
  late Future<List<InvoiceData>> filteredInvoicesFuture;

  DateTimeRange? initialDateTime;
  late DateTime startDate;
  late DateTime endDate;
  late final InvoiceDataService invoiceDataService;

  double minAmount = 0;
  double maxAmount = 0;

  @override
  void initState() {
    invoiceDataService = InvoiceDataService();

    endDate = DateTime.now();
    startDate = DateTime(0000);

    originalInvoicesFuture =
        retrieveInvoicesAccordingDate(startDate, endDate, widget.companyName);

    filteredInvoicesFuture = originalInvoicesFuture;

    super.initState();
  }

  Future<List<InvoiceData>> retrieveInvoicesAccordingDate(
      final DateTime startDate,
      final DateTime endDate,
      final String companyName) async {
    final List<InvoiceData> invoices = (await InvoiceDataService()
        .getInvoicesBetweenDates(startDate, endDate))
        .where((final invoice) => invoice.companyName == companyName)
        .toList();

    calculateMinMaxAmounts(invoices);

    return invoices;
  }

  void calculateMinMaxAmounts(final List<InvoiceData> invoices) {

    if (invoices.isEmpty) {
      return;
    }

    minAmount = invoices[0].totalAmount;
    maxAmount = invoices[0].totalAmount;
    for (final invoice in invoices) {
      final double totalAmount = invoice.totalAmount;
      if (totalAmount < minAmount) {
        minAmount = totalAmount;
      }
      if (totalAmount > maxAmount) {
        maxAmount = totalAmount;
      }
    }
    setState(() {});

  }

}
