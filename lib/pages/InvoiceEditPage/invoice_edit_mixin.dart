part of 'invoice_edit.dart';

mixin _InvoiceEditPageMixin on ConsumerState<InvoiceEditPage> {
  final ValueNotifier<bool> _saveButtonState = ValueNotifier(true);

  late bool _isFileSaved;

  late final XFile imageFile;
  late ReadMode? readMode;

  late CompanyType companySuffix = CompanyType.LTD;
  late InvoiceCategory invoiceCategory = InvoiceCategory.Others;

  //TextLabelControllers
  late final TextEditingController companyTextController;
  late final TextEditingController invoiceNoTextController;
  late final TextEditingController dateTextController;
  late final TextEditingController totalAmountTextController;
  late final TextEditingController taxAmountTextController;

  late final GlobalKey<ScaffoldState> _scaffoldKey;
  late final GlobalKey<FormState> _formKey;

  late Future<dynamic> _future;

  @override
  void initState() {
    _saveButtonState.value = true;
    _isFileSaved = false;

    imageFile = widget.imageFile;
    readMode = widget.readMode;

    companyTextController = TextEditingController();
    invoiceNoTextController = TextEditingController();
    dateTextController = TextEditingController();
    totalAmountTextController = TextEditingController();
    taxAmountTextController = TextEditingController();

    _scaffoldKey = GlobalKey<ScaffoldState>();
    _formKey = GlobalKey<FormState>();

    _future = readMode != null ? analyzeNewData() : fetchInvoiceData();

    super.initState();
  }

  @override
  void dispose() {
    companyTextController.dispose();
    invoiceNoTextController.dispose();
    dateTextController.dispose();
    totalAmountTextController.dispose();
    _scaffoldKey.currentState?.dispose();
    _formKey.currentState?.dispose();

    if (!_isFileSaved && readMode != null) {
      File(imageFile.path).delete();
    }

    super.dispose();
  }

  Future<void> analyzeNewData() async {
    if (await blurDetection(imageFile.path, 10) && mounted) {
      Toast(context,
          text: "The image is not clear enough.\nIt may not be read properly.",
          color: Colors.redAccent);
    }
    await imageFilter(imageFile);

    if (readMode == ReadMode.legacy) {
      await fetchInvoiceData(
          outPut: parseInvoiceData(await getScannedText(imageFile)));
    } else if (readMode == ReadMode.ai) {
      try {
        await fetchInvoiceData(
            outPut: await GeminiAPI().describeImage(
                imgFile: File(imageFile.path), prompt: identifyInvoicePrompt));
      } catch (e) {
        String error = e.toString();
        if (!(await isInternetConnected())) {
          error = "No Internet Connection!";
        }

        ref.read(errorProvider).errorMessage =
            "$error\nSwitching to Legacy Mode...";
        await Future.delayed(const Duration(seconds: 2));

        await fetchInvoiceData(
            outPut: parseInvoiceData(await getScannedText(imageFile)));
      }
    }
  }

  // Get Invoice Data from scanned text with Regex

  Future<void> fetchInvoiceData({final String? outPut}) async {
    final InvoiceData item;
    final InvoiceDataService invoiceDataService = InvoiceDataService();

    if (outPut == null) {
      item = invoiceDataService.getInvoiceData(widget.invoiceData!)!;
    } else {
      item = InvoiceData.fromJson(jsonDecode(outPut));
    }

    companySuffix = invoiceDataService.companyTypeFinder(item.companyName);
    invoiceCategory =
        InvoiceCategory.parse(item.category) ?? InvoiceCategory.Others;
    companyTextController.text =
        invoiceDataService.companyTypeExtractor(item.companyName);
    companyTextController.text = invoiceDataService
        .invalidCompanyTypeExtractor(companyTextController.text);
    invoiceNoTextController.text = item.invoiceNo;
    dateTextController.text = updateYear(dateFormat.format(item.date));
    totalAmountTextController.text = item.totalAmount.toString();
    taxAmountTextController.text = item.taxAmount.toString();
  }

  Future<void> saveInvoice() async {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      try {
        _saveButtonState.value = true;

        // If the form is valid, display a snack bar. In the real world,
        // you'd often call a server or save the information in a database.

        final InvoiceDataService invoiceDataService = InvoiceDataService();

        final List<String> companyList =
            await invoiceDataService.getCompanyList();

        companyTextController.text =
            invoiceDataService.companyTypeExtractor(companyTextController.text);

        companyTextController.text = invoiceDataService
            .invalidCompanyTypeExtractor(companyTextController.text);

        companyTextController.text += " ${companySuffix.name}";

        if (readMode != null) {
          for (final companyName in companyList) {
            // If the company name is the same as the company name in the database, bypass to similarity check
            if (companyTextController.text == companyName) {
              break;
            }
            final double similarity =
                (companyTextController.text).similarityTo(companyName);

            if (similarity >= 0.4) {
              if (!mounted) {
                return;
              }
              await showDialog<bool>(
                barrierDismissible: false,
                context: context,
                builder: (final BuildContext context) => AlertDialog(
                  title: const Text(
                    'Similar Company Found!',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Do you want to merge with it?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        FilledButton(
                          onPressed: () {},
                          child: Text(companyTextController.text),
                        ),
                        const Text("↓", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                        FilledButton(
                          onPressed: () {},
                          child:
                              Text(companyName),
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Yes!'),
                    ),
                  ],
                ),
              ).then((final value) {
                if (value != null && value) {
                  setState(() {
                    companyTextController.text = companyName;
                  });
                }
              });
              break;
            }
          }
        }

        if (mounted) {
          Toast(context,
              text: "Processing Data...", color: Colors.yellowAccent);
        }

        final data = InvoiceData(
            imagePath: imageFile.path,
            companyName: companyTextController.text,
            invoiceNo: invoiceNoTextController.text,
            date: dateFormat.parse(dateTextController.text),
            totalAmount: double.parse(totalAmountTextController.text),
            taxAmount: double.parse(taxAmountTextController.text),
            category: invoiceCategory.name,
            id: widget.invoiceData?.id);

        await InvoiceDataService().saveInvoiceData(data);

        _isFileSaved = true;

        if (mounted) {
          Toast(context, text: "Data Processed!", color: Colors.greenAccent);
          Navigator.pop(context);
        }
      } catch (e) {
        Toast(context,
            text: "Something went wrong.\n$e", color: Colors.redAccent);
      } finally {
        setState(() {
          _saveButtonState.value = false;
        });
      }
    }
  }
}
