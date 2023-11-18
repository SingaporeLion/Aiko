import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatContextManager {
  List<Map<String, dynamic>> messages = [];
  String? userName;
  int? userAge;
  String? userGender;
  bool isInitialContextSet = false;

  final String apiURL = 'https://api.openai.com/v1/chat/completions'; // Ersetzen Sie dies mit Ihrer tatsächlichen API-URL

  void setInitialContext(String name, int age, String gender) {
    this.userName = name;
    this.userAge = age;
    this.userGender = gender;
    isInitialContextSet = true;
  }

  Future<String> sendMessageToAPI(List<Map<String, dynamic>> messagesList) async {
    var response = await http.post(
      Uri.parse(apiURL),
      headers: {
        'Content-Type': 'application/json',
        // Fügen Sie hier weitere erforderliche Header hinzu
      },
      body: jsonEncode({
        'messages': messagesList, // Senden der Nachrichtenliste als JSON
        'userName': userName,
        'userAge': userAge,
        'userGender': userGender,
        // Fügen Sie hier ggf. weitere erforderliche Daten hinzu
      }),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data['response']; // Extrahieren Sie die Antwort aus der API-Antwort
    } else {
      throw Exception('Fehler beim Senden der Nachrichten an die API');
    }
  }

// Weitere Methoden und Logik Ihrer Klasse...
}