import 'package:flutter/material.dart';
import 'db/db.dart'; // 假設有資料庫服務類

class PostDetailPage extends StatefulWidget {
  final Map<String, dynamic> post;

  PostDetailPage({required this.post});

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  bool isLoading = false;

  Future<void> _deletePost() async {
    setState(() {
      isLoading = true;
    });
    try {
      var conn = await DatabaseService().connection;

      // 從 posts 表中刪除記錄
      await conn.query(
        'DELETE FROM recipedb.posts WHERE postId = ?',
        [widget.post['postId']],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('貼文已刪除')),
      );

      // 返回上一頁並標記為成功刪除
      Navigator.pop(context, true);
    } catch (e) {
      print('刪除貼文失敗: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('刪除貼文失敗，請稍後再試')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('確認刪除'),
          content: Text('確定要刪除此貼文嗎？此操作無法恢復。'),
          actions: [
            TextButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop(); // 關閉對話框
              },
            ),
            ElevatedButton(
              child: Text('確認'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // 設定確認按鈕為紅色
              ),
              onPressed: () {
                Navigator.of(context).pop(); // 關閉對話框
                _deletePost(); // 呼叫刪除貼文的方法
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('貼文詳情'),
        backgroundColor: Color(0xFFF1E9E6),
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 顯示貼文圖片
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage(widget.post['url']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // 顯示食譜名稱
                  Text(
                    widget.post['recipeName'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),

                  // 顯示發布時間
                  Text(
                    '發布時間: ${widget.post['postTime'].toString().split(' ')[0]}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  Spacer(),

                  // 刪除貼文按鈕
                  ElevatedButton.icon(
                    onPressed: _confirmDelete,
                    icon: Icon(Icons.delete),
                    label: Text('刪除貼文'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
