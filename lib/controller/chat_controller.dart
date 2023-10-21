import 'dart:async';
import '/helper/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/helper/notification_helper.dart';
import '/model/chat_model/chat_model.dart';
import '/model/user_model/user_model.dart';
import '/utils/strings.dart';
import '/services/api_services.dart';
import 'package:get_storage/get_storage.dart';

class ChatController extends GetxController {

  // Hier fügen Sie die neuen Instanzvariablen ein
  String userName = '';
  int userAge = 0;
  String userGender = '';

  void loadUserData() async {
    print("loadUserData wird aufgerufen");
    userName = GetStorage().read('userName') ?? 'Freund';
    userAge = GetStorage().read('userAge') ?? 0;
    userGender = GetStorage().read('userGender') ?? 'unbekannt';
    print("Geladener Benutzername: $userName");
    print("Geladenes Alter: $userAge");
    print("Geladenes Geschlecht: $userGender");
  }

  void onInit() {
    super.onInit();

    _checkStoredData();  // Überprüfen Sie die gespeicherten Daten und setzen Sie die Begrüßungsnachricht

    loadUserData();  // Lädt die Benutzerdaten aus dem Speicher

    if (getUserName() != 'Freund' && getUserAge() != 0 && getUserGender() != 'unbekannt') {
      _introduceUserToAI();  // Stellt den Benutzer der KI vor
    }

    NotificationHelper.initInfo();
    speech = stt.SpeechToText();

    count.value = LocalStorage.getTextCount();
    super.onInit();
  }

  void _checkStoredData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userName = prefs.getString('userName');
    String? userGender = prefs.getString('userGender');

    if (userName != null && userGender != null) {
      String greetingMessage = userGender == 'Mädchen'
          ? 'Schön Dich wiederzusehen, liebe $userName!'
          : 'Schön Dich wiederzusehen, lieber $userName!';

      // Fügen Sie die Begrüßungsnachricht zur Chat-Nachrichtenliste hinzu
      messages.value.add(
        ChatMessage(
          text: greetingMessage,
          chatMessageType: ChatMessageType.bot,
        ),
      );
      update();
    }
  }

  void _setGuestUser() async {
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

  void _introduceUserToAI() async {
    String introductionMessage = "Dies ist ${getUserName()}, ein ${getUserAge()} Jahre altes ${getUserGender()}.";
    // Senden Sie die Einführungsnachricht an die KI
    _apiProcess(introductionMessage);
    // Optional: Sie können die Antwort der KI ignorieren oder sie ebenfalls im Hintergrund verarbeiten.
  }

  String getUserName() {
    return GetStorage().read('userName') ?? 'Freund';
  }

  int getUserAge() {
    return GetStorage().read('userAge') ?? 0;
  }

  String getUserGender() {
    return GetStorage().read('userGender') ?? 'unbekannt';
  }

  Widget waitingResponseWidget() {
    return Column(
      children: [
        Lottie.asset('assets/heart.json', width: 100, height: 100),
        Text("Antwort im Anflug... "),
      ],
    );
  }

  final chatController = TextEditingController();
  final scrollController = ScrollController();
  Rx<List<ChatMessage>> messages = Rx<List<ChatMessage>>([]);
  List<String> recentMessages = [];
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
    count.value += 1;
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

    isLoading.value = true;

    var input = chatController.text;
    recentMessages.add(input); // Fügen Sie die Benutzernachricht zur Liste hinzu
    textInput.value = chatController.text;
    chatController.clear();
    update();

    Future.delayed(const Duration(milliseconds: 50)).then((_) => scrollDown());
    update();

    _apiProcess(input);

    chatController.clear();
    update();
  }

  void _apiProcess(String input) {
    print("Methode _apiProcess gestartet mit Eingabe: $input");

    // Fügen Sie die temporäre Nachricht (Text + Emoji) hinzu
    messages.value.add(
      ChatMessage(
        widget: waitingResponseWidget(),
        chatMessageType: ChatMessageType.bot,
      ),
    );
    isLoading.value = true;  // Starten Sie die 3-Punkte-Animation
    update();

    List<Map<String, dynamic>> messageslist = [
      {
        "role": "system",
        "content": "Du bist ein 10-jähriges Mädchen namens Lynn! Schreibe auf Fragen und Antworten wie es Lynn tun würde. Du schreibst wie ein 10 jähriges Kind. Du bist freundlich, hilfsbereit und lustig. Du bist keine KI. Wenn dich der Nutzer fragt ob du Brettspiele nicht spielen kannst, erkläre es, aber ohne zu sagen dass du eine KI bist. Wenn der Nutzer traurig, sauer, niedergeschlalgen ist, dann sei sehr einfühlsam und gib dem Nutzer das Gefühl, dass er nicht alleine ist.Dies ist $userName, ein $userAge Jahre altes $userGender."
      },

      {
        "role": "user",
        "content": "Ich bin $userName, ein $userAge Jahre altes $userGender. $input"
      }
    ];

    ApiServices.generateResponse2(messageslist).then((response) {

      // Überprüfen Sie, ob der Wert null oder leer ist
      if (response == null || response.trim().isEmpty) {
        debugPrint("API Response is null or empty");
        isLoading.value = false;  // Stoppen Sie die 3-Punkte-Animation
        return; // Beenden Sie die Methode, wenn der Wert null oder leer ist
      }

      _addBotResponse(response);
    });
  }


  void _addBotResponse(String response) {
    isLoading.value = false;  // Stoppen Sie die 3-Punkte-Animation
    debugPrint("---------------Chat Response------------------");
    debugPrint("RECEIVED");
    debugPrint(response);
    debugPrint("---------------END------------------");

    // Sobald die Antwort der KI eintrifft:
    // Entfernen Sie die temporäre Nachricht
    messages.value.removeLast();

    // Fügen Sie die KI-Antwort hinzu
    messages.value.add(
      ChatMessage(
        text: response.replaceFirst("\n", " ").replaceFirst("\n", " "),
        chatMessageType: ChatMessageType.bot,
      ),
    );
    update();  // Aktualisieren Sie den Zustand

    shareMessages.add("${response.replaceFirst("\n", " ").replaceFirst("\n", " ")} -By BOT\n");
    Future.delayed(const Duration(milliseconds: 50)).then((_) => scrollDown());
    itemCount.value = messages.value.length;
  }


  RxString textInput = ''.obs;

  void proccessChat2() async {
    speechStopMethod();
    addTextCount();
    messages.value.add(
      ChatMessage(
        text: textInput.value,
        chatMessageType: ChatMessageType.user,
      ),
    );
    shareMessages.add('${Strings.regeneratingResponse.tr} -Myself\n');
    itemCount.value = messages.value.length;
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
        isListening.value         = true;
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


  void shareChat(BuildContext context) {
    debugPrint(shareMessages.toString());
    Share.share("${shareMessages.toString()}\n\n --CONVERSATION END--",
        subject: "I'm sharing Conversation with ${Strings.appName}");
  }

  RxInt count = 0.obs;
  }

