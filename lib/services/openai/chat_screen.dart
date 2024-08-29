// this is chat_screen.dart

import 'package:flutter/material.dart';
import 'chat_service.dart';
import 'package:recipe_gpt/homepage.dart'; // 假設HomePage的widget在homepage.dart中定義
import '/db/db.dart';

class ChatPage extends StatefulWidget {
  final String prompt;
  final int people;
  final String recipe;
  final int accountId;
  final String preferences;

  ChatPage({required this.accountId, required this.preferences, required this.prompt, required this.people, required this.recipe});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String _chatResponse = '';
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _startChat(widget.recipe, widget.prompt, widget.people, widget.preferences);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1E9E6),
        title: Text('生成食譜'),
      ),
      backgroundColor: Color(0xFFF1E9E6),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 0.8),
                    image: DecorationImage(
                        image: AssetImage('assets/image/note.jpg'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.5),
                          BlendMode.dstATop,
                        ),
                      ),
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: 1,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Center(
                          child: Text(
                            _chatResponse.isNotEmpty
                                ? _chatResponse
                                : '食譜生成中...',
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0), // 添加一些間隔
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor  : Color(0xFFF2B892), // 背景顏色
                    foregroundColor : Colors.white, // 文字顏色
                  ),
                  onPressed: () {
                    // 導航回首頁
                    Navigator.pushAndRemoveUntil(
                      context,
                      // MaterialPageRoute(builder: (context) => HomePage(accountId: widget.accountId)),
                      MaterialPageRoute(builder: (context) => HomePage()),//測試新登入模組
                      (route) => false,
                    );
                  },
                  child: Text('完成'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor  : Color(0xFFF2B892), // 背景顏色
                    foregroundColor : Colors.white, // 文字顏色
                  ),
                  onPressed: () {
                    // 分享食譜
                    // Share.share(_chatResponse);
                  },
                  child: Text('分享'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  void _startChat(String recipe, String prompt, int people, String preferences) async {
    String? response = await ChatService().request(recipe, prompt, people, preferences);
    setState(() {
       // 確保 response 不為
      _chatResponse = response ?? 'No response';
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });

    // 如果有 response，保存到数据库
    if (response != null && response.isNotEmpty) {
      await _saveRecipeToDatabase(widget.accountId, recipe, response);
    }

  }

  // 新增這個方法，用來存儲食譜到資料庫
  Future<void> _saveRecipeToDatabase(int accountId, String recipeName, String recipeText) async {
    try {
      var conn = await DatabaseService().connection;

      // // 从第四个字符开始截取 recipeName
      // String truncatedRecipeName = recipeName.length > 3 ? recipeName.substring(0) : '';

      // 插入新的食譜記錄到 `recipes` 表
      await conn.query(
        'INSERT INTO recipedb.recipes (accountId, recipeName, recipeText, createDate) VALUES (?, ?, ?, NOW())',
        [accountId, recipeName, recipeText],
      );

      print('食譜成功保存到資料庫中');
    } catch (e) {
      print('保存食譜到資料庫時出錯: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
