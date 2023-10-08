class ApiConfig {
  static const String stripeUrl = "https://api.stripe.com/v1/payment_intents";
  static const String stripeSecretKey =
      "sk_test_51L6hZUBoqQ6Z2AxwD8EzIYyW5z7i5OFIa76Rv1IpzZ4yoEjZNlVIo4WpiMzVoPmEl5vvbNBD3ipVxVxqUuoM9P4X002BcC7b8s";
  static const String stripePublishableKey =
      "pk_test_51L6hZUBoqQ6Z2Axwg7s0pOYp5xrSfbsIrdNfFJArKoaUi78oNxzwgJxZDYOwupsn8xBIG59jGWnW5tXewtW0kr2s00sNLjLDS3";

  static String payStackPublicKey =
      'pk_test_3c06b99b181a85fe99c74b8e4767429c8c902b66';
  static String payStackServerKey =
      'sk_test_6d2678dfe6f79af08d1c8c8dcc845799c2af84ac';

  static String flutterwavePublicKey =
      'FLWPUBK_TEST-8c91f68d3221f80efdd1d7f9fa9fb2d4-X';

  static const double premiumSubscriptionFee = 19.0;

  static const int freeMessageLimit = 2;
  static const int freeImageGenLimit = 1;
  static const int freeContentLimit = 2;
  static const int freeHashTagLimit = 2;

  static const int premiumMessageLimit = 100;
  static const int premiumImageGenLimit = 50;
  static const int premiumContentLimit = 100;
  static const int premiumHashTagLimit = 100;
  static const int premiumDuration = 30;
}
