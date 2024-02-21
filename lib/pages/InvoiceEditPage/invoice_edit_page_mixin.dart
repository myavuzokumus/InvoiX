part of 'invoice_edit_page.dart';

mixin _InvoiceEditPageMixin on State<InvoiceEditPage> {

  late bool _saveButtonState;
  late bool _isFileSaved;

  late final XFile imageFile;
  late ReadMode? readMode;

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

    _saveButtonState = true;
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

    _future = readMode != null ? collectReadData() : fetchInvoiceData();

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

  Future<void> collectReadData() async {

    if( readMode == ReadMode.legacy) {
      await imageFilter(imageFile);
      getInvoiceData(await getScannedText(imageFile));
      await Future.delayed(const Duration(seconds: 2));
    }
    else if ( readMode == ReadMode.ai) {
      try {
        await imageFilter(imageFile);
        await fetchInvoiceData(await GeminiAPI().describeImage(imgFile: File(imageFile.path), prompt: identifyInvoicePrompt));
      } catch (e) {
        if (await isInternetConnected()) {
          print(e);
          Toast(context,
              text: "Something went wrong.\n"
                  "$e\n"
                  "Switching to Legacy Mode...",
              color: Colors.redAccent);
        } else {
          Toast(context,
              text: "No Internet Connection\n"
                  "Switching to Legacy Mode...",
              color: Colors.redAccent);
        }
        readMode = ReadMode.legacy;
        _future = collectReadData();
      }
    }

  }

  // Get Invoice Data from scanned text with Regex
  void getInvoiceData(final List listText) {
    companyTextController.text = listText[0];

    String invoiceNo = "";

    // For every each text in ListText
    for (String i in listText) {
      // Text if match with CompanyRegex
      if (companyRegex.hasMatch(i)) {

        // Set text to CompanyTextController.text
        if (i.contains(RegExp("A.S.", caseSensitive: false))) {
          i = i.replaceAll(RegExp("A.S.", caseSensitive: false), "A.Ş.");
        }
        companyTextController.text = i;
      }
      // Text if match with DateRegex

      else if (dateRegex.hasMatch(i)) {
        // Set text to DateTextController.text
        final RegExpMatch? matchedDate = dateRegex.firstMatch(i);
        if (matchedDate != null) {
          i = i.substring(matchedDate.start, matchedDate.end);
        }

        dateTextController.text = dateFormat.format(DateParser(i));
      }
      // If text length is 16
      else if (invoiceNoRegex.hasMatch(i)) {
        // set text to InvoiceNoTextController.text
        i = i.replaceAll(" ", "");
        if (i.contains(":")) {
          i = i.split(":").last;
        }

        invoiceNoTextController.text = i;

      }
      // Text if match with AmountRegex
      else if (amountRegex.hasMatch(i) && !RegExp(r"[a-z]", caseSensitive: false).hasMatch(i)) {
        // Set text to AmountTextController.text
        String tax = listText.elementAt(listText.indexOf(i) - 1);

        i = i.replaceAll(" ", "").replaceAll(RegExp(r'[^0-9.,]'), "").replaceAll(",", ".");
        tax = tax.replaceAll(" ", "").replaceAll(RegExp(r'[^0-9.,]'), "").replaceAll(",", ".");

        totalAmountTextController.text = double.parse(i).toString();
        taxAmountTextController.text = double.parse(tax).toString();
      }

      if (i.toUpperCase().contains("NO")) {
        if (listText.length != listText.indexOf(i) + 1) {
          i = listText.elementAt(listText.indexOf(i) + 1);
          i = i.replaceAll(" ", "");
          if (i.contains(":")) {
            i = i.split(":").last;
          }
          invoiceNo = i;
        }
      }

    }
    if (invoiceNoTextController.text.isEmpty) {
      invoiceNoTextController.text = invoiceNo;
    }
  }

  Future<void> fetchInvoiceData([final String? aioutput]) async {

    final InvoiceData item;

    if (readMode == null) {
      item = InvoiceDataService().getInvoiceData(widget.invoiceData!)!;
    }
    else {
      //For test
      print(aioutput);
      item = InvoiceData.fromJson(jsonDecode(aioutput!));
    }

    companyTextController.text = item.companyName;
    invoiceNoTextController.text = item.invoiceNo;
    dateTextController.text = dateFormat.format(item.date);
    totalAmountTextController.text = item.totalAmount.toString();
    taxAmountTextController.text = item.taxAmount.toString();

  }

  Future<void> saveInvoice() async {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      setState(() {
        _saveButtonState = false;
      });

      // If the form is valid, display a snack bar. In the real world,
      // you'd often call a server or save the information in a database.

      final List<String> companyList = await InvoiceDataService().getCompanyList();

      if (readMode != null) {
        for (final companyName in companyList) {

          // If the company name is the same as the company name in the database, bypass to similarity check
          if (companyTextController.text == companyName) {
            break;
          }
          final double similarity =
          (companyTextController.text).similarityTo(companyName);

          if (similarity >= 0.4) {
            if (!mounted) return;
            await showDialog<bool>(
              barrierDismissible: false,
              context: context,
              builder: (final BuildContext context) => AlertDialog(
                title: const Text(
                  'Similar Company Found!',
                  style: TextStyle(color: Colors.redAccent),
                ),
                content: Text(
                  'Do you want to merge with it?'
                      '\n${companyTextController.text} -> $companyName',
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
              if (value == true) {
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
            text: "Processing Data...",
            color: Colors.yellowAccent);
      }

      if (companyTextController.text.contains("A.S.")) {
        companyTextController.text = companyTextController.text.replaceAll(RegExp("A.S.", caseSensitive: false), "A.Ş.");
      }

      try {
        final data = InvoiceData(
            imagePath: imageFile.path,
            companyName: companyTextController.text,
            invoiceNo: invoiceNoTextController.text,
            date: dateFormat.parse(dateTextController.text),
            totalAmount: double.parse(totalAmountTextController.text),
            taxAmount: double.parse(taxAmountTextController.text),
            id: widget.invoiceData?.id);

        await InvoiceDataService().saveInvoiceData(data);
        _isFileSaved = true;

        if (mounted) {
          Toast(context,
              text: "Data Processed!",
              color: Colors.greenAccent
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) return;
        Toast(context,
            text: "Something went wrong.\n$e",
            color: Colors.redAccent);
      } finally {
        setState(() {
          _saveButtonState = true;
        });
      }
    }
  }
}
