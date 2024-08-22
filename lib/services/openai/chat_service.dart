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
  Future<String?> requestRecipeList(String prompt, int people, String preference) async {
    String strPeople = people.toString();
    try {
      ChatRequest request = ChatRequest(model: "gpt-3.5-turbo", messages: [
        Message(
          role: "system",
          content:
              "下列三項資訊，食材: $prompt, 人數: $strPeople, 飲食偏好:$preference。請根據食材生成10種食譜名稱，輸出格式為只要顯示食譜名稱就好，食譜名稱前面不要有數字。",
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
  Future<String?> request(String recipe, String prompt, int people, String preferences) async {
    String strPeople = people.toString();
    // gpt-3.5-turbo
    try {
      ChatRequest request = ChatRequest(model: "gpt-3.5-turbo", messages: [
        Message(
          role: "system",
          content:
              "請根據以下資訊生成食譜內容:\n食譜名稱: $recipe\n食材: $prompt\n人數: $strPeople 人份\飲食偏好: $preferences\n。食譜所用食材，只能採用告訴你的那些食材，不能多加其他食材。請先顯示食譜名稱(不要顯示食譜編號)、再顯示食材用量,然後再條列顯示製作步驟(包含調味料的用量)。",
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

