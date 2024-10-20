part of 'invoice_edit.dart';

mixin _InvoiceEditPageMixin on ConsumerState<InvoiceEditPage> {
  final ValueNotifier<bool> _saveButtonState = ValueNotifier(true);

  late bool _isFileSaved;

  late final XFile imageFile;
  late ReadMode? readMode;

  late CompanyType companySuffix = CompanyType.LTD;
  late InvoiceCategory invoiceCategory = InvoiceCategory.Others;
  late PriceUnit priceUnit = PriceUnit.EUR;

  //TextLabelControllers
  late final TextEditingController companyTextController;
  late final TextEditingController invoiceNoTextController;
  late final TextEditingController companyIdTextController;
  late final TextEditingController dateTextController;
  late final TextEditingController totalAmountTextController;
  late final TextEditingController taxAmountTextController;

  late final GlobalKey<ScaffoldState> _scaffoldKey;
  late final GlobalKey<FormState> _formKey;

  late Future<dynamic> _future;

  late final InvoiceDataService invoiceDataService;
  late final FirebaseService firebaseService;

  @override
  void initState() {
    invoiceDataService = ref.read(invoiceDataServiceProvider);
    firebaseService = ref.read(firebaseServiceProvider);

    _saveButtonState.value = true;
    _isFileSaved = false;

    imageFile = widget.imageFile;
    readMode = widget.readMode;

    companyTextController = TextEditingController();
    companyIdTextController = TextEditingController();
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
    companyIdTextController.dispose();
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
      showToast(text: context.l10n.message_blurChecker,
          color: Colors.redAccent);
    }
    await imageFilter(imageFile);

    if (readMode == ReadMode.legacy) {
      await fetchInvoiceData(
          outPut: parseInvoiceData(await getScannedText(imageFile)));
    } else if (readMode == ReadMode.ai) {
      try {
        await fetchInvoiceData(
            outPut: await firebaseService.describeImageWithAI(
                imgFile: File(imageFile.path), type: ProcessType.scan));
      } catch (e) {
        String error = e.toString();
        final status = await currentStatusChecker("aiInvoiceReads");

        error = status.name;

        ref.read(loadingProvider.notifier).state = ref
            .read(loadingProvider)
            .copyWith(message: "$error\n${context.l10n.error_switchingMode}");

        await Future.delayed(const Duration(seconds: 3));

        await fetchInvoiceData(
            outPut: parseInvoiceData(await getScannedText(imageFile)));
      }
    }
  }

  // Get Invoice Data from scanned text with Regex

  Future<void> fetchInvoiceData({final String? outPut}) async {
    final InvoiceData item;

    if (outPut == null) {
      item = invoiceDataService.getInvoiceData(widget.invoiceData!)!;
    } else {
      item = InvoiceData.fromJson(jsonDecode(outPut));
    }

    companySuffix = invoiceDataService.companyTypeFinder(item.companyName);
    invoiceCategory =
        InvoiceCategory.parse(item.category) ?? InvoiceCategory.Others;
    priceUnit =
        PriceUnit.parse(item.unit) ?? PriceUnit.Others;

    companyTextController.text =
        invoiceDataService.companyTypeExtractor(item.companyName);
    companyTextController.text = invoiceDataService
        .invalidCompanyTypeExtractor(companyTextController.text);


    companyIdTextController.text = item.companyId;
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

        final List<String> companyList =
            await invoiceDataService.getCompanyList();

        companyTextController.text =
            invoiceDataService.companyTypeExtractor(companyTextController.text);
        print("EDİT 1");
        print(companyTextController.text);

        companyTextController.text = invoiceDataService
            .invalidCompanyTypeExtractor(companyTextController.text);
        print("EDİT 2");
        print(companyTextController.text);


        companyTextController.text += " ${companySuffix.name}";
        print("EDİT 3");
        print(companyTextController.text);


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
                  title: Text(context.l10n.similarity_title,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(context.l10n.similarity_message,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        FilledButton(
                          onPressed: () {},
                          child: Text(companyTextController.text),
                        ),
                        const Text("↓",
                            style: TextStyle(
                                fontSize: 32, fontWeight: FontWeight.bold)),
                        FilledButton(
                          onPressed: () {},
                          child: Text(companyName),
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(context.l10n.button_cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(context.l10n.button_yes),
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
          showToast(text: context.l10n.loading_data, color: Colors.yellowAccent);
        }

        final data = InvoiceData(
            imagePath: imageFile.path,
            companyName: companyTextController.text,
            invoiceNo: invoiceNoTextController.text,
            date: dateFormat.parse(dateTextController.text),
            totalAmount: double.parse(totalAmountTextController.text),
            taxAmount: double.parse(taxAmountTextController.text),
            category: invoiceCategory.name,
            unit: priceUnit.name,
            companyId: companyIdTextController.text,
            id: widget.invoiceData?.id);

        await invoiceDataService.saveInvoiceData(data);

        _isFileSaved = true;

        if (mounted) {
          showToast(text: context.l10n.loading_success, color: Colors.greenAccent);
          Navigator.pop(context);
        }
      } catch (e) {
        showToast(text: "${context.l10n.status_somethingWentWrong}:\n$e", color: Colors.redAccent);
      } finally {
        setState(() {
          _saveButtonState.value = false;
        });
      }
    }
  }
}
