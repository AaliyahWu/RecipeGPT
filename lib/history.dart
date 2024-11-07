import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:recipe_gpt/db/db.dart';

class HistoryPage extends StatefulWidget {
  final int recipeId;

  HistoryPage({required this.recipeId});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Map<String, dynamic>? recipeDetails;
  TextEditingController _remarkController = TextEditingController(); // 備註控制器

  @override
  void initState() {
    super.initState();
    _fetchRecipeDetails();
  }

  Future<void> _fetchRecipeDetails() async {
    try {
      var conn = await DatabaseService().connection;

      // 使用 recipeId 查詢食譜的詳細資料，包含 remark 欄位
      var result = await conn.query(
        'SELECT recipeName, recipeText, createDate, rating, url, remark FROM recipedb.recipes WHERE recipeId = ?',
        [widget.recipeId],
      );

      if (result.isNotEmpty) {
        var row = result.first;

        setState(() {
          recipeDetails = {
            'title': row['recipeName'],
            'content': row['recipeText'],  // 包含食材和步驟的描述
            'createDate': (row['createDate'] as DateTime).toLocal().toString().split(' ')[0], // 格式化日期
            'rating': row['rating'],
            'imageUrl': row['url'] ?? 'assets/default_image.png',
            'remark': row['remark'] ?? ''  // 確保 remark 不為 null
          };
          _remarkController.text = recipeDetails!['remark']; // 將 remark 載入至 TextField 控制器
        });
      }
    } catch (e) {
      print('Error loading recipe details: $e');
    }
  }

  Future<void> _saveRemark() async {
    try {
      var conn = await DatabaseService().connection;

      // 更新資料庫中的 remark 欄位
      await conn.query(
        'UPDATE recipedb.recipes SET remark = ? WHERE recipeId = ?',
        [_remarkController.text, widget.recipeId],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('備註已儲存')),
      );
    } catch (e) {
      print('Error saving remark: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('備註儲存失敗')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Color(0xFFF1E9E6);

    return Scaffold(
      appBar: AppBar(
        title: Text('歷史食譜詳情'),
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: recipeDetails == null
          ? Center(child: CircularProgressIndicator()) // 加載指示器
          : Container(
              color: backgroundColor,
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage(recipeDetails!['imageUrl']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '製作時間：${recipeDetails!['createDate']}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '食譜內容',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              recipeDetails!['content'], // 顯示來自 DB 的 recipeText
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(6.5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '備註',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _remarkController, // 綁定備註控制器
                          maxLines: 2,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '在這裡寫下你的備註...',
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Spacer(),
                            ElevatedButton(
                              onPressed: _saveRemark, // 儲存備註到資料庫
                              child: Text('儲存'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
