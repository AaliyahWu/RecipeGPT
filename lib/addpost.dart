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
    return Scaffold(
      appBar: AppBar(
        title: Text('新增貼文'),
        backgroundColor: Color(0xFFF1E9E6),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // 顯示加載指示器
          : historicalRecipes.isEmpty
              ? Center(child: Text('目前沒有可以新增的食譜'))
              : ListView.builder(
                  itemCount: historicalRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = historicalRecipes[index];
                    return Card(
                      margin: EdgeInsets.all(15),
                      child: ListTile(
                        leading: Image.network(
                          recipe['imageUrl'],
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                        // title: Text(recipe['recipeName']),
                        title: Text(
                          recipe['recipeText'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
    );
  }
}
