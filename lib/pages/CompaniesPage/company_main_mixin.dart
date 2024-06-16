part of 'company_main.dart';

mixin _CompanyPageMixin on ConsumerState<CompanyPage> {
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier(false);

  late ReadMode readMode;

  @override
  void initState() {
    readMode = ReadMode.ai;
    super.initState();
  }

  Future<void> nextPage() async {
    _isLoadingNotifier.value = true;

    final DocumentScanningResult? result =
        await getDocumentScanner().catchError((final e) {
      if (mounted && e.message != "Operation cancelled") {
        Toast(context,
            text: "Something went wrong."
                "$e",
            color: Colors.redAccent);
      }
      return null;
    });

    if (result != null && mounted && result.images.isNotEmpty) {
      unawaited(Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (final BuildContext context,
                    final Animation<double> animation,
                    final Animation<double> secondaryAnimation) =>
                InvoiceEditPage(
                    imageFile: XFile(result.images[0]), readMode: readMode),
            transitionDuration: const Duration(milliseconds: 250),
            transitionsBuilder:
                (final context, animation, final animationTime, final child) {
              animation =
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut);
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          )));
    }
    _isLoadingNotifier.value = false;
  }
}
