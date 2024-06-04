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

  // 生成多樣食譜列表
  Future<String?> requestRecipeList(String prompt, int people) async {
    String strPeople = people.toString();
    try {
      ChatRequest request = ChatRequest(model: "gpt-3.5-turbo", messages: [
        Message(
          role: "system",
          content:
              "根據食材: $prompt, 人數: $strPeople, 生成10種高蛋白質食譜名稱，食譜所用材料，只能採用告訴你的那些食材，不能多加其他食材。輸出格式為只要顯示食譜名稱就好。",
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

  // 食譜生成API
  Future<String?> request(String recipe, String prompt, int people) async {
    String strPeople = people.toString();
    try {
      ChatRequest request = ChatRequest(model: "gpt-3.5-turbo", messages: [
        Message(
          role: "system",
          content:
              "請根據以下資訊生成食譜內容:\n食譜名稱: $recipe\n食材: $prompt\n人數: $strPeople 人份\n請先顯示食譜名稱(不要顯示食譜編號)、再顯示食材用量,然後再條列顯示製作步驟(包含調味料的用量)。",
          // content: "先顯示食譜名稱。再顯示食材的用量為多少，請一定要說明食材要用多少份量" +
          //     strPeople +
          //     "人份。偏好高蛋白質。請僅用下列食材，編號條列產生製作過程(含調味料的份量)。" +
          //     prompt,
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
