import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';

class SubscriptionService {
  static final List<String> productIds = [
    Platform.isAndroid
        ? "monthly_subscription"
        : "huntfishai_monthly_subscription"
  ];

  static Future<bool> isSubscriptionPurchased() async {
    final ProductDetailsResponse response = await InAppPurchase.instance
        .queryProductDetails({
      Platform.isAndroid
          ? "monthly_subscription"
          : "huntfishai_monthly_subscription"
    });
    return response.productDetails
        .any((purchase) => productIds.contains(purchase.id));
  }

  static Future<List<ProductDetails>> getAvailableSubscriptions() async {
    final isAvailable = await InAppPurchase.instance.isAvailable();
    if (isAvailable) {
      final ProductDetailsResponse response = await InAppPurchase.instance
          .queryProductDetails({
        Platform.isAndroid
            ? "monthly_subscription"
            : "huntfishai_monthly_subscription"
      });
    }
    final ProductDetailsResponse response = await InAppPurchase.instance
        .queryProductDetails({
      Platform.isAndroid
          ? "monthly_subscription"
          : "huntfishai_monthly_subscription"
    });
    return response.productDetails;
  }

  static Future<void> buySubscription(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    await InAppPurchase.instance
        .buyConsumable(purchaseParam: purchaseParam)
        .then((value) {});
  }
}
