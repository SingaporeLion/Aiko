import 'utils/config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'helper/unity_ad.dart';
import 'services/apple_sign_in/apple_sign_in_available.dart';
import 'services/status_service_admin.dart';
import 'helper/notification_helper.dart';
import 'routes/pages.dart';
import 'routes/routes.dart';
import 'utils/Flutter Theam/themes.dart';
import 'utils/language/local_string.dart';
import 'utils/strings.dart';
import '/helper/local_storage.dart';

void main() async {
  print("App gestartet");
  WidgetsFlutterBinding.ensureInitialized();

    final appDocumentDirectory = await path_provider.getApplicationDocumentsDirectory();
    Hive.init(appDocumentDirectory.path);
    runApp(MyApp());

  await GetStorage.init();
  await AdManager.init();
  await LocalStorage.init();

  Stripe.publishableKey = ApiConfig.stripePublishableKey;

  SystemChrome.setPreferredOrientations([
    // Locking Device Orientation
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  NotificationHelper.initialization();
  NotificationHelper.requestPermission();
  NotificationHelper.getBackgroundNotification();

  StatusService.init();

  appleSignInAvailable.check();

  runApp(MyApp());
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
        initialRoute: Routes.welcomeScreen,
        getPages: Pages.list,
        translations: LocalString(),
        locale: const Locale('en', 'US'),
        builder: (context, widget) {
          ScreenUtil.init(context);
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: widget!,
          ); // Locking Device Orientation
        },
      ),
    );
  }
}




