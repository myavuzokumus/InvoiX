import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:invoix/pages/SubscriptionPage/subscription_card.dart';
import 'package:invoix/services/in_app_purchase_service.dart';

class SubscriptionTab extends StatelessWidget {
  final String productId;
  final InAppPurchaseService inAppPurchaseService;

  const SubscriptionTab({
    super.key,
    required this.productId,
    required this.inAppPurchaseService,
  });

  @override
  Widget build(final BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final product = inAppPurchaseService.getProductById(productId);

    if (product == null) {
      return const Center(child: Text('Product not found'));
    }

    String title;
    String buttonText;
    List<String> features;
    IconData icon;
    Color glowColor;

    switch (productId) {
      case 'individual_subscription':
        title = localizations.individualUser;
        buttonText = localizations.subscribe;
        features = [localizations.individualFeatures_1, localizations.individualFeatures_2, localizations.individualFeatures_3];
        icon = Icons.person;
        glowColor = Colors.blue;
        break;
      case 'advanced_subscription':
        title = localizations.advancedUser;
        buttonText = localizations.subscribe;
        features = [localizations.advancedFeatures_1, localizations.advancedFeatures_2, localizations.advancedFeatures_3];
        icon = Icons.people;
        glowColor = Colors.purple;
        break;
      case 'corporate_subscription':
        title = localizations.corporateUser;
        buttonText = localizations.contactUs;
        features = [localizations.corporateFeatures];
        icon = Icons.business;
        glowColor = Colors.orange;
        break;
      default:
        return const Center(child: Text('Invalid product ID'));
    }
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SubscriptionCard(
          title: title,
          price: product.price, //"3€ / Monthly"
          features: features,
          buttonText: buttonText,
          icon: icon,
          glowColor: glowColor,
          onPressed: () => inAppPurchaseService.buyProduct(product), //() {}
        ),
      ),
    );
  }
}
