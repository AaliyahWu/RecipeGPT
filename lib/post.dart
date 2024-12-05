import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 引入日期格式化工具
import 'db/db.dart'; // 假設有資料庫服務類

class PostPage extends StatefulWidget {
  final int postId;

  PostPage({required this.postId});

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  bool isLoading = true;
  Map<String, dynamic>? recipeDetails;

  @override
  void initState() {
    super.initState();
    _fetchRecipeDetails(); // 初始化時獲取食譜詳細資料
  }

  Future<void> _fetchRecipeDetails() async {
    try {
      var conn = await DatabaseService().connection;

      // 查詢食譜詳細資料
      var results = await conn.query(
        '''
        SELECT r.recipeName, r.recipeText, r.url, p.postTime
        FROM recipedb.recipes AS r
        JOIN recipedb.posts AS p
        ON r.recipeId = p.recipeId
        WHERE p.postId = ?
        ''',
        [widget.postId],
      );

      if (results.isNotEmpty) {
        var row = results.first;
        setState(() {
          recipeDetails = {
            'recipeName': row['recipeName'],
            'recipeText': row['recipeText'],
            'imageUrl': row['url'],
            'postTime': row['postTime'], // 原始的日期時間數據
          };
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('載入食譜詳情失敗: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('食譜詳情'),
        backgroundColor: Color(0xFFF1E9E6),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : recipeDetails == null
              ? Center(child: Text('無法載入食譜詳細資料'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 顯示圖片
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

                      // 顯示食譜名稱
                      Text(
                        recipeDetails!['recipeName'],
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),

                      // 顯示發布時間（只顯示年月日）
                      Text(
                        '發布時間: ${_formatPostTime(recipeDetails!['postTime'])}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 16),

                      // 顯示製作步驟
                      Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '製作步驟',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              recipeDetails!['recipeText'],
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  // 格式化發布時間，只顯示年月日
  String _formatPostTime(DateTime postTime) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(postTime);
  }
}
