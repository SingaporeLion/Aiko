import '/widgets/api/toast_message.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/settings_controller.dart';
import '../helper/local_storage.dart';
import '../routes/routes.dart';
import '../utils/custom_color.dart';
import '../utils/custom_style.dart';
import '../utils/dimensions.dart';
import '../utils/strings.dart';
import '../widgets/api/custom_loading_api.dart';
import '../widgets/appbar/appbar_widget.dart';
import '../widgets/custom_dropdown_widget.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({Key? key}) : super(key: key);

  final controller = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        context: context,
        appTitle: Strings.settings.tr,
        onPressed: () {},
        moreVisible: false,
        onBackClick: () {
          Get.back();
        },
      ),

      body: Obx(() => controller.isLoading ? const CustomLoadingAPI(): _bodyWidget(context)),
    );
  }

  _bodyWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Strings.changeTextModel.tr,
            style: TextStyle(
                fontSize: Dimensions.mediumTextSize * .8,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor
            ),
          ),
          SizedBox(height: Dimensions.heightSize * 0.8),
          InputDropDown(
            itemsList: controller.modelData,
            selectMethod: controller.selectedModel,
            onChanged: (value){
              controller.selectedModel.value = value!;
            },
          ),



          SizedBox(height: Dimensions.heightSize * 1.8),


          Text(
            Strings.changeImageSize.tr,
            style: TextStyle(
                fontSize: Dimensions.mediumTextSize * .8,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor
            ),
          ),


          SizedBox(height: Dimensions.heightSize * 0.8),
          InputDropDown(
            itemsList: controller.imageType,
            selectMethod: controller.selectedImageType,
            onChanged: (value){
              controller.selectedImageType.value = value!;
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
                Strings.imageNote.tr,
              textAlign: TextAlign.end,
              style: CustomStyle.redTextStyle,
            ),
          ),

          Visibility(
            visible: controller.selectedModel.value != 'gpt-3.5-turbo',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: Dimensions.heightSize * 1.8),

                Text(
                  Strings.setToken.tr,
                  style: TextStyle(
                      fontSize: Dimensions.mediumTextSize * .8,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor
                  ),
                ),

                SizedBox(height: Dimensions.heightSize * 0.8),
              ],
            ),
          ),

          Visibility(
            visible: controller.selectedModel.value != 'gpt-3.5-turbo',
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.widthSize,
                vertical: Dimensions.heightSize,
              ),

              decoration: BoxDecoration(
                color: CustomColor.deepGrayColor.withOpacity(.5),
                borderRadius: BorderRadius.circular(Dimensions.radius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      controller.token.value.toString(),
                      textAlign: TextAlign.center,
                      style: CustomStyle.whiteTextStyle.copyWith(
                        fontSize: Dimensions.defaultTextSize * 2
                      ),
                    ),
                  ),
                  Obx(() => Slider(
                    activeColor: CustomColor.whiteColor,
                    inactiveColor: CustomColor.whiteColor.withOpacity(0.5),
                    label: controller.token.value.toString(),
                    min: 7,
                    max: 2000,
                      value: controller.token.value.toDouble(),
                      onChanged: (value){
                        controller.token.value = value.toInt();
                      }
                  )),
                ],
              ),
            ),
          ),




          SizedBox(height: Dimensions.buttonHeight * .8),


          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * .45,
              height: Dimensions.buttonHeight * .75,
              child: ElevatedButton(
                onPressed: (){
                  ToastMessage.success('Successfully Saved');
                  LocalStorage.saveSelectedModel(value: controller.selectedModel.value);
                  LocalStorage.saveSelectedImageType(value: controller.selectedImageType.value);
                  LocalStorage.saveSelectedToken(value: controller.token.value);

                  Get.offAllNamed(Routes.homeScreen);
                },
                child: const Text(Strings.save),
              ),
            ),
          )
        ],
      ),
    );
  }
}
