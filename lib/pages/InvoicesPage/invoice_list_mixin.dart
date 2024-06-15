part of 'invoice_list.dart';

mixin _InvoiceListMixin on State<InvoiceList>{

  late Future<List<InvoiceData>> invoicesFuture;
  DateTimeRange? initialDateTime;
  late DateTime startDate;
  late DateTime endDate;
  late final InvoiceDataService invoiceDataService;
  double minAmount = double.infinity;
  double maxAmount = double.negativeInfinity;

  @override
  void initState() {
    invoiceDataService = InvoiceDataService();

    endDate = DateTime.now();
    startDate = DateTime(1900);

    invoicesFuture =
        retrieveInvoicesAccordingDate(startDate, endDate, widget.companyName);

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

    for (final invoice in invoices) {
      final double totalAmount = invoice.totalAmount;
      if (totalAmount < minAmount) {
        minAmount = totalAmount;
      }
      if (totalAmount > maxAmount) {
        maxAmount = totalAmount;
      }
    }
  }

  //This method is used to check if the invoice list is empty or not. If yes, then page will be pop.
  List<InvoiceData> invoiceListChecker(
      final AsyncSnapshot<List<InvoiceData>> invoice) {
    final List<InvoiceData> invoiceList = List.from(invoice.data!);

    if (invoiceList.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((final _) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    }
    return invoiceList;
  }

}
