import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:invoix/services/firebase_service.dart';
import 'package:invoix/states/firebase_state.dart';
import 'package:invoix/states/global_provider.dart';

class InAppPurchaseService {
  static final InAppPurchaseService _instance = InAppPurchaseService._internal();

  factory InAppPurchaseService() {
    return _instance;
  }

  InAppPurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];
  final FirebaseService _firebaseService = GlobalProviderContainer.get().read(firebaseServiceProvider);

  Future<void> initialize() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      print('In-app purchases are not available');
      return;
    }

    const Set<String> kIds = {'individual_subscription', 'advanced_subscription', 'corporate_subscription'};
    final ProductDetailsResponse productDetailResponse = await _inAppPurchase.queryProductDetails(kIds);
    if (productDetailResponse.error != null) {
      print('Error fetching product details: ${productDetailResponse.error}');
      return;
    }

    _products = productDetailResponse.productDetails;
    if (_products.isEmpty) {
      print('No products found');
      return;
    }

    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((final purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (final error) {
      print('Error in purchase stream: $error');
    });
  }

  void _listenToPurchaseUpdated(final List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((final PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show a dialog that purchase is pending
        print('Purchase is pending');
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // Handle error here.
          print('Error in purchase: ${purchaseDetails.error}');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // Verify purchase with Firebase
          final bool isValid = await _firebaseService.verifyPurchase(
            purchaseDetails.productID,
            purchaseDetails.purchaseID ?? '',
          );
          if (isValid) {
            // Update user's subscription status
            await _firebaseService.updateUserSubscription(purchaseDetails.productID);
          } else {
            print('Purchase verification failed');
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    });
  }

  ProductDetails? getProductById(final String productId) {
    try {
      print(_products);
      return _products.firstWhere((final p) => p.id == productId);
    } catch (e) {
      print('Product not found: $productId');
      return null;
    }
  }

  Future<bool> buyProduct(final ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    try {
      final bool success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      return success;
    } catch (e) {
      print('Error purchasing product: $e');
      return false;
    }
  }

  void dispose() {
    _subscription.cancel();
  }
}
