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