import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/diet_chart_controller.dart';
import '../helper/local_storage.dart';
import '../helper/unity_ad.dart';
import '../utils/config.dart';
import '../utils/custom_color.dart';
import '../utils/dimensions.dart';
import '../utils/strings.dart';
import '../widgets/api/custom_loading_api.dart';
import '../widgets/api/toast_message.dart';
import '../widgets/appbar/appbar_widget.dart';
import '../widgets/buttons/button.dart';
import '../widgets/inputs_widgets/input_field.dart';

class DietChartScreen extends StatelessWidget {
  DietChartScreen({super.key});

  final controller = Get.put(DietChartController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarWidget(context),
      body: _bodyWidget(context),
    );
  }

  _appBarWidget(BuildContext context) {
    return AppBarWidget(
      context: context,
      actionVisible: false,
      onBackClick: () {
        Get.back();
      },
      appTitle: Strings.dietChartCreating.tr,
      onPressed: () {},
    );
  }

  _bodyWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _inputWidget(context),
        ],
      ),
    );
  }

  _inputWidget(BuildContext context) {
    return Flexible(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          SizedBox(height: Dimensions.heightSize * 1),
          _currentWeightTextAndInputWidget(context),
          _targetWeightTextAndInputWidget(context),
          _heightTextAndInputWidget(context),
          _dietDurationTextAndInputWidget(context),
          _genderSelectionTextAndInputWidget(context),
          _lifeStyleSelectionTextAndInputWidget(context),
          _countrySelectionTextAndInputWidget(context),
          _buttonWidget(context),
        ],
      ),
    );
  }

  _currentWeightTextAndInputWidget(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: Dimensions.defaultPaddingSize * .25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //current weight
          Text(
            Strings.currentWeight.tr,
            style: TextStyle(
                fontSize: Dimensions.mediumTextSize * .8,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor),
          ),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: Dimensions.widthSize * .5),
            child: InputField(
              controller: controller.currentWeightController,
              keyboardType: TextInputType.number,
              hintText: "100",
            ),
          ),
        ],
      ),
    );
  }

  _targetWeightTextAndInputWidget(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: Dimensions.defaultPaddingSize * .25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //target weight
          Text(
            Strings.targetWeight.tr,
            style: TextStyle(
                fontSize: Dimensions.mediumTextSize * .8,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor),
          ),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: Dimensions.widthSize * .5),
            child: InputField(
              controller: controller.targetWeightController,
              keyboardType: TextInputType.number,
              hintText: "70",
            ),
          ),
        ],
      ),
    );
  }

  // return Padding(
  // padding:
  // EdgeInsets.symmetric(vertical: Dimensions.defaultPaddingSize * .25),
  // child: Column(
  // crossAxisAlignment: CrossAxisAlignment.start,
  // children: [
  //
  //
  // ],
  // ),
  // );

  _heightTextAndInputWidget(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: Dimensions.defaultPaddingSize * .25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //height
          Text(
            Strings.height.tr,
            style: TextStyle(
                fontSize: Dimensions.mediumTextSize * .8,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor),
          ),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: Dimensions.widthSize * .5),
            child: InputField(
              controller: controller.heightController,
              keyboardType: TextInputType.number,
              hintText: "165",
            ),
          ),
        ],
      ),
    );
  }

  _dietDurationTextAndInputWidget(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: Dimensions.defaultPaddingSize * .25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //diet duration
          Text(
            Strings.dietDuration.tr,
            style: TextStyle(
                fontSize: Dimensions.mediumTextSize * .8,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor),
          ),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: Dimensions.widthSize * .5),
            child: InputField(
              controller: controller.dietDurationController,
              keyboardType: TextInputType.number,
              hintText: "20",
            ),
          ),
        ],
      ),
    );
  }

  _genderSelectionTextAndInputWidget(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: Dimensions.defaultPaddingSize * .25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Strings.gender.tr,
            style: TextStyle(
                fontSize: Dimensions.mediumTextSize * .8,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor),
          ),
          Container(
            height: Dimensions.buttonHeight * 1.1,
            padding: EdgeInsets.symmetric(
                horizontal: Dimensions.defaultPaddingSize * .75,
                vertical: Dimensions.defaultPaddingSize * .30),
            margin: EdgeInsets.symmetric(
                horizontal: Dimensions.defaultPaddingSize * .25,
                vertical: Dimensions.defaultPaddingSize * .30),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.4),
                  width: 1),
              borderRadius: BorderRadius.circular(
                Dimensions.radius * 0.7,
              ),
            ),
            child: Obx(
              () => DropdownButton<String>(
                isExpanded: true,
                value: controller.selectedGender.value,
                hint: Text(
                  controller.selectGenderHintText,
                  style: TextStyle(
                    color: CustomColor.whiteColor.withOpacity(.60),
                    fontWeight: FontWeight.normal,
                  ),
                ),
                dropdownColor: CustomColor.blackColor,
                underline: Container(),
                icon: const Icon(Icons.arrow_drop_down_sharp),
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(
                      controller.selectGenderHintText,
                      style: const TextStyle(
                        color: CustomColor.whiteColor,
                      ),
                    ),
                  ),
                  ...controller.genderList.map((item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: TextStyle(
                          color: CustomColor.whiteColor.withOpacity(.60),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    );
                  }),
                ],
                onChanged: (newValue) {
                  controller.selectedGender.value = newValue!;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

//life Style selection text and input Widget
  _lifeStyleSelectionTextAndInputWidget(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: Dimensions.defaultPaddingSize * .25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Strings.lifeStyle.tr,
            style: TextStyle(
                fontSize: Dimensions.mediumTextSize * .8,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor),
          ),
          Container(
            height: Dimensions.buttonHeight * 1.1,
            padding: EdgeInsets.symmetric(
                horizontal: Dimensions.defaultPaddingSize * .75,
                vertical: Dimensions.defaultPaddingSize * .30),
            margin: EdgeInsets.symmetric(
                horizontal: Dimensions.defaultPaddingSize * .25,
                vertical: Dimensions.defaultPaddingSize * .30),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.4),
                  width: 1),
              borderRadius: BorderRadius.circular(
                Dimensions.radius * 0.7,
              ),
            ),
            child: Obx(
              () => DropdownButton<String>(
                isExpanded: true,
                value: controller.selectedLifeStyle.value,
                hint: Text(
                  controller.selectLifeStyleHintText,
                  style: TextStyle(
                    color: CustomColor.whiteColor.withOpacity(.80),
                    fontWeight: FontWeight.normal,
                  ),
                ),
                dropdownColor: CustomColor.blackColor,
                underline: Container(),
                icon: const Icon(Icons.arrow_drop_down_sharp),
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(
                      controller.selectLifeStyleHintText,
                      style: const TextStyle(
                        color: CustomColor.whiteColor,
                      ),
                    ),
                  ),
                  ...controller.selectedLifeStyleList.map((item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: TextStyle(
                          color: CustomColor.whiteColor.withOpacity(.60),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    );
                  }),
                ],
                onChanged: (newValue) {
                  controller.selectedLifeStyle.value = newValue!;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buttonWidget(BuildContext context) {
    return Obx(
      () => controller.isLoading.value
          ? const CustomLoadingAPI()
          : Column(
              children: [
                SizedBox(height: Dimensions.heightSize * 1),
                Button(
                  child: Text(
                    Strings.create.tr,
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                  onClick: () async{
                    if (!LocalStorage.isFreeUser()) {
                      if (LocalStorage.getHashTagCount() <
                          ApiConfig.premiumHashTagLimit) {
                        controller.process(context);


                      } else {
                        ToastMessage.error(
                            'Subscription Limit is over. Buy subscription again.');
                      }
                    } else {
                      if (LocalStorage.getHashTagCount() <
                          ApiConfig.freeHashTagLimit) {
                        controller.process(context);

                        debugPrint((controller.count.value % 2 ==0).toString());
                        if(controller.count.value % 2 ==0){
                          debugPrint("1");
                          AdManager.showIntAd();
                        }else{
                          debugPrint("2");
                        }

                      } else {
                        ToastMessage.error(
                            'Content Limit is over. Buy subscription.');
                      }
                    }
                  },
                ),
                SizedBox(height: Dimensions.heightSize * 1),
                const Divider(),
                Container()
              ],
            ),
    );
  }





  _countrySelectionTextAndInputWidget(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: Dimensions.defaultPaddingSize * .25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //diet duration
          Text(
            Strings.selectCountry.tr,
            style: TextStyle(
                fontSize: Dimensions.mediumTextSize * .8,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor),
          ),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: Dimensions.widthSize * .5),
            child: InputField(
              controller: controller.countryController,
              hintText: "Deutsch",
            ),
          ),
        ],
      ),
    );
  }
}