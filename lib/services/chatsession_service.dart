import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logging/logging.dart';

class ChatContextManager {
  final Logger _logger = Logger('ChatContextManager');
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
    String apiKey = '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';

    try {
      var response = await http.post(
        Uri.parse(apiURL),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'ft:gpt-3.5-turbo-1106:personal::8JRC1Idj', // Ersetzen Sie dies durch Ihr gewähltes Modell
          'messages': messagesList,
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return data['response'] ?? 'Keine Antwort von der API';
      } else {
        print('Fehler beim API-Aufruf: ${response.statusCode}');
        print('Antwort: ${response.body}');
        return 'Fehler beim Senden der Nachrichten an die API: ${response.body}'; // Gibt die genaue Fehlermeldung zurück
      }
    } catch (e) {
      print('Exception in sendMessageToAPI: $e');
      return 'Exception beim Senden der Nachrichten an die API: $e'; // Gibt die genaue Exception zurück
    }
  }

// Weitere Methoden und Logik Ihrer Klasse...
}