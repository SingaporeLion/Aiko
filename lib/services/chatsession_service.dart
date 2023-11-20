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