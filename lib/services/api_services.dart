import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

// Weitere notwendige Importe könnten hier stehen

class ApiServices {
  // Ihr API-Schlüssel
  static const String _apiKey = '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';

  // Struktur für Benutzerdaten (könnte an Ihre App angepasst werden)
  Map<String, dynamic> userData = {
    'name': 'Benutzername',
    'age': 'Benutzeralter',
    'gender': 'Benutzergeschlecht'
  };

  // Methode zum Senden von Nachrichten mit Benutzerdaten und Chatverlauf
  static Future<String> sendMessageWithUserDataAndHistory(String message, HiveChatStorage chatStorage, Map<String, dynamic> userData) async {
    List<Map<String, dynamic>> chatHistory = chatStorage.getLast90Messages();
    var payload = {
      'message': message,
      'userData': userData,
      'chatHistory': chatHistory
    };

    // Loggen, was an die API gesendet wird
    print('Sende an API: $payload');

    var url = Uri.parse('IHR_API_ENDPOINT');
    var response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey'
        },
        body: json.encode(payload));

    return response.body;
  }

  // Ursprüngliche generateResponse2 Methode
  static Future<String> generateResponse2(List<Map<String, dynamic>> messages) async {
    var url = Uri.https("api.openai.com", "/v1/chat/completions");
    Map<String, dynamic> requestBody = {
      "model": "ft:gpt-3.5-turbo-1106:personal::8JRC1Idj",
      "messages": messages
    };

    final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey'
        },
        body: json.encode(requestBody));

    if (response.statusCode == 200) {
      Map<String, dynamic> newResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (newResponse != null &&
          newResponse.containsKey('choices') &&
          newResponse['choices'].isNotEmpty &&
          newResponse['choices'][0].containsKey('message') &&
          newResponse['choices'][0]['message'].containsKey('content')) {
        return newResponse['choices'][0]['message']['content'];
      } else {
        throw Exception('Unexpected response structure from OpenAI API');
      }
    } else {
      throw Exception('Failed to fetch response from OpenAI API with status code: ${response.statusCode}');
    }
  }

// Weitere Methoden und Klassen könnten hier stehen
}

// Pseudo-Klasse für Hive-Speicheroperationen
class HiveChatStorage {
  final Box chatBox;

  HiveChatStorage(this.chatBox);

  void storeChatMessage(String message, bool isUserMessage, DateTime timestamp) {
    final chatMessage = {
      'message': message,
      'isUserMessage': isUserMessage,
      'timestamp': timestamp.toString()
    };
    chatBox.add(chatMessage);
  }

  List<Map<String, dynamic>> getLast90Messages() {
    return chatBox.values.toList().take(90).map((e) => Map<String, dynamic>.from(e)).toList();
  }
}

// Weitere Klassen und Methoden könnten hier stehen