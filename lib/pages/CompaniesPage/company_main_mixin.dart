part of 'company_main.dart';

mixin _CompanyPageMixin on ConsumerState<CompanyPage> {

  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier(false);

  late ReadMode readMode;

  @override
  void initState() {
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

  // Get image from camera
  Future<void> getImageFromCamera() async {

    final DocumentScannerOptions documentOptions = DocumentScannerOptions(
      documentFormat: DocumentFormat.jpeg, // set output document format
      mode: ScannerMode.full, // to control what features are enabled
      pageLimit: 1, // setting a limit to the number of pages scanned
      isGalleryImport: true, // importing from the photo gallery
    );

    final documentScanner = DocumentScanner(options: documentOptions);

      try {
        _isLoadingNotifier.value = true;

        final DocumentScanningResult result = await documentScanner.scanDocument();

        if (mounted && result.images.isNotEmpty) {
          unawaited(Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (final BuildContext context, final Animation<double> animation, final Animation<double> secondaryAnimation) => InvoiceEditPage(
                    imageFile: XFile(result.images[0]), readMode: readMode),
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
      } on PlatformException catch (e) {
        if (mounted && e.message != "Operation cancelled") {
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
