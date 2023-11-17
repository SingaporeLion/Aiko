import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class ChatContextManager {
  List<Map<String, dynamic>> messages = [];
  String? userName;
  int? userAge;
  String? userGender;
  bool isInitialContextSet = false;

  void setInitialContext(String name, int age, String gender) {
    userName = name;
    userAge = age;
    userGender = gender;
    isInitialContextSet = true;
  }

  void logMessage(String message) {
    final timestamp = DateTime.now().toIso8601String();
    debugPrint("[$timestamp] $message");
  }

  void addMessage(String role, String content) {
    messages.add({"role": role, "content": content});
    if (messages.length > 90) {
      messages.removeAt(0); // Hält die Liste auf 90 Nachrichten beschränkt
    }
    logMessage("Nachricht hinzugefügt: Rolle: $role, Inhalt: $content");
  }

  Future<String> sendMessageToAPI(String userMessage) async {
    logMessage("API-Anfrage: $userMessage");

    if (!isInitialContextSet) {
      messages.insert(0, {"role": "system", "content": "Benutzer ist $userName, Alter $userAge, Geschlecht $userGender"});
      isInitialContextSet = true;
    }

    addMessage("user", userMessage);

    var url = Uri.parse('https://api.openai.com/v1/chat/completions');
    var headers = {
      'Content-Type': 'application/json',
      "Authorization": "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"
    };
    var body = json.encode({"model": "ft:gpt-3.5-turbo-1106:personal::8JRC1Idj", "messages": messages});

    var response = await http.post(url, headers: headers, body: body);
    logMessage("API-Antwort Status: ${response.statusCode}");

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      logMessage("API-Antwort Inhalt: ${responseData['choices'][0]['message']['content']}");

      addMessage("assistant", responseData['choices'][0]['message']['content']);
      return responseData['choices'][0]['message']['content'];
    } else {
      logMessage("API-Fehler: ${response.statusCode}");
      throw Exception('Fehler beim Senden der Anfrage: ${response.statusCode}');
    }
  }
}