import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../helper/local_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../helper/notification_helper.dart';
import '../helper/unity_ad.dart';
import '../model/chat_model/chat_model.dart';
import '../model/user_model/user_model.dart';
import '../services/api_services.dart';
import '../utils/strings.dart';
import 'main_controller.dart';

class ChatController extends GetxController {
  Timer? timer;

  late List<QueryDocumentSnapshot<Map<String, dynamic>>> suggestedData;

  @override

  void onInit() {
    getSuggestedCategory();

    NotificationHelper.initInfo();

    speech = stt.SpeechToText();
    LocalStorage.isLoggedIn() ? _getUserData() : _setGesutUser();

    count.value = LocalStorage.getTextCount();

    super.onInit();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await AdManager.loadUnityIntAd();
      // await AdManager.loadUnityRewardedAd();
    });
  }

  final chatController = TextEditingController();
  final scrollController = ScrollController();

  // final RxList messages = <ChatMessage>[].obs;
  Rx<List<ChatMessage>> messages = Rx<List<ChatMessage>>([]);
  List<String> shareMessages = [
    '--THIS IS CONVERSATION with ${Strings.appName}--\n\n'
  ];
  RxInt itemCount = 0.obs;
  RxInt voiceSelectedIndex = 0.obs;
  RxBool isLoading = false.obs;
  RxBool isLoading2 = false.obs;

  late UserModel userModel;

  final List<String> moreList = [
    Strings.regenerateResponse.tr,
    Strings.clearConversation.tr,
    Strings.share.tr,
    Strings.changeTextModel.tr,
  ];
  void addTextCount() {
    // Hier den Code einfügen, der die Textanzahl erhöht oder aktualisiert.
    count.value += 1; // Als einfaches Beispiel, um den Zähler zu erhöhen.
  }

  void proccessChat() async {
    speechStopMethod();
    addTextCount();

    // Benutzernachricht hinzufügen
    messages.value.add(
      ChatMessage(
        text: chatController.text,
        chatMessageType: ChatMessageType.user,
      ),
    );
    shareMessages.add("${chatController.text} - Myself\n");
    itemCount.value = messages.value.length;

    // Fügen Sie eine temporäre Nachricht hinzu, die anzeigt, dass die KI tippt
    messages.value.add(
      ChatMessage(
        text: "Lynn's Zauberhut ist auf... Antwort kommt gleich!",
        chatMessageType: ChatMessageType.bot,
      ),
    );
    update();  // Aktualisieren Sie den Zustand

    isLoading.value = true;

    var input = chatController.text;
    textInput.value = chatController.text;
    chatController.clear();
    update();

    Future.delayed(const Duration(milliseconds: 50)).then((_) => scrollDown());
    update();

    debugPrint("---------------S------------------");
    debugPrint("SEND TEXT");
    debugPrint(input);
    debugPrint(input);
    debugPrint("---------------E------------------");

    // Fügen Sie hier die Verzögerung ein
    await Future.delayed(Duration(seconds: 1));

    _apiProcess(input);

    chatController.clear();

    update();
  }

  void _apiProcess(String input) {
    if (LocalStorage.getSelectedModel() == 'gpt-3.5-turbo') {
      ApiServices.generateResponse2(input).then((value) {
        // Überprüfen Sie, ob der Wert null oder leer ist
        if (value == null || value.trim().isEmpty) {
          debugPrint("API Response is null or empty");
          return; // Beenden Sie die Methode, wenn der Wert null oder leer ist
        }

        isLoading.value = false;
        debugPrint("---------------Chat Response------------------");
        debugPrint("RECEIVED");
        debugPrint(value);
        debugPrint("---------------END------------------");

        // Entfernen Sie die temporäre Nachricht
        messages.value.removeLast();

        // Fügen Sie die KI-Antwort hinzu
        messages.value.add(
          ChatMessage(
            text: value.replaceFirst("\n", " ").replaceFirst("\n", " "),
            chatMessageType: ChatMessageType.bot,
          ),
        );
        update();  // Aktualisieren Sie den Zustand

        shareMessages.add("${value.replaceFirst("\n", " ").replaceFirst("\n", " ")} -By BOT\n");
        Future.delayed(const Duration(milliseconds: 50)).then((_) => scrollDown());
        itemCount.value = messages.value.length;
      });
    } else {
      ApiServices.generateResponse2(input).then((value) {
        // Überprüfen Sie, ob der Wert null oder leer ist
        if (value == null || value.trim().isEmpty) {
          debugPrint("API Response is null or empty");
          return; // Beenden Sie die Methode, wenn der Wert null oder leer ist
        }

        isLoading.value = false;

        // Entfernen Sie die temporäre Nachricht
        messages.value.removeLast();

        // Fügen Sie die KI-Antwort hinzu
        messages.value.add(
          ChatMessage(
            text: value.replaceFirst("\n", " ").replaceFirst("\n", " "),
            chatMessageType: ChatMessageType.bot,
          ),
        );
        update();  // Aktualisieren Sie den Zustand

        debugPrint("---------------Chat Response------------------");
        debugPrint("RECEIVED");
        debugPrint(value);
        debugPrint("---------------END------------------");

        shareMessages.add("${value.replaceFirst("\n", " ").replaceFirst("\n", " ")} -By BOT\n");
        Future.delayed(const Duration(milliseconds: 50)).then((_) => scrollDown());
        itemCount.value = messages.value.length;
      });
    }
  }

  RxString textInput = ''.obs;

  void proccessChat2() async {
    speechStopMethod();

    addTextCount();
    messages.value.add(
      ChatMessage(
        text: "Lynn's Zauberhut ist auf... die Antwort kommt gleich!",
        chatMessageType: ChatMessageType.bot,
      ),
    );
    shareMessages.add('${Strings.regeneratingResponse.tr} -Myself\n');
    itemCount.value = messages.value.length;
    isLoading.value = true;

    update();

    Future.delayed(const Duration(milliseconds: 50)).then((_) => scrollDown());
    update();

    _apiProcess(textInput.value);

    chatController.clear();
    update();
  }

  void scrollDown() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  RxString userInput = "".obs;
  RxString result = "".obs;

  //  on Init  speech = stt.SpeechToText();

  RxBool isListening = false.obs;

  var languageList = LocalStorage.getLanguage();

  late stt.SpeechToText speech;

  void listen(BuildContext context) async {
    speechStopMethod();

    chatController.text = '';
    result.value = '';
    userInput.value = '';
    if (isListening.value == false) {
      bool available = await speech.initialize(
        onStatus: (val) => debugPrint('*** onStatus: $val'),
        onError: (val) => debugPrint('### onError: $val'),
      );
      if (available) {
        isListening.value = true;
        speech.listen(
            localeId: languageList[0],
            onResult: (val) {
              chatController.text = val.recognizedWords.toString();
              userInput.value = val.recognizedWords.toString();
            });
      }
    } else {
      isListening.value = false;
      speech.stop();
      update();
    }
  }

  final FlutterTts flutterTts = FlutterTts();

  final _isSpeechLoading = false.obs;

  bool get isSpeechLoading => _isSpeechLoading.value;

  final _isSpeech = false.obs;

  bool get isSpeech => _isSpeech.value;

  speechMethod(String text, String language) async {
    _isSpeechLoading.value = true;
    _isSpeech.value = true;
    update();

    await flutterTts.setLanguage(language);
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.45);
    await flutterTts.speak(text);

    Future.delayed(
        const Duration(seconds: 2), () => _isSpeechLoading.value = false);
    update();
  }

  speechStopMethod() async {
    _isSpeech.value = false;
    await flutterTts.stop();
    update();
  }

  clearConversation() {
    speechStopMethod();
    messages.value.clear();
    shareMessages.clear();
    shareMessages.add('--THIS IS CONVERSATION with ${Strings.appName}--\n\n');
    textInput.value = '';
    itemCount.value = 0;
    speechStopMethod();
    update();
  }

  _getUserData() async {
    final FirebaseAuth userAuth =
        FirebaseAuth.instance; // firebase instance/object

    // Get the user form the firebase
    User? user = userAuth.currentUser;

    UserModel userData = UserModel(
        name: user!.displayName ?? "",
        uniqueId: user.uid,
        email: user.email ?? '',
        phoneNumber: user.phoneNumber ?? "",
        isActive: true,
        imageUrl: user.photoURL ?? "");

    userModel = userData;

    messages.value.add(
      ChatMessage(
        text: '${Strings.hello.tr} ${userData.name}',
        chatMessageType: ChatMessageType.bot,
      ),
    );
    shareMessages
        .add("${Strings.hello.tr} ${userData.name} -By ${Strings.appName}\n");

    Future.delayed(const Duration(milliseconds: 50)).then((_) => scrollDown());
    itemCount.value = messages.value.length;
    update();
  }

  void _setGesutUser() async {
    // Get the user form the firebase

    UserModel userData = UserModel(
        name: "Guest",
        uniqueId: '',
        email: '',
        phoneNumber: '',
        isActive: false,
        imageUrl: '');

    userModel = userData;

    messages.value.add(
      ChatMessage(
        text: Strings.helloGuest.tr,
        chatMessageType: ChatMessageType.bot,
      ),
    );
    shareMessages.add("${Strings.helloGuest.tr} -By ${Strings.appName}\n\n");

    Future.delayed(const Duration(milliseconds: 50)).then((_) => scrollDown());
    itemCount.value = messages.value.length;
    update();
  }

  void shareChat(BuildContext context) {
    debugPrint(shareMessages.toString());
    Share.share("${shareMessages.toString()}\n\n --CONVERSATION END--",
        subject: "I'm sharing Conversation with ${Strings.appName}");
  }

  final FirebaseAuth _auth = FirebaseAuth.instance; // firebase instance/object
  User get user => _auth.currentUser!;
  RxInt count = 0.obs;


  getSuggestedCategory() async {
    isLoading2.value = true;
    update();

    final QuerySnapshot<Map<String, dynamic>> userDoc =
    await FirebaseFirestore.instance.collection('suggested_category').get();

    suggestedData = userDoc.docs;

    debugPrint(userDoc.docs.toString());
    debugPrint(userDoc.docs.length.toString());

    isLoading2.value = false;
    update();
  }
}