import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:invoix/services/firebase_service.dart';

class InAppPurchaseService {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];
  final FirebaseService _firebaseService;

  InAppPurchaseService(this._firebaseService);

  Future<void> initialize() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      return;
    }

    const Set<String> _kIds = {'individual_subscription', 'advanced_subscription', 'corporate_subscription'};
    final ProductDetailsResponse productDetailResponse = await _inAppPurchase.queryProductDetails(_kIds);
    if (productDetailResponse.error == null) {
      _products = productDetailResponse.productDetails;
    }

    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((final purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (final error) {
      // Handle error here.
    });
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show a dialog that purchase is pending
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // Handle error here.
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // Verify purchase with Firebase
          await _firebaseService.verifyPurchase(
            purchaseDetails.productID,
            purchaseDetails.purchaseID ?? '',
          );
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    });
  }

  ProductDetails? getProductById(final String productId) {
    try {
      return _products.firstWhere((final p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  void buyProduct(final ProductDetails product) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void dispose() {
    _subscription.cancel();
  }
}