import 'package:flutter/material.dart';
import 'db/db.dart'; // 假設有資料庫服務類

class FavoritevPage extends StatefulWidget {
  final int recipeId; // 接收從收藏列表傳遞的 recipeId
  final int accountId; // 接收用戶的 accountId

  FavoritevPage({required this.recipeId, required this.accountId});

  @override
  _FavoritevPageState createState() => _FavoritevPageState();
}

class _FavoritevPageState extends State<FavoritevPage> {
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

      // 查詢食譜詳細資料
      var results = await conn.query(
        '''
        SELECT recipeName, recipeText, url
        FROM recipedb.recipes
        WHERE recipeId = ?
        ''',
        [widget.recipeId],
      );

      if (results.isNotEmpty) {
        var row = results.first;
        setState(() {
          recipeDetails = {
            'recipeName': row['recipeName'],
            'recipeText': row['recipeText'],
            'imageUrl': row['url'],
          };
          isLoading = false;
        });
      }
    } catch (e) {
      print('載入食譜詳細資料失敗: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _removeFromFavorites() async {
    try {
      var conn = await DatabaseService().connection;

      // 從 likes 表中刪除記錄
      await conn.query(
        'DELETE FROM recipedb.likes WHERE accountId = ? AND recipeId = ?',
        [widget.accountId, widget.recipeId],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已取消我的最愛')));

      // 返回 favorite.dart 並通知刷新
      Navigator.pop(context, true);
    } catch (e) {
      print('取消收藏失敗: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('取消收藏失敗，請稍後再試')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Color(0xFFF1E9E6);

    return Scaffold(
      appBar: AppBar(
        title: Text('好食在'),
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        // elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : recipeDetails == null
              ? Center(
                  child: Text(
                    '無法載入食譜詳細資料',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                )
              : Stack(
                  children: [
                    SingleChildScrollView(
                      child: Container(
                        color: backgroundColor,
                        padding: EdgeInsets.all(16.0),
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
                                  image: NetworkImage(
                                    recipeDetails!['imageUrl'],
                                  ),
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

                            // 步驟部分
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
                            SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),

                    // 右下角的 "取消我的最愛" 按鈕
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: FloatingActionButton.extended(
                        onPressed: _removeFromFavorites,
                        label: Text('取消我的最愛'),
                        icon: Icon(Icons.favorite),
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
    );
  }
}
