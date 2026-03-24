import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey = "lib/services/gemini_service.dart";

  Future<String> sendMessage(String message) async {
    final url =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey";

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": message}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      return "Error: ${response.body}";
    }
  }
}