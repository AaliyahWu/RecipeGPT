// this is chat_service.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_key.dart';
import 'chat_request.dart';
import 'chat_response.dart';

// this is chat_service.dart

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
      ChatRequest request = ChatRequest(model: "gpt-3.5-turbo", messages: [
        Message(
          role: "system",
          content: "先顯示食譜名稱。再顯示食材的用量為多少，請一定要說明食材要用多少份量" +
              strPeople +
              "人份。偏好高蛋白質。請僅用下列食材，編號條列產生製作過程(含調味料的份量)。" +
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

// class ChatService {
//   static final Uri chatUri =
//       Uri.parse('https://api.openai.com/v1/chat/completions');

//   static final Map<String, String> headers = {
//     'Content-Type': 'application/json',
//     'Authorization': 'Bearer ${ApiKey.openAIApiKey}',
//   };

//   Future<String?> request(String prompt, int people) async {
//     String strPeople = people.toString();

//     try {
//       ChatRequest request = ChatRequest(
//           model: "gpt-3.5-turbo",
//           // maxTokens: 150,
//           messages: [
//             Message(
//               role: "system",
//               // people: people,
//               content: "先顯示食譜名稱。" +
//                   strPeople +
//                   "2人份。偏好高蛋白質。請僅用下列食材，編號條列產生製作過程(含調味料的份量)。" +
//                   prompt,
//             )
//           ]);

//       if (prompt.isEmpty) {
//         return null;
//       }
//       http.Response response = await http.post(
//         chatUri,
//         headers: headers,
//         body: request.toJson(),
//       );
//       ChatResponse chatResponse = ChatResponse.fromResponse(response);
//       print(chatResponse.choices?[0].message?.content);
//       return chatResponse.choices?[0].message?.content;
//     } catch (e) {
//       print("error $e");
//     }
//     return null;
//   }
// }
