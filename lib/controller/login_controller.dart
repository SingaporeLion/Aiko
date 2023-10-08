
import 'package:firebase_auth/firebase_auth.dart';

import '../helper/notification_helper.dart';
import '../widgets/api/toast_message.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../helper/local_storage.dart';
import '../model/user_model/user_model.dart';
import '../routes/routes.dart';
import 'main_controller.dart';

class LoginController extends GetxController {
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  /// auth sector
  signInWithGoogle(BuildContext context) async {
    _isLoading.value = true;
    update();

    try {
      final authService = MainController();
      debugPrint("-------signInWithGoogle  =>  after get userCredential--------");

      final userCredential = await authService.signInWithGoogle();
      debugPrint("-------signInWithGoogle  =>  1  --------");

      final user = userCredential.user!;
      debugPrint("-------signInWithGoogle  =>  before get userCredential--------");


      _userFunctionDataStore(user, userCredential);
    } catch (e) {
      ToastMessage.error(e.toString());
      debugPrint("----------${e.toString()}---------");
    } finally{
      _isLoading.value = false;
      update();
    }
  }
  signInWithApple(BuildContext context) async {
    try {
      final authService = MainController();

      final userCredential = await authService.signInWithApple();
      final user = userCredential.user!;

      debugPrint('uid: ${user.uid}');

      _userFunctionDataStore(user, userCredential);

    } catch (e) {
      ToastMessage.error(e.toString());
      debugPrint("----------${e.toString()}---------");
    }
  }

  void goToHomePage() {
    Get.toNamed(Routes.homeScreen);
  }

  _userFunctionDataStore(User? user, UserCredential userCredential) {
    debugPrint("----------Before Condition---------");
    debugPrint("----------${user?.uid}---------");

    if (user != null) {
      debugPrint("----------After Start Condition---------");

      // storing some data for future use
      ToastMessage.success("Login Success");
      LocalStorage.isLoginSuccess(isLoggedIn: true);
      LocalStorage.saveEmail(email: user.email ?? '');
      LocalStorage.saveName(name: user.displayName ?? "");
      LocalStorage.saveId(id: user.uid);

      debugPrint("----------Before Loc Save al Storage---------");


      // debugPrint(user.toString());

      debugPrint("_________________________________");


      UserModel userData = UserModel(
        name: user.displayName ?? "",
        uniqueId: user.uid,
        phoneNumber: user.phoneNumber ?? "",
        isActive: true,
        imageUrl: user.photoURL ?? "",
        isPremium: false,
        textCount: 0,
        imageCount: 0,
        contentCount: 0,
        hashTagCount: 0,
        date: 0,
        email: user.email ?? '',
      );

      if (userCredential.additionalUserInfo!.isNewUser) {
        MainController.setData(userData);

      }
      else {
        MainController.checkPremiumOrNot(userData);
      }

    }
    else {
      _isLoading.value = false;
      update();
    }
  }

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final noteController = TextEditingController();
  @override
  void onInit() {
    NotificationHelper.initInfo();
    super.onInit();
  }
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    noteController.dispose();
    super.dispose();
  }
}
