import 'dart:convert';

import '/widgets/api/toast_message.dart';
import 'package:http/http.dart' as http;

import '../helper/local_storage.dart';

class ApiServices {
  // Ersetzen Sie YOUR_API_KEY durch Ihren tatsächlichen API-Schlüssel oder laden Sie ihn aus einer sicheren Quelle.
  static const String _apiKey = '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';

  static Future<String> generateResponse2(String prompt) async {
    var url = Uri.https("api.openai.com", "/v1/chat/completions");
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $_apiKey"
      },
      body: json.encode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {
            "role": "user",
            "content": prompt
          }
        ]
      }),
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
