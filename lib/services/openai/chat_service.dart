import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_key.dart';
import 'chat_request.dart';
import 'chat_response.dart';

class ChatService {
  static final Uri chatUri =
      Uri.parse('https://api.openai.com/v1/chat/completions');

  static final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${ApiKey.openAIApiKey}',
  };

  Future<String?> request(String prompt, int people) async {
    String strPeople = people.toString();

    try {
      ChatRequest request = ChatRequest(
          model: "gpt-3.5-turbo",
          // maxTokens: 150,
          messages: [
            Message(
              role: "system",
              // people: people,
              content: "先顯示食譜名稱。" +
                  strPeople +
                  "人份。偏好增肌。請僅用下列食材，編號條列產生製作過程(含調味料的份量)。" +
                  prompt,
            )
          ]);

      if (prompt.isEmpty) {
        return null;
      }
      http.Response response = await http.post(
        chatUri,
        headers: headers,
        body: request.toJson(),
      );
      ChatResponse chatResponse = ChatResponse.fromResponse(response);
      print(chatResponse.choices?[0].message?.content);
      return chatResponse.choices?[0].message?.content;
    } catch (e) {
      print("error $e");
    }
    return null;
  }
}
