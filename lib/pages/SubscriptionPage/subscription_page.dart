import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:invoix/pages/SubscriptionPage/subscription_card.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Text(
            localizations.selectPlan,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          bottom: TabBar(
            tabs: [
              Tab(text: localizations.individualUser),
              Tab(text: localizations.advancedUser),
              Tab(text: localizations.corporateUser),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  _buildSubscriptionTab(
                    context,
                    title: localizations.individualUser,
                    price: localizations.individualPrice,
                    features: [localizations.individualFeatures_1, localizations.individualFeatures_2, localizations.individualFeatures_3],
                    buttonText: localizations.subscribe,
                    icon: Icons.person,
                    glowColor: Colors.blue,
                  ),
                  _buildSubscriptionTab(
                    context,
                    title: localizations.advancedUser,
                    price: localizations.advancedPrice,
                    features: [localizations.advancedFeatures_1, localizations.advancedFeatures_2, localizations.advancedFeatures_3],
                    buttonText: localizations.subscribe,
                    icon: Icons.people,
                    glowColor: Colors.purple,
                  ),
                  _buildSubscriptionTab(
                    context,
                    title: localizations.corporateUser,
                    price: localizations.corporatePrice,
                    features: [localizations.corporateFeatures],
                    buttonText: localizations.contactUs,
                    icon: Icons.business,
                    glowColor: Colors.orange,
                  ),
                ],
              ),
            ),
            _buildNewUserOffer(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionTab(
      final BuildContext context, {
        required final String title,
        required final String price,
        required final List<String> features,
        required final String buttonText,
        required final IconData icon,
        required final Color glowColor,
      }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SubscriptionCard(
          title: title,
          price: price,
          features: features,
          buttonText: buttonText,
          icon: icon,
          glowColor: glowColor,
        ),
      ),
    );
  }

  Widget _buildNewUserOffer(final BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 10,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              localizations.newUserOffer,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              localizations.newUserOfferDetails,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}