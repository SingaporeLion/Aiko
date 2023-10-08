import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../helper/unity_ad.dart';
import '../services/api_services.dart';
import '../utils/strings.dart';
import '../views/pdf_view_screen.dart';
import '../widgets/api/toast_message.dart';

import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;


class DietChartController extends GetxController {

  @override
  void onInit() {
    super.onInit();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await AdManager.loadUnityIntAd();
      // await AdManager.loadUnityRewardedAd();
    });
  }
  late String firebaseUrl ;
  late String pdfFileName;
  String selectGenderHintText = 'Select Gender';
  Rx<String?> selectedGender = Rx<String?>(null);
  RxInt count = 0.obs;

  var genderList = [
    'Male',
    'Female',
  ];
  RxBool isGenderSelected = RxBool(false);

  String selectLifeStyleHintText = 'Select Life Style';
  Rx<String?> selectedLifeStyle = Rx<String?>(null);
  var selectedLifeStyleList = [
    'sedentary',
    'Lightly Active',
    'Moderately Active',
    'Very Active',
    'Extra Active'
  ];
  RxBool isLifeStyleSelected = RxBool(false);

  final currentWeightController = TextEditingController();
  final targetWeightController = TextEditingController();
  final heightController = TextEditingController();
  final dietDurationController = TextEditingController();
  final countryController = TextEditingController();

  RxBool isLoading = false.obs;
  RxString textResponse = ''.obs;
  RxList<int> pdfBytes = RxList<int>([]);

  bool genderValidate() {
    return selectedGender.value != null;
  }

  bool lifeStyleValidate() {
    return selectedLifeStyle.value != null;
  }

  Future<void> process(BuildContext context) async {
    if (genderValidate() && lifeStyleValidate()) {
      if (currentWeightController.text.isNotEmpty &&
          targetWeightController.text.isNotEmpty &&
          heightController.text.isNotEmpty &&
          dietDurationController.text.isNotEmpty) {
        // Perform form processing here

        debugPrint("========>Test print of data #sayem<==========");

        debugPrint(
            "current weight: ${currentWeightController.text}, target weight: ${targetWeightController.text} , height: ${heightController.text}, diet Duration: ${dietDurationController.text} , Gender: ${selectedGender.value}, LifeStyle: ${selectedLifeStyle.value} ");
        processChat(context);
      } else {
        ToastMessage.error("Fill out all the fields");
      }
    } else {
      if (!genderValidate()) {
        ToastMessage.error("Please select a gender");
      } else if (!lifeStyleValidate()) {
        ToastMessage.error("Please select a lifestyle");
      }
    }
  }

  void processChat(BuildContext context) async {
    isLoading.value = true;

    var input =
        "${Strings.createDietChart.tr} ${Strings.nowWeight.tr}  ${currentWeightController.text} ${Strings.kg.tr} ${Strings.expectedWeight.tr} ${targetWeightController.text} ${Strings.kg.tr} ${Strings.heightIs.tr} ${heightController.text} ${Strings.cm.tr}  ${Strings.myDietDuration.tr} ${dietDurationController.text} ${Strings.weeks.tr} ${Strings.iAmA.tr}  ${selectedGender.value ?? 'Male'} ${Strings.myLifestyle.tr}   ${selectedLifeStyle.value ?? 'Sedentary'}  ${Strings.basedOn.tr} ${countryController.text} ${Strings.food.tr}  ";
    debugPrint("printing the input in the controller");
    debugPrint(input);



    update();

    _apiProcess(input, context);

    update();
  }

  _apiProcess(String input, context) async {
    await ApiServices.generateResponse2(input)
        .then((value) {
      textResponse.value = "";
      isLoading.value = true;
      update();
      debugPrint("---------------Content Response------------------");
      debugPrint("RECEIVED");

      debugPrint("=========> printing response of chat gpt<=========");
      debugPrint(value);
      textResponse.value = value.replaceAll("#", "\n#");
      update();
      debugPrint("---------------END------------------");

      count.value ++;

       generatePdf(context, response: textResponse.value);
    });
  }

  Future<void> generatePdf(context, {required String response}) async {
    isLoading.value = true;
    update();
    final PdfDocument document = PdfDocument();
    final PdfPage page = document.pages.add();
    final PdfTextElement textElement = PdfTextElement();
    textElement.text = response;
    textElement.font = PdfStandardFont(PdfFontFamily.helvetica, 12);
    final PdfLayoutResult? result = textElement.draw(
      page: page,
      bounds: Rect.fromLTWH(0, 0, MediaQuery.of(context).size.width * .95,
          MediaQuery.of(context).size.height * .90),
    );
    if (result != null) {
      result.page.graphics.drawString(
        Strings.pdfHeader.tr,
        PdfStandardFont(PdfFontFamily.helvetica, 14),
        bounds: const Rect.fromLTWH(0, 0, 500, 50),
      );
    }
    pdfBytes.value = await document.save();


    // Upload PDF to Firebase Storage
    String downloadUrl = await uploadInFirebase(Uint8List.fromList(pdfBytes));
    debugPrint("========>Download Url<==========");
    debugPrint(downloadUrl);
    isLoading.value = false;
    Get.to(PdfViewScreen(pdfBytes: pdfBytes.toList()));
    //clear the data from the field
    currentWeightController.clear();
    targetWeightController.clear();
    heightController.clear();
    dietDurationController.clear();
    countryController.clear();
    selectedGender.value = null;
    selectedLifeStyle.value = null;
    update();
    document.dispose();

    isLoading.value = false;
    Get.to(PdfViewScreen(pdfBytes: pdfBytes.toList()));
    update();
    document.dispose();



  }
  Future<String> uploadInFirebase(Uint8List pdfBytes) async {
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}.pdf';
    //kept the file name in global variable pdfFilename
    pdfFileName = fileName;
    final firebase_storage.Reference dietChartPdf =
    firebase_storage.FirebaseStorage.instance.ref('dietChartPdf/$fileName');

    await dietChartPdf.putData(pdfBytes);

    final String downloadUrl = await dietChartPdf.getDownloadURL();
    debugPrint(downloadUrl);
    firebaseUrl = downloadUrl;
    return downloadUrl;
  }


  clearConversation() {
    textResponse.value = '';
    update();
  }

  Future<void> downloadFile( ) async {
    late final Map<Permission, PermissionStatus> status;

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        status = await [Permission.storage].request();
      } else {
        status = await [Permission.photos].request();
      }
    } else {
      status = await [Permission.photosAddOnly].request();
    }

    var allAccept = true;
    status.forEach((permission, status) {
      if (status != PermissionStatus.granted) {
        allAccept = false;
      }
    });

    if (allAccept) {
      downloadPDF(
        url: firebaseUrl,

      );
    }
  }

  Future<void> downloadPDF({required String url}) async {
    final http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Directory? downloadsDirectory;
      if (Platform.isIOS) {
        downloadsDirectory = await getDownloadsDirectory();
      } else {
        String directory;
        if (Platform.isAndroid) {
          directory = "/storage/emulated/0/";
          final bool dirDownloadExists = await Directory("$directory/Download").exists();
          directory += dirDownloadExists ? "Download/" : "Downloads/";
        } else {
          // Handle other platforms here, if applicable
          return;
        }
        downloadsDirectory = Directory(directory);
      }
      final File file = File('${downloadsDirectory!.path}/$pdfFileName');
      await file.writeAsBytes(response.bodyBytes);

      ToastMessage.success('File downloaded successfully at ${file.path}!');
    } else {
      ToastMessage.error('Failed to download the file.');
    }
  }


}