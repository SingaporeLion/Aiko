import 'package:get/get.dart';

import '../helper/local_storage.dart';
import '../helper/notification_helper.dart';
import '../routes/routes.dart';
import '../utils/constants.dart';
import '../utils/language/english.dart';
import '../utils/strings.dart';
import 'login_controller.dart';
import 'main_controller.dart';

class HomeController extends GetxController {
  var selectedLanguage = "".obs;
  final loginController = Get.put(LoginController());

  final List<String> menuList = [
    Strings.deleteAccount,
  ];

  @override
  void onInit() {
    super.onInit();
    print("Button wurde gedrückt!");
    if (LocalStorage.isLoggedIn()) {
      // Hier können Sie die Logik für eingeloggte Benutzer hinzufügen
    }
    selectedLanguage.value = languageStateName;
  }

  onChangeLanguage(var language, int index) {
    selectedLanguage.value = language;
    if (index == 0) {
      LocalStorage.saveLanguage(
        langSmall: 'en',
        langCap: 'US',
        languageName: English.english,
      );
      languageStateName = English.english;
    }
    // Fügen Sie hier Logik für weitere Sprachen hinzu
  }

  void logout() {
    LocalStorage.logout();
    Get.offAllNamed(Routes.loginScreen);
  }
}
