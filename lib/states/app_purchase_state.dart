import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoix/services/in_app_purchase_service.dart';

final inAppPurchaseServiceProvider = Provider<InAppPurchaseService>((final ref) {
  return InAppPurchaseService();
});