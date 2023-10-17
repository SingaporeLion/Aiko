import 'dart:convert';
import 'dart:math';
import '/widgets/api/toast_message.dart';
import 'package:http/http.dart' as http;

import '../helper/local_storage.dart';

class ApiServices {
  // Ersetzen Sie YOUR_API_KEY durch Ihren tatsächlichen API-Schlüssel oder laden Sie ihn aus einer sicheren Quelle.
  static const String _apiKey = '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';

  static Future<String> generateResponse2(dynamic input) async {
    var url = Uri.https("api.openai.com", "/v1/chat/completions");
    Map<String, dynamic> requestBody;

    if (input is String) {
      // Verarbeiten Sie die Eingabe als einzelnen String
      requestBody = {
        "model": "gpt-3.5-turbo",
        "prompt": input,
        "max_tokens": 150
      };
    } else if (input is List<Map<String, dynamic>>) {
      // Verarbeiten Sie die Eingabe als Nachrichtenliste
      requestBody = {
        "model": "gpt-3.5-turbo",
        "messages": input
      };
    } else {
      throw ArgumentError('Unsupported input type');
    }

    // Wenn die Eingabe eine Liste ist, nehmen Sie nur die letzte Nachricht (oder die letzten paar Nachrichten)
    if (input is List<Map<String, dynamic>>) {
      List<Map<String, dynamic>> recentMessages = input.sublist(max(0, input.length - 2));
      requestBody["messages"] = recentMessages; // Setzen Sie recentMessages hier
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $_apiKey"
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> newresponse = jsonDecode(utf8.decode(response.bodyBytes));

      // Überprüfen Sie, ob die Antwort die erwarteten Daten enthält
      if (newresponse != null &&
          newresponse.containsKey('choices') &&
          newresponse['choices'].isNotEmpty &&
          newresponse['choices'][0].containsKey('message') &&
          newresponse['choices'][0]['message'].containsKey('content')) {
        return newresponse['choices'][0]['message']['content'];
      } else {
        throw Exception('Unexpected response structure from OpenAI API');
      }
    } else {
      throw Exception('Failed to fetch response from OpenAI API with status code: ${response.statusCode}');
    }
  }
}
