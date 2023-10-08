// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutter_sslcommerz/model/SSLCTransactionInfoModel.dart';
import 'package:flutterwave_standard/core/flutterwave.dart';
import 'package:flutterwave_standard/models/requests/customizations.dart';
import 'package:flutterwave_standard/models/responses/charge_response.dart';
import 'package:get/get.dart';
import 'package:pay/pay.dart';
import 'package:uuid/uuid.dart';

import '../controller/main_controller.dart';
import '../helper/local_storage.dart';
import '../controller/plan_controller.dart';
import '../routes/routes.dart';
import '../services/paystack/initiliaze_paystack.dart';
import '../services/ssl_commerz.dart';
import '../services/stripe_service.dart';
import '../utils/assets.dart';
import '../utils/config.dart';
import '../utils/custom_color.dart';
import '../utils/custom_style.dart';
import '../utils/dimensions.dart';
import '../utils/strings.dart';
import '../widgets/api/toast_message.dart';
import '../widgets/appbar/appbar_widget2.dart';

import 'payment_method/paypal_payment.dart';
import 'package:flutterwave_standard/models/requests/customer.dart';

class PurchasePlanScreen extends StatelessWidget {
  PurchasePlanScreen({Key? key}) : super(key: key);

  final controller = Get.put(PlanController());
  var paymentController = StripeService();

  @override
  Widget build(BuildContext context) {
    debugPrint(LocalStorage.isFreeUser().toString());
    return Scaffold(
      appBar: AppBarWidget2(
        context: context,
        appTitle: Strings.subscriptionPlan.tr,
        onTap: () {
          Get.offAllNamed(Routes.homeScreen);
        },
      ),
      body: LocalStorage.isFreeUser()
          ? _bodyWidget(context)
          : _subscriptionWidget(context),
    );
  }

  _subscriptionWidget(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: .4,
      child: _purchaseWidget(
        onTap: () {},
        color: Colors.green,
        title: Strings.myPlan.tr,
        price: ApiConfig.premiumSubscriptionFee.toStringAsFixed(2),
        visible: true,
        support: '${Strings.purchaseDate.tr}: ${LocalStorage.getDateString()}',
        firstService:
            "Text search count: ${LocalStorage.getTextCount()}/${ApiConfig.premiumMessageLimit}",
        secondService:
            "Image search count: ${LocalStorage.getImageCount()}/${ApiConfig.premiumImageGenLimit}",
      ),
    );
  }

  _bodyWidget(BuildContext context) {
    return GetBuilder(
      builder: (PlanController controller) {
        return ListView(
          children: [
            _purchaseWidget(
              onTap: () {
                // controller.updateUserPlan();
                Get.offAllNamed(Routes.homeScreen);
              },
              color: CustomColor.secondaryColor,
              title: Strings.freeSubscription.tr,
              price: '0.00',
              support: "${Strings.freeSupport.tr} ${Strings.notIncluded.tr}",
              firstService: Strings.basicChatting.tr,
              secondService: Strings.basicImage.tr,
            ),
            _purchaseWidget(
              onTap: () {
                _showPaymentDialog(context);
              },
              color: CustomColor.secondaryColor2,
              title: Strings.premiumSubscription.tr,
              price: ApiConfig.premiumSubscriptionFee.toStringAsFixed(2),
              visible: true,
              support: '${Strings.freeSupport.tr} 24/7',
              firstService: Strings.unlimitedChatting.tr,
              secondService: Strings.unlimitedImage.tr,
            ),
          ],
        );
      },
    );
  }

  _purchaseWidget({
    required VoidCallback onTap,
    required Color color,
    required String title,
    required String price,
    required String support,
    required String firstService,
    required String secondService,
    bool visible = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(
            horizontal: Dimensions.widthSize * 2,
            vertical: Dimensions.heightSize),
        padding: EdgeInsets.symmetric(
            horizontal: Dimensions.widthSize * 2,
            vertical: Dimensions.heightSize * 2),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(Dimensions.radius * 3),
              bottomLeft: Radius.circular(Dimensions.radius * 3),
            ),
            color: color.withOpacity(Get.isDarkMode ? 0.03 : 1),
            border: Border.all(
                width: 2, color: color.withOpacity(Get.isDarkMode ? 0.08 : 1))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: CustomStyle.primaryTextStyle.copyWith(
                  fontSize: Dimensions.defaultTextSize * 2,
                  color: Get.isDarkMode ? color : Colors.white),
            ),
            SizedBox(
              height: Dimensions.heightSize,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "\$ $price",
                  style: CustomStyle.primaryTextStyle.copyWith(
                      fontSize: Dimensions.defaultTextSize * 4,
                      color: Get.isDarkMode ? color : Colors.white,
                      fontWeight: FontWeight.w700),
                ),
                Visibility(
                  visible: visible,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: Dimensions.widthSize * .5,
                      ),
                      Container(
                        height: Dimensions.heightSize * 2,
                        width: 2,
                        color: Get.isDarkMode ? color : Colors.white,
                      ),
                      SizedBox(
                        width: Dimensions.widthSize * .5,
                      ),
                      Text(
                        Strings.perMonth.tr,
                        style: CustomStyle.primaryTextStyle.copyWith(
                          fontSize: Dimensions.defaultTextSize * 1.4,
                          color: Get.isDarkMode ? color : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: Dimensions.heightSize * .5,
            ),
            Text(
              support,
              style: CustomStyle.primaryTextStyle.copyWith(
                  fontSize: Dimensions.defaultTextSize * 1.2,
                  color: Get.isDarkMode
                      ? color.withOpacity(0.8)
                      : Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: Dimensions.heightSize * 1,
            ),
            Text(
              "• $firstService",
              style: CustomStyle.primaryTextStyle.copyWith(
                  fontSize: Dimensions.defaultTextSize * 1.4,
                  color: Get.isDarkMode ? color : Colors.white,
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: Dimensions.heightSize * .5,
            ),
            Text(
              "• $secondService",
              style: CustomStyle.primaryTextStyle.copyWith(
                  fontSize: Dimensions.defaultTextSize * 1.4,
                  color: Get.isDarkMode ? color : Colors.white,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  _showPaymentDialog(BuildContext context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            width: MediaQuery.of(context).size.width * 0.7,
            padding: EdgeInsets.symmetric(
                horizontal: Dimensions.widthSize * 2,
                vertical: Dimensions.heightSize * 2),
            decoration: BoxDecoration(
              color: CustomColor.whiteColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(Dimensions.radius * 2),
                  topRight: Radius.circular(Dimensions.radius * 2)),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _paypalAndStripeWidget(context),
              _sslAndGpayWidget(),
              _paystackWidget(context),
              _flutterWaveWidget(context),
            ]),
          );
        });
  }

  _paypalAndStripeWidget(BuildContext context) {
    return Row(
      children: [
        _paypalPayment(context),
        SizedBox(
          width: Dimensions.widthSize,
        ),
        _stripePayment(),
      ],
    );
  }

  _paypalPayment(BuildContext context) {
    return Visibility(
      visible: LocalStorage.getPaypalStatus(),
      child: Expanded(
        child: _textButtonWidget(
            scale: 25,
            buttonText: controller.paymentMethod.first,
            path: controller.paymentMethodIcon.first,
            onTap: () {
              debugPrint("WORKED PAYPAL");
              Get.back();
              debugPrint("WORKED PAYPAL");
              if (LocalStorage.getPaypalStatus()) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => PaypalPayment(
                      onFinish: (number) async {
                        controller.updateUserPlan();
                      },
                    ),
                  ),
                );
              } else {
                Get.snackbar("Alert!", 'Paypal is not active.');
              }
            }),
      ),
    );
  }

  _stripePayment() {
    return Visibility(
      visible: LocalStorage.getStripeStatus(),
      child: Expanded(
        child: _textButtonWidget(
            scale: 25,
            buttonText: controller.paymentMethod[1],
            path: controller.paymentMethodIcon[1],
            onTap: () {
              if (LocalStorage.getStripeStatus()) {
                paymentController.makePayment(
                    amount: ApiConfig.premiumSubscriptionFee.toStringAsFixed(0),
                    currency: 'USD');
                // Get.back();
              } else {
                Get.snackbar("Alert!", 'Stripe is not active.');
              }
            }),
      ),
    );
  }

  _sslAndGpayWidget() {
    return Row(
      children: [
        _sslPayment(),
        SizedBox(
          width: Dimensions.widthSize,
        ),
        _gAndApplePay(),
      ],
    );
  }

  _sslPayment() {
    return Visibility(
      visible: LocalStorage.getSSLStatus(),
      child: Expanded(
          child: Padding(
        padding: EdgeInsets.only(top: Dimensions.heightSize * 1),
        child: _textButtonWidget(
            buttonText: controller.paymentMethod[2],
            path: controller.paymentMethodIcon[2],
            onTap: () async {
              var result = await EasySSLCommerz(
                      amount: ApiConfig.premiumSubscriptionFee,
                      productCategory: '',
                      customerAddress1: '',
                      customerCity: '',
                      customerCountry: '',
                      customerEmail: '',
                      customerName: '',
                      customerPhone: '',
                      customerPostCode: '',
                      customerState: '')
                  .payNow();

              if (result is PlatformException) {
                debugPrint(
                    "the response is: ${result.message.toString()} code: ${result.code}");
              } else {
                SSLCTransactionInfoModel model =
                    result as SSLCTransactionInfoModel;
                debugPrint(
                    "SSLCTransactionInfoModel: ${model.toJson().toString()}");
                controller.updateUserPlan();
              }
            },
            scale: 25),
      )),
    );
  }

  _gAndApplePay() {
    return Visibility(
      visible: LocalStorage.getPayStatus(),
      child: Expanded(
          child: Column(
        children: [
          _gpayPayment(),
          _applePayPayment(),
        ],
      )),
    );
  }

  _applePayPayment() {
    return FutureBuilder<PaymentConfiguration>(
        future: controller.applePayConfigFuture,
        builder: (context, snapshot) => snapshot.hasData
            ? ApplePayButton(
                height: Dimensions.heightSize * 3.6,
                paymentConfiguration: snapshot.data!,
                paymentItems: controller.paymentItems,
                style: ApplePayButtonStyle.black,
                type: ApplePayButtonType.plain,
                margin: const EdgeInsets.only(top: 15.0),
                onPaymentResult: controller.onApplePayResult,
                loadingIndicator: const Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : const SizedBox.shrink());
  }

  _gpayPayment() {
    return FutureBuilder<PaymentConfiguration>(
        future: controller.googlePayConfigFuture,
        builder: (context, snapshot) => snapshot.hasData
            ? GooglePayButton(
                height: Dimensions.heightSize * 3.6,
                paymentConfiguration: snapshot.data!,
                paymentItems: controller.paymentItems,
                type: GooglePayButtonType.plain,
                margin: const EdgeInsets.only(top: 15.0),
                onPaymentResult: controller.onGooglePayResult,
                loadingIndicator: const Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : const SizedBox.shrink());
  }

  _paystackWidget(BuildContext context) {
    return Visibility(
      visible: LocalStorage.getPayStackStatus(),
      child: Row(
        children: [
          _payStackCardPayment(context),
          SizedBox(
            width: Dimensions.widthSize,
          ),
          _payStackBankPayment(context),
        ],
      ),
    );
  }

  _payStackCardPayment(BuildContext context) {
    return Visibility(
      visible: LocalStorage.getPayStackCardStatus(),
      child: Expanded(
          child: Padding(
        padding: EdgeInsets.only(top: Dimensions.heightSize * 1),
        child: _textButtonWidget(
            buttonText: "paystack by card",
            path: Assets.paystack,
            onTap: () => chargeCard(context),
            scale: 25),
      )),
    );
  }

  _payStackBankPayment(BuildContext context) {
    return Visibility(
      visible: LocalStorage.getPayStackBankStatus(),
      child: Expanded(
          child: Padding(
        padding: EdgeInsets.only(top: Dimensions.heightSize * 1),
        child: _textButtonWidget(
            buttonText: "paystack by bank",
            path: Assets.paystack,
            onTap: () => chargeBank(context),
            scale: 25),
      )),
    );
  }

  _flutterWaveWidget(BuildContext context) {
    return Visibility(
      visible: LocalStorage.getFlutterWaveStatus(),
      child: Row(
        children: [
          _flutterwavePayment(context),
          SizedBox(
            width: Dimensions.widthSize,
          ),
          Container(),
        ],
      ),
    );
  }

  _flutterwavePayment(BuildContext context) {
    return Visibility(
      visible: LocalStorage.getPayStackCardStatus(),
      child: Expanded(
          child: Padding(
        padding: EdgeInsets.only(top: Dimensions.heightSize * 1),
        child: _textButtonWidget(
            buttonText: "Fluttewave",
            path: Assets.flutterwave,
            onTap: () => flutterWavePaymentInitialization(
                context, ApiConfig.premiumSubscriptionFee.toStringAsFixed(0)),
            scale: 25),
      )),
    );
  }

  _textButtonWidget(
      {required VoidCallback onTap,
      required String path,
      required String buttonText,
      double scale = 1}) {
    return InkWell(
        borderRadius: BorderRadius.circular(Dimensions.radius * 2),
        onTap: onTap,
        child: Container(
          height: Dimensions.heightSize * 3.6,
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.widthSize * 1.5,
            vertical: Dimensions.heightSize * .8,
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Platform.isAndroid
                  ? Dimensions.radius * 3
                  : Dimensions.radius * .5),
              color: Colors.black),
          child: FittedBox(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(path, scale: scale),
                SizedBox(width: Dimensions.widthSize * .5),
                Text(
                  buttonText,
                  style: const TextStyle(
                    color: CustomColor.whiteColor,
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  /// paystack card payment
  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }
    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  chargeCard(BuildContext context) async {
    Get.back();
    Charge charge = Charge()
      ..amount = ApiConfig.premiumSubscriptionFee.toInt()
      ..reference = _getReference()
      // or ..accessCode = _getAccessCodeFrmInitialization()
      ..email = 'appdevsx@gmail.com'; //user email
    CheckoutResponse response = await controller.plugin.checkout(
      context,
      method: CheckoutMethod.card, // Defaults to CheckoutMethod.selectable
      charge: charge,
    );
    if (response.status == true) {
      MainController.updateToPremiumUser();
      ToastMessage.success('Your Plan Updated to Premium');
      Get.offNamedUntil(Routes.homeScreen, (route) => false);
    } else {
      ToastMessage.error('Failed to process payment');
    }
  }

  chargeBank(BuildContext context) async {
    Map accessCode = await createAccessCode(ApiConfig.payStackServerKey);

    Charge charge = Charge()
      ..amount = 10000
      ..accessCode = accessCode["data"]["access_code"]
      ..email = 'appdevsx@gmail.com';

    CheckoutResponse response = await controller.plugin.checkout(
      context,
      method: CheckoutMethod.bank, // Defaults to CheckoutMethod.selectable
      charge: charge,
    );
    if (response.status == true) {
      MainController.updateToPremiumUser();
      ToastMessage.success('Your Plan Updated to Premium');
      Get.offNamedUntil(Routes.homeScreen, (route) => false);
    } else {
      ToastMessage.error('Failed to process payment');
    }
  }

  flutterWavePaymentInitialization(BuildContext context, String amount) async {
    final Customer customer = Customer(
        email: "customer@customer.com",
        name: 'customer',
        phoneNumber: '123456789');
    final Flutterwave flutterwave = Flutterwave(
        context: context,
        publicKey: ApiConfig.flutterwavePublicKey,
        currency: 'USD',
        redirectUrl: 'https://flutterwave.com/us',
        txRef: const Uuid().v1(),
        amount: amount,
        customer: customer,
        paymentOptions: "card, payattitude, barter, bank transfer, ussd",
        customization: Customization(title: "Test Payment"),
        isTestMode: true);
    final ChargeResponse response = await flutterwave.charge();
    // ignore: unnecessary_null_comparison
    if (response != null) {
      if (response.success == true) {
        // debugPrint(response.toString());
        controller.updateUserPlan();
      } else {
        debugPrint(response.toString());
      }
      debugPrint("${response.toJson()}");
    } else {
      debugPrint("No Response!");
    }
  }
}
