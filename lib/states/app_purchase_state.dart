import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoix/services/in_app_purchase_service.dart';
import 'package:invoix/states/firebase_state.dart';

final inAppPurchaseServiceProvider = Provider<InAppPurchaseService>((final ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return InAppPurchaseService(firebaseService);
});