part of 'invoix_main.dart';

mixin _InvoixMainMixin on ConsumerState<InvoixMain> {
  bool _showWelcomePage = false;
  late final SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _checkFirstSeen();
    _checkCooldown();
  }

  Future<void> _checkCooldown() async {
    final invoiceDataService = ref.read(invoiceDataServiceProvider);
    for (final key in invoiceDataService.remainingTimeBox.keys) {
      final int remainingTime = invoiceDataService.remainingTimeBox.get(key) ??
          0;
      if (remainingTime > 0) {
        await cooldown(remainingTime, key, invoiceDataService);
      }
    }
  }

  Future<void> _checkFirstSeen() async {
    prefs = await SharedPreferences.getInstance();
    final bool seen = (prefs.getBool('seen') ?? false);

    setState(() {
      _showWelcomePage = !seen;
    });
  }

  Future<void> _onWelcomePageDone() async {
    setState(() {
      _showWelcomePage = false;
      prefs.setBool('seen', false);
    });
  }
}