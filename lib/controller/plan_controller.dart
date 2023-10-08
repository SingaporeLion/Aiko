import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:pay/pay.dart';

import '../helper/notification_helper.dart';

import '../utils/assets.dart';
import '../utils/config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/routes.dart';
import 'main_controller.dart';

class PlanController extends GetxController {

  final plugin = PaystackPlugin();

  @override
  void onInit() {
    NotificationHelper.initInfo();
    plugin.initialize(publicKey: ApiConfig.payStackPublicKey);

    googlePayConfigFuture =
        PaymentConfiguration.fromAsset('google_pay.json');
    applePayConfigFuture =
        PaymentConfiguration.fromAsset('apple_pay.json');

    super.onInit();
  }

  updateUserPlan() async {
    MainController.updateToPremiumUser();
    Get.offNamedUntil(Routes.homeScreen, (route) => false);
  }

  navigateToDashboardScreen() {
    Get.toNamed(Routes.homeScreen);
  }


  RxString selectedMethod = ''.obs;

  final List<String> paymentMethod = [
    'Paypal',
    'Stripe',
    'SSL',
    "paystack by card"
    "paystack by bank"
  ];
  final List<String> paymentMethodIcon = [
    Assets.paypal,
    Assets.stripe,
    Assets.sslCommerz,
    Assets.paystack,
    Assets.paystack2,
  ];


  late final Future<PaymentConfiguration> googlePayConfigFuture;
  late final Future<PaymentConfiguration> applePayConfigFuture;

  List <PaymentItem> paymentItems = [
    PaymentItem(
    label: 'Premium Subscription',
    amount: ApiConfig.premiumSubscriptionFee.toString(),
    status: PaymentItemStatus.final_price,
    )
  ];


  void onGooglePayResult(paymentResult) {
    debugPrint(paymentResult.toString());
  }

  void onApplePayResult(paymentResult) {
    debugPrint(paymentResult.toString());
  }
}