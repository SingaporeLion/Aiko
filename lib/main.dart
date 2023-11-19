import 'utils/config.dart';
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

import 'services/status_service_admin.dart';
import 'helper/notification_helper.dart';
import 'routes/pages.dart';
import 'routes/routes.dart';
import 'utils/Flutter Theam/themes.dart';
import 'utils/language/local_string.dart';
import 'utils/strings.dart';
import '/helper/local_storage.dart';
import 'services/chatsession_service.dart'; // Importieren des ChatSessionService
import 'package:logging/logging.dart';
import '/model/chat_model/chat_model.dart';

void main() async {
  print("App gestartet");
  WidgetsFlutterBinding.ensureInitialized();
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  // Initialisiert Hive für Flutter
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.registerAdapter(ChatMessageAdapter());
  Hive.init(appDocumentDir.path);

  await Hive.initFlutter();
  await GetStorage.init();
  await AdManager.init();
  await LocalStorage.init();


  Stripe.publishableKey = ApiConfig.stripePublishableKey;

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);


  StatusService.init();



  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(414, 896),
      builder: (_, child) => GetMaterialApp(
        title: Strings.appName, // Replace with your app name
        debugShowCheckedModeBanner: false,
        theme: Themes.light, // Your theme data
        darkTheme: Themes.dark, // Your dark theme data
        themeMode: Themes().theme, // Your theme mode
        navigatorKey: Get.key, // Your navigator key
        initialRoute: Routes.welcomeScreen, // Your initial route
        getPages: Pages.list, // Your pages
        translations: LocalString(), // Your translations
        locale: const Locale('en', 'US'), // Your locale
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





