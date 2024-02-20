part of 'company_main.dart';

mixin _CompanyPageMixin on ConsumerState<CompanyPage> {

  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier(false);

  late ReadMode readMode;

  @override
  void initState() {
    _isLoadingNotifier.value = false;
    initializeModeData();

    super.initState();
  }

  Future<void> initializeModeData() async {
    final box = await Hive.openBox('modeBox');
    box.get('isAI') ?? false
        ? readMode = ReadMode.ai
        : readMode = ReadMode.legacy;
  }

  void handleModeChange(final ReadMode mode) {
    setState(() {
      readMode = mode;
    });
  }

  Future<void> onDelete(final context) async {
    final selectionState = ref.read(companySelectionProvider);
    final selectedItems = List.from(selectionState.selectedCompanies);

    if (selectedItems.isNotEmpty) {
      await showDialog(
          context: context,
          builder: (final BuildContext context) {
            return AlertDialog(
              title: const Text("Delete Company(s)"),
              content: Text(
                  "Are you sure you want to delete ${selectedItems.length.toString()} company(s)?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    for (final String company in selectedItems) {
                      final List invoices =
                      await InvoiceDataService().getInvoiceList(company);
                      selectionState.selectedCompanies.remove(company);
                      selectionState.listLength -= 1;
                      for (final InvoiceData invoice in invoices) {
                        await InvoiceDataService().deleteInvoiceData(invoice);
                        selectionState.selectedInvoices.remove(invoice);
                      }
                    }

                    if ((await InvoiceDataService().getCompanyList()).isEmpty) {
                      ref.read(companySelectionProvider.notifier).toggleSelectionMode();
                    }

                    Toast(
                      context,
                      text:
                      "${selectedItems.length.toString()} company deleted successfully!",
                      color: Colors.green,
                    );
                  },
                  child: const Text("Delete"),
                ),
              ],
            );
          });
    } else {
      Toast(
        context,
        text: "No company selected for deletion!",
        color: Colors.redAccent,
      );
    }
  }

  // Get image from camera
  Future<void> getImageFromCamera() async {
    final isCameraGranted = await Permission.camera.request();

    if (!mounted) return;

    if (isCameraGranted.isPermanentlyDenied) {
      unawaited(openAppSettings());
      Toast(context,
          text: "You need to give permission to use camera.",
          color: Colors.redAccent);
    } else if (!isCameraGranted.isGranted) {
      Toast(context,
          text: "You need to give permission to use camera.",
          color: Colors.redAccent);
    } else {
      // Generate filepath for saving
      final String imagePath = path.join(
          (await getApplicationSupportDirectory()).path,
          "${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.jpeg");

      try {
        _isLoadingNotifier.value = true;

        final bool success = await EdgeDetection.detectEdge(imagePath,
            canUseGallery: true,
            androidScanTitle: 'Scanning',
            androidCropTitle: 'Crop');


        if (mounted && success) {
          unawaited(Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (final BuildContext context, final Animation<double> animation, final Animation<double> secondaryAnimation) => InvoiceEditPage(
                    imageFile: XFile(imagePath), readMode: readMode),
                transitionDuration: const Duration(milliseconds: 250),
                transitionsBuilder: (final context, animation, final animationTime, final child) {
                  animation = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },

              )));
        }
      } catch (e) {
        if (mounted) {
          Toast(context,
              text: "Something went wrong."
                  "$e",
              color: Colors.redAccent);
        }
      } finally {
        _isLoadingNotifier.value = false;
      }
    }
  }

}