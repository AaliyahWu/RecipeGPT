import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'addpostcheck.dart'; // 導入確認新增貼文的頁面
import 'db/db.dart'; // 資料庫服務

class AddPostPage extends StatefulWidget {
  final int accountId;

  AddPostPage({required this.accountId});

  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  List<Map<String, dynamic>> historicalRecipes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistoricalRecipes();
  }

  Future<void> _fetchHistoricalRecipes() async {
    try {
      var conn = await DatabaseService().connection;

      // 查詢未出現在 posts 表中的 recipes
      var results = await conn.query(
        '''
      SELECT recipeId, recipeName, url, recipeText
      FROM recipedb.recipes
      WHERE accountId = ?
      AND recipeId NOT IN (
        SELECT recipeID FROM recipedb.posts
      )
      ORDER BY createDate DESC
      ''',
        [widget.accountId], // 使用目前使用者的 accountId
      );

      // 更新歷史食譜資料
      setState(() {
        historicalRecipes = results.map((row) {
          return {
            'recipeId': row['recipeId'],
            'recipeName': row['recipeName'],
            'imageUrl': row['url'],
            'recipeText': row['recipeText'],
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('載入歷史食譜失敗: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Color backgroundColor = Color(0xFFF1E9E6);
    return Scaffold(
      backgroundColor: Color(0xFFF1E9E6), // 固定 AppBar 背景顏色
      appBar: AppBar(
        title: Container(
          padding:
              EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // 添加適當的內邊距
          child: Text(
            '新增貼文',
            style: TextStyle(color: Colors.black), // 設定文字顏色
          ),
        ),
        backgroundColor: Color(0xFFF1E9E6), // 固定 AppBar 背景顏色
        // elevation: 1, // 去除陰影
        surfaceTintColor: Colors.transparent, //設定滑動時背景顏色透明
        iconTheme: IconThemeData(color: Colors.black), // 設定返回按鈕顏色
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 16.0, vertical: 8.0), // 設定內邊距
        child: isLoading
            ? Center(child: CircularProgressIndicator()) // 顯示加載指示器
            : historicalRecipes.isEmpty
                ? Center(
                    child: Text(
                      '目前沒有可以新增的食譜',
                      style: TextStyle(
                          color: Colors.black, fontSize: 16), // 修正文字顏色
                    ),
                  )
                : ListView.builder(
                    itemCount: historicalRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = historicalRecipes[index];
                      return Card(
                        margin:
                            EdgeInsets.symmetric(vertical: 8.0), // 每個項目的上下間距
                        child: ListTile(
                          leading: Image.network(
                            recipe['imageUrl'],
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                          title: Text(
                            recipe['recipeText'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black), // 修正文字顏色
                          ),
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddPostCheckPage(recipe: recipe),
                              ),
                            );
                            if (result == true) {
                              Navigator.pop(context, true); // 返回上一頁並通知新增成功
                            }
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
