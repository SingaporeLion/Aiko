import 'dart:convert';
import 'package:http/http.dart' as http;


class ApiServices {
  static const String _apiKey = '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'; // API-Schlüssel

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
}
// Weitere Klassen und Methoden könnten hier stehen