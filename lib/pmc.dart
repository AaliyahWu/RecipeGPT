import 'package:flutter/material.dart';
import 'db/db.dart'; // 假設有資料庫服務類

class PMCDetailedPage extends StatefulWidget {
  final int postId; // 接收從 pm.dart 傳遞的 postId

  PMCDetailedPage({required this.postId});

  @override
  _PMCDetailedPageState createState() => _PMCDetailedPageState();
}

class _PMCDetailedPageState extends State<PMCDetailedPage> {
  Map<String, dynamic>? recipeDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecipeDetails(); // 初始化時獲取食譜詳細資料
  }

  Future<void> _fetchRecipeDetails() async {
    try {
      var conn = await DatabaseService().connection;

      // 查詢 postId 對應的 recipeId 以及食譜詳情
      var results = await conn.query('''
        SELECT r.recipeId, r.recipeName, r.recipeText, r.url
        FROM recipedb.posts AS p
        JOIN recipedb.recipes AS r ON p.recipeID = r.recipeId
        WHERE p.postId = ?
      ''', [widget.postId]);

      if (results.isNotEmpty) {
        var row = results.first;
        setState(() {
          recipeDetails = {
            'recipeId': row['recipeId'],
            'recipeName': row['recipeName'],
            'recipeText': row['recipeText'],
            'url': row['url'],
          };
          isLoading = false;
        });
      } else {
        // 處理找不到對應資料的情況
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('找不到對應的食譜詳情')),
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('加載食譜詳細資料失敗: $e');
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
        // elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : recipeDetails == null
              ? Center(
                  child: Text(
                    '無法加載食譜詳情',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 顯示食譜圖片
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            image: recipeDetails!['url'] != null
                                ? DecorationImage(
                                    image: NetworkImage(recipeDetails!['url']),
                                    fit: BoxFit.cover,
                                  )
                                : null,
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
                                recipeDetails!['recipeText'] ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
    );
  }
}
