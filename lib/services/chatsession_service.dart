import 'package:http/http.dart' as http;
import 'dart:convert';

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

  void addMessage(String role, String content) {
    messages.add({"role": role, "content": content});
    if (messages.length > 90) {
      messages.removeAt(0); // Hält die Liste auf 90 Nachrichten beschränkt
    }
  }

  Future<String> sendMessageToAPI(String userMessage) async {
    if (!isInitialContextSet) {
      // Initialisiere den Kontext mit Benutzerdaten
      messages.insert(0, {"role": "system", "content": "Benutzer ist $userName, Alter $userAge, Geschlecht $userGender"});
      isInitialContextSet = true;
    }

    addMessage("user", userMessage);

    var url = Uri.parse('Ihre-ChatGPT-API-URL');
    var headers = {
      'Content-Type': 'application/json',
      "Authorization": "Ihr-API-Schlüssel"
    };
    var body = json.encode({"model": "gpt-3.5-turbo", "messages": messages});

    var response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      addMessage("assistant", responseData['choices'][0]['message']['content']);
      return responseData['choices'][0]['message']['content'];
    } else {
      throw Exception('Fehler beim Senden der Anfrage: ${response.statusCode}');
    }
  }
}
