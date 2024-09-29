import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoix/pages/SubscriptionPage/new_user_offer.dart';
import 'package:invoix/pages/SubscriptionPage/subscription_tab.dart';
import 'package:invoix/services/in_app_purchase_service.dart';
import 'package:invoix/states/app_purchase_state.dart';
import 'package:invoix/widgets/status/loading_animation.dart';

class SubscriptionPage extends ConsumerStatefulWidget {
  const SubscriptionPage({super.key});

  @override
  ConsumerState<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends ConsumerState<SubscriptionPage> {
  late InAppPurchaseService _inAppPurchaseService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _inAppPurchaseService = ref.read(inAppPurchaseServiceProvider);
    await _inAppPurchaseService.initialize();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _inAppPurchaseService.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Text(
            localizations.selectPlan,
            style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          bottom: TabBar(
                  tabs: [
                    Tab(text: localizations.individualUser),
                    Tab(text: localizations.advancedUser),
                    Tab(text: localizations.corporateUser),
                  ],
                ),
        ),
        body: _isLoading
            ? const LoadingAnimation()
            : isPortrait
                ? Column(
                    children: [
                      tabs(),
                      const NewUserOffer(),
                    ],
                  )
                : Row(
                    children: [
                      tabs(),
                      Flexible(
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height - 150,
                          child: const NewUserOffer(),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Expanded tabs() {

    return Expanded(
      child: TabBarView(
        children: [
          SubscriptionTab(
            productId: 'individual_subscription',
            inAppPurchaseService: _inAppPurchaseService,
          ),
          SubscriptionTab(
            productId: 'advanced_subscription',
            inAppPurchaseService: _inAppPurchaseService,
          ),
          SubscriptionTab(
            productId: 'corporate_subscription',
            inAppPurchaseService: _inAppPurchaseService,
          ),
        ],
      ),
    );

  }

}
