import 'package:get/get.dart';
import '../binding/splash_binding.dart';
import '../utils/strings.dart';
import '../views/chat_screen.dart';
import '../views/content_screen.dart';
import '../views/diet_chart_screen.dart';
import '../views/hash_tag_screen.dart';
import '../views/home_screen.dart';
import '../views/image_screen.dart';
import '../views/login_screen.dart';
import '../views/purchase_plan_screen.dart';
import '../views/settings_screen.dart';
import '../views/splash_screen/splash_screen.dart';
import '../views/update_profile_screen.dart';
import '../widgets/others/webview_widget.dart';
import '../routes/routes.dart';



class Pages {
  static var list = [
    GetPage(
      name: Routes.splashScreen,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.welcomeScreen,
      page: () => WelcomeScreen(),
    ),
    GetPage(
      name: Routes.purchasePlanScreen,
      page: () => PurchasePlanScreen(),
    ),
    GetPage(
      name: Routes.homeScreen,
      page: () => HomeScreen(),
    ),
    GetPage(
      name: Routes.chatScreen,
      page: () => ChatScreen(),
    ),
    GetPage(
      name: Routes.searchScreen,
      page: () => ImageScreen(),
    ),
    GetPage(
      name: Routes.contentScreen,
      page: () => ContentWritingScreen(),
    ),
    GetPage(
      name: Routes.hashTagScreen,
      page: () => HashTagScreen(),
    ),
    GetPage(
      name: Routes.dietChartScreen,
      page: () => DietChartScreen(),
    ),
    GetPage(
      name: Routes.updateProfileScreen,
      page: () => UpdateProfileScreen(),
    ),
    GetPage(
      name: Routes.settingsScreen,
      page: () => SettingsScreen(),
    ),
    GetPage(
      name: Routes.privacyPolicy,
      page: () => const WebviewWidget(
        mainUrl: Strings.privacyPolicyUrl,
        appBarTitle: Strings.privacyPolicy,
      ),
    ),
    GetPage(
      name: Routes.termsAndCondition,
      page: () => const WebviewWidget(
        mainUrl: Strings.termsUrl,
        appBarTitle: Strings.terms,
      ),
    ),
    GetPage(
      name: Routes.refundPolicy,
      page: () => const WebviewWidget(
        mainUrl: Strings.refundPolicyUrl,
        appBarTitle: Strings.refundPolicy,
      ),
    ),
  ];
}
