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
    Color backgroundColor = Color(0xFFF1E9E6);
    return Scaffold(
      appBar: AppBar(
        title: Text('確認新增貼文'),
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      backgroundColor: Colors.white, // 設置固定背景顏色
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 食譜圖片
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                recipe['imageUrl'], // 顯示食譜的圖片 URL
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16),
            // 食譜名稱
            Text(
              recipe['recipeName'], // 顯示食譜名稱
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            // 步驟標題
            Text(
              '食譜步驟：',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            // 滾動區域：顯示食譜步驟
            Expanded(
              child: Scrollbar(
                thickness: 8.0, // 滾動條厚度
                radius: Radius.circular(4.0), // 圓角
                thumbVisibility: true, // 始終顯示滾動條
                child: SingleChildScrollView(
                  child: Text(
                    recipe['recipeText'] ?? '步驟資訊未提供', // 若步驟為 null，提供預設值
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            // 提交貼文按鈕
            Center(
              child: ElevatedButton(
                onPressed: () => _submitPost(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 24.0),
                  child: Text(
                    '確認新增貼文',
                    style: TextStyle(fontSize: 18, color: Colors.white), // 白色文字
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFDD8A62), // 固定背景顏色
                  shadowColor: Colors.transparent, // 去除陰影
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
