import 'package:flutter/material.dart';
import 'package:invoix/l10n/localization_extension.dart';
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
        title = context.l10n.subsplan_individualUser;
        buttonText = context.l10n.subsplan_subscribe;
        features = [context.l10n.subsplan_individualFeatures_1, context.l10n.subsplan_individualFeatures_2, context.l10n.subsplan_individualFeatures_3];
        icon = Icons.person;
        glowColor = Colors.blue;
        break;
      case 'advanced_subscription':
        title = context.l10n.subsplan_advancedUser;
        buttonText = context.l10n.subsplan_subscribe;
        features = [context.l10n.subsplan_advancedFeatures_1, context.l10n.subsplan_advancedFeatures_2, context.l10n.subsplan_advancedFeatures_3];
        icon = Icons.people;
        glowColor = Colors.purple;
        break;
      case 'corporate_subscription':
        title = context.l10n.subsplan_corporateUser;
        buttonText = context.l10n.subsplan_contactUs;
        features = [context.l10n.subsplan_corporateFeatures];
        icon = Icons.business;
        glowColor = Colors.orange;
        break;
      default:
        return Center(child: Text(context.l10n.message_invalidId));
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
