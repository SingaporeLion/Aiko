import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/image_controller.dart';
import '../helper/local_storage.dart';
import '../helper/unity_ad.dart';
import '../routes/routes.dart';
import '../utils/config.dart';
import '../utils/custom_color.dart';
import '../utils/dimensions.dart';
import '../utils/strings.dart';
import '../widgets/api/custom_loading_api.dart';
import '../widgets/api/toast_message.dart';
import '../widgets/appbar/appbar_widget.dart';
import '../widgets/inputs_widgets/primary_input_field.dart';

class ImageScreen extends StatelessWidget {
  ImageScreen({Key? key}) : super(key: key);
  final _imageController = Get.put(ImageController());
  final TextEditingController _imageTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        context: context,
        onBackClick: () {
          Get.back();
        },
        moreVisible: false,
        buttonText: Strings.changeImageSize.tr,
        appTitle: Strings.generateAnyImage.tr,
        onPressed: () {
          Get.back();
          Get.toNamed(Routes.settingsScreen);
        },
      ),
      body: Column(
        children: [
          Expanded(
            flex: 0,
            child: PrimaryInputField(
              controller: _imageTextController,
              hintText: Strings.typeYour,
              onTap: () async {
                if (!LocalStorage.isFreeUser()) {
                  if(LocalStorage.getImageCount() < ApiConfig.premiumImageGenLimit){
                    if (_imageTextController.text.isNotEmpty) {

                      await _imageController.getImage(
                        imageText: _imageTextController.text.trim(),
                      );

                      Get.snackbar('Generated', "Please wait for load image");
                    } else {
                      ToastMessage.error(Strings.writeSomething.tr);
                    }
                  }
                  else{
                    ToastMessage.error(
                        'Subscription Limit is over. Buy subscription again.');
                  }

                } else {
                  if (LocalStorage.getImageCount() < ApiConfig.freeImageGenLimit) {
                    if (_imageTextController.text.isNotEmpty) {
                      await _imageController.getImage(
                        imageText: _imageTextController.text.trim(),
                      );

                      debugPrint((_imageController.count.value % 2 ==0).toString());
                      if(_imageController.count.value % 2 ==0){
                        debugPrint("1");
                        AdManager.showIntAd();
                      }else{
                        debugPrint("2");
                      }

                      Get.snackbar('Generated', "Please wait for load image");
                    } else {
                      ToastMessage.error(Strings.writeSomething.tr);
                    }
                  } else {
                    ToastMessage.error(
                        'Image Limit is over. Buy subscription.');
                  }
                }
              },
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          _gridView(),
        ],
      ),
    );
  }

  _gridView() {
    return Obx(() {
      return _imageController.isVisible
          ? _imageController.isLoading
              ? const Center(
                  child: CustomLoadingAPI(),
                )
              : Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: Dimensions.widthSize),
                    child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: .9,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10),
                        itemCount: _imageController.imageModel.data.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              _showDialog(context,
                                  _imageController.imageModel.data[index].url!);
                            },
                            child: Container(
                              width: double.infinity,
                              height: 300,
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(Dimensions.radius),
                                  image: DecorationImage(
                                      image: NetworkImage(_imageController
                                          .imageModel.data[index].url!),
                                      fit: BoxFit.fill)),
                            ),
                          );
                        }),
                  ),
                )
          : Text(
        Strings.searchSomething.tr,
        style: TextStyle(
            color: CustomColor.primaryColor,
            fontWeight: FontWeight.w700,
            fontSize: Dimensions.defaultTextSize * 3.2),
      );
    });
  }

  _showDialog(BuildContext context, String url) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Dimensions.widthSize * 3,
                vertical: Dimensions.heightSize),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                  _imageController.moreList.length,
                  (index) => Container(
                        alignment: Alignment.centerLeft,
                        color: Colors.white,
                        width: MediaQuery.of(context).size.width * 0.5,
                        padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.widthSize * 1,
                            vertical: Dimensions.heightSize * 0.5),
                        child: TextButton(
                            onPressed: () {
                              if (index == 0) {
                                _imageController.download(context, url);
                              } else if (index == 1) {
                                _imageController.shareImage(
                                    context, url, _imageTextController.text);
                              }
                              Get.back();
                            },
                            child: Text(
                              _imageController.moreList[index].tr,
                              style: const TextStyle(
                                  color: CustomColor.blackColor),
                            )),
                      )),
            ),
          );
        });
  }
}