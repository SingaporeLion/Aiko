import '../../widgets/api/custom_loading_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../controller/hash_tag_controller.dart';
import '../helper/local_storage.dart';
import '../helper/unity_ad.dart';
import '../utils/config.dart';
import '../utils/custom_color.dart';
import '../utils/dimensions.dart';
import '../utils/strings.dart';
import '../widgets/api/toast_message.dart';
import '../widgets/appbar/appbar_widget.dart';
import '../widgets/buttons/button.dart';
import '../widgets/inputs_widgets/input_field.dart';

class HashTagScreen extends StatelessWidget {
  HashTagScreen({Key? key}) : super(key: key);

  final controller = Get.put(HashTagController());

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
      appTitle: Strings.keyWordCreating.tr,
      onPressed: () {},
    );
  }

  _bodyWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _inputWidget(context),
          _buttonWidget(context),
          
          _responseDetailsWidget(context)
        ],
      ),
    );
  }

  _responseDetailsWidget(BuildContext context) {
    return Obx(() => Visibility(
      visible: controller.isResponseVisible.value,
      child: Expanded(
            child: Container(
              color: CustomColor.primaryColor.withOpacity(.1),
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.widthSize
              ),
              child: Stack(
                children: [
                  ListView(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      Obx(() => Text(
                          controller.textResponse.value,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor
                        ),
                      )),
                      SizedBox(height: Dimensions.heightSize),
                      SizedBox(height: Dimensions.heightSize),
                    ],
                  ),

                  Positioned(
                    top: 5,
                    right: 5,
                    child: InkWell(
                      child: Row(
                        children: [
                          Text(
                            Strings.copy.tr,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          SizedBox(width: Dimensions.widthSize * .5),
                          SvgPicture.asset(
                              "assets/icon/copy.svg",
                            // ignore: deprecated_member_use
                            color: Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                      onTap: (){
                        controller.copyResponse(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
    ));
  }

  _inputWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: Dimensions.heightSize * 1),
        Text(
          Strings.topic.tr,
          style: TextStyle(
              fontSize: Dimensions.mediumTextSize * .8,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimensions.widthSize * .5),
          child: InputField(
            controller: controller.textController,
            hintText: "Ex. Song",
          ),
        ),
      ],
    );
  }

  _buttonWidget(BuildContext context) {
    return Obx(() => controller.isLoading.value
        ? const CustomLoadingAPI()
        : Column(
            children: [
              SizedBox(height: Dimensions.heightSize * 1),
              Button(
                child: Text(
                  Strings.create.tr,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold
                  ),
                ),
                onClick: () async{
                  // if(controller.count.value % 2 ==0){
                  //    AdManager.showIntAd();
                  //   debugPrint((controller.count.value % 2 ==0).toString());
                  //   debugPrint('0');
                  // }else{
                  //   debugPrint('1');
                  // }
                  // AdManager.showIntAd();

                  if(!LocalStorage.isFreeUser()){
                    if(LocalStorage.getHashTagCount() < ApiConfig.premiumHashTagLimit){
                      process(context);

                    }else{
                      ToastMessage.error(
                          'Subscription Limit is over. Buy subscription again.');
                    }
                  }

                  else{
                    if(LocalStorage.getHashTagCount() < ApiConfig.freeHashTagLimit){
                      process(context);

                      debugPrint((controller.count.value % 2 ==0).toString());
                      if(controller.count.value % 2 ==0){
                        debugPrint("1");
                        AdManager.showIntAd();
                      }else{
                        debugPrint("2");
                      }


                    }else{
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
          ));
  }

  process(BuildContext context) {
    if(controller.textController.text.isNotEmpty){
      controller.processChat();
    }else{
      ToastMessage.error("Write Something");
    }
  }
}