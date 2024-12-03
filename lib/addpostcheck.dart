import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'db/db.dart'; // 資料庫服務

class AddPostCheckPage extends StatelessWidget {
  final Map<String, dynamic> recipe;

  AddPostCheckPage({required this.recipe});

  Future<void> _submitPost(BuildContext context) async {
    try {
      var conn = await DatabaseService().connection;

      // 插入貼文資料到資料庫
      await conn.query(
        '''
        INSERT INTO recipedb.posts (recipeID, postTime, tag) 
        VALUES (?, NOW(), ?)
        ''',
        [recipe['recipeId'], '新增貼文'], // 預設標籤
      );

      // 返回上一頁，並告知成功
      Navigator.pop(context, true);

      // 可選：顯示成功訊息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('貼文新增成功！')),
      );
    } catch (e) {
      print('新增貼文出錯: $e');

      // 可選：顯示失敗訊息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('新增貼文失敗，請稍後再試！')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('確認新增貼文'),
        backgroundColor: Color(0xFFF1E9E6),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顯示食譜圖片
            Image.network(
              recipe['imageUrl'],
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 16),
            // 顯示食譜名稱
            Text(
              recipe['recipeName'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            // 提交按鈕
            ElevatedButton(
              onPressed: () => _submitPost(context),
              child: Text('確認新增貼文'),
            ),
          ],
        ),
      ),
    );
  }
}
