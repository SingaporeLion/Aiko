// ignore_for_file: deprecated_member_use, depend_on_referenced_packages

import 'utils/config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:AIKO/views/login_screen.dart';
import 'package:AIKO/views/SecondWelcomeScreen.dart';

import 'helper/unity_ad.dart';
import 'services/apple_sign_in/apple_sign_in_available.dart';
import 'services/status_service_admin.dart';
import 'firebase_options.dart';
import 'helper/notification_helper.dart';
import 'routes/pages.dart';
import 'routes/routes.dart';
import 'utils/Flutter Theam/themes.dart';
import 'utils/language/local_string.dart';
import 'utils/strings.dart';

String? userName;
String? userGender;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();
  await AdManager.init();

  Stripe.publishableKey = ApiConfig.stripePublishableKey;

  // Bedingte Initialisierung von Firebase
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Laden der SharedPreferences-Daten
  SharedPreferences prefs = await SharedPreferences.getInstance();
  userName = prefs.getString('userName');
  userGender = prefs.getString('userGender');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(414, 896),
      builder: (_, child) => GetMaterialApp(
        title: Strings.appName,
        debugShowCheckedModeBanner: false,
        theme: Themes.light,
        darkTheme: Themes.dark,
        themeMode: Themes().theme,
        navigatorKey: Get.key,
        initialRoute: userName != null && userGender != null
            ? '/secondWelcome'
            : '/welcome',
        getPages: Pages.list,
        translations: LocalString(),
        locale: const Locale('en', 'US'),
        builder: (context, widget) {
          ScreenUtil.init(context);
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: widget!,
          );
        },
      ),
    );
  }
}

