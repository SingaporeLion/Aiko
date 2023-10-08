import 'package:get/get.dart';

import '../helper/local_storage.dart';
import '../model/ai_type_model/ai_type_model.dart';

class SettingsController extends GetxController{
  late AiTypeModel typeModelData;

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  RxInt token = LocalStorage.getSelectedToken().obs;

  RxString selectedModel = LocalStorage.getSelectedModel().obs;
  List<String> modelData = [
    'gpt-3.5-turbo',
    'text-davinci-001',
    'text-davinci-002',
    'text-davinci-003',
    'text-ada-001',
    'text-curie-001',
    'text-babbage-001'
  ];

  RxString selectedImageType = LocalStorage.getSelectedImageType().obs;
  List<String> imageType = [
    '256x256',
    '512x512',
    '1024x1024'
  ];
}