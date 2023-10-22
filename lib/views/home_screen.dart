import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../controller/home_controller.dart';
import '../helper/local_storage.dart';
import '../helper/unity_ad.dart';
import '../routes/routes.dart';
import '../utils/assets.dart';
import '../utils/config.dart';
import '../utils/custom_color.dart';
import '../utils/dimensions.dart';
import '../utils/strings.dart';
import '../widgets/api/toast_message.dart';
//import '../widgets/app_name_widget.dart';
import 'drawer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final controller = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await AdManager.loadUnityIntAd();
      await AdManager.loadUnityRewardedAd();
    });
  }

  @override
  Widget build(BuildContext context) {
    RxBool isDark = Get.isDarkMode.obs;

    return Scaffold(
      drawer: DrawerWidget(isDark: isDark),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Visibility(
            visible: LocalStorage.isLoggedIn(),
            child: IconButton(
              onPressed: () {
                _showMenuDialog(context);
              },
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: Get.isDarkMode
                ? [Colors.pink[900]!, Colors.blue[900]!]
                : [Colors.pink[100]!, Colors.blue[100]!],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _pageIconAnTitle(),
            _buttonsWidget(context, isDark),
          ],
        ),
      ),
    );
  }

  _buttonsWidget(BuildContext context, isDark) {
    return Flexible(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Visibility(
              visible: LocalStorage.getChatStatus(),
              child: _buildContainer(context, isDark,
                  title: Strings.chatWithAIKO.tr,
                  subTitle: Strings.chatWithAIKOSubTitle.tr,
                  iconPath: Assets.messages, onTap: () async{
                    await AdManager.showRewardedAd();
                    Get.toNamed(Routes.chatScreen);
                  })),


          Visibility(
              visible: LocalStorage.getContentStatus(),
              child: _buildContainer(context, isDark,
                  title: Strings.contentWriting.tr,
                  subTitle: Strings.contentWritingSubTitle.tr,
                  iconPath: Assets.content, onTap: () async{
                if (LocalStorage.isFreeUser()) {

                  await AdManager.showRewardedAd();

                  if (LocalStorage.getContentCount() <
                      ApiConfig.freeContentLimit) {
                    Get.toNamed(Routes.contentScreen);
                  } else {
                    ToastMessage.error(
                        'Free limit is over.\nBuy Subscription for continue');
                  }
                } else {
                  if (LocalStorage.getContentCount() <
                      ApiConfig.premiumContentLimit) {
                    Get.toNamed(Routes.contentScreen);
                  } else {
                    ToastMessage.error(
                        'Paid limit is over.\nBuy Subscription again');
                  }
                }
              })),

          Visibility(
            visible: LocalStorage.getContentStatus(),
            child: _buildContainer(
              context,
              isDark,
              title: Strings.keyWordCreating.tr,
              subTitle: Strings.hashTagCreatorSubTitle.tr,
              iconPath: Assets.hashTag,
              onTap: () async{
                if (LocalStorage.isFreeUser()) {

                  await AdManager.showRewardedAd();

                  if (LocalStorage.getHashTagCount() <
                      ApiConfig.freeHashTagLimit) {
                    Get.toNamed(Routes.hashTagScreen);
                  } else {
                    ToastMessage.error(
                        'Free limit is over.\nBuy Subscription for continue');
                  }
                } else {
                  if (LocalStorage.getHashTagCount() <
                      ApiConfig.premiumHashTagLimit) {
                    Get.toNamed(Routes.hashTagScreen);
                  } else {
                    ToastMessage.error(
                        'Paid limit is over.\nBuy Subscription again');
                  }
                }
              },
            ),
          ),

//diet chart using hash tag letter change assets and functions
          Visibility(
            visible: LocalStorage.getContentStatus(),
            child: _buildContainer(
              context,
              isDark,
              title: Strings.dietChartCreating.tr,
              subTitle: Strings.dietChartCreatorSubTitle.tr,
              iconPath: Assets.dietChart,
              onTap: () async{
                if (LocalStorage.isFreeUser()) {

                  await AdManager.showRewardedAd();

                  if (LocalStorage.getHashTagCount() <
                      ApiConfig.freeHashTagLimit) {
                    Get.toNamed(Routes.dietChartScreen);
                  } else {
                    ToastMessage.error(
                        'Free limit is over.\nBuy Subscription for continue');
                  }
                } else {
                  if (LocalStorage.getHashTagCount() <
                      ApiConfig.premiumHashTagLimit) {
                    Get.toNamed(Routes.dietChartScreen);
                  } else {
                    ToastMessage.error(
                        'Paid limit is over.\nBuy Subscription again');
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  _pageIconAnTitle() {
    return Center(
      child: Image.asset(
        Assets.bot,
        scale: 6,
      ),
    );
  }

  //_animatedTextWidget() {
  //  return const Padding(
  //      padding: EdgeInsets.only(top: 18.0), child: AppNameWidget());
  //}

  _buildContainer(BuildContext context, isDark,
      {required String title,
      required String subTitle,
      required VoidCallback onTap,
      required String iconPath}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        padding: EdgeInsets.all(Dimensions.defaultPaddingSize * 0.5),
        margin: EdgeInsets.symmetric(
          vertical: Dimensions.heightSize * 0.5,
          horizontal: Dimensions.widthSize * 2,
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radius),
            border: Border.all(
                color: (isDark.value
                        ? CustomColor.whiteColor
                        : CustomColor.primaryColor)
                    .withOpacity(0.4),
                width: 1)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                height: 40,
                width: 50,
                child: SvgPicture.asset(
                  iconPath,
                  // ignore: deprecated_member_use
                  color: (isDark.value
                      ? CustomColor.whiteColor
                      : CustomColor.primaryColor),
                )),
            SizedBox(width: Dimensions.widthSize),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Get.isDarkMode ? CustomColor.whiteColor : CustomColor.primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: Dimensions.defaultTextSize * 1.8,
                    ),
                  ),
                  SizedBox(height: Dimensions.heightSize * 0.5),
                  Text(
                    subTitle,
                    style: TextStyle(
                      color: Get.isDarkMode
                          ? CustomColor.whiteColor.withOpacity(0.7)
                          : CustomColor.primaryColor.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                      fontSize: Dimensions.defaultTextSize * 1.1,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _showMenuDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Dimensions.widthSize * 3,
                vertical: Dimensions.heightSize),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                  controller.menuList.length,
                  (index) => Container(
                        alignment: Alignment.centerLeft,
                        color: Colors.white,
                        width: MediaQuery.of(context).size.width * 0.5,
                        padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.widthSize * 1,
                            vertical: Dimensions.heightSize * 0.5),
                        child: TextButton(
                            onPressed: () {
                              // if(LocalStorage.showAdPermissioned() && LocalStorage.getAdMobStatus()){
                              //     AdMobHelper.getInterstitialAdLoad();
                              //   }
                              if (index == 0) {
                                Get.back();
                                AdManager.showIntAd();
                                showAlertDialog(context);
                              }
                            },
                            child: Text(
                              controller.menuList[index].tr,
                              style: const TextStyle(
                                  color: CustomColor.blackColor),
                            )),
                      )),
            ),
          );
        });
  }

  void showAlertDialog(BuildContext context) {
    // Create button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Get.back();
        controller.deleteAccount();
      },
    );

    Widget cancelButton = TextButton(
      child: Text(
        Strings.cancel.tr,
        style: const TextStyle(color: Colors.red),
      ),
      onPressed: () {
        Get.back();
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        Strings.alert.tr,
        style: const TextStyle(color: Colors.red),
      ),
      content: Text(
        Strings.deleteYourAccount.tr,
        style: const TextStyle(color: CustomColor.primaryColor),
      ),
      actions: [okButton, cancelButton],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
