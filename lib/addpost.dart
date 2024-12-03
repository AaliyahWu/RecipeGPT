import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart'; // For database connection
import 'addpostcheck.dart'; // 導入確認頁面
import 'db/db.dart'; // 資料庫服務

class AddPostPage extends StatefulWidget {
  final int accountId; // 接收使用者的帳號 ID

  AddPostPage({required this.accountId});

  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  List<Map<String, dynamic>> historicalRecipes = []; // 歷史食譜列表
  bool isLoading = true; // 載入狀態

  @override
  void initState() {
    super.initState();
    _fetchHistoricalRecipes(); // 初始化時載入歷史食譜
  }

  // 從資料庫加載歷史食譜
  Future<void> _fetchHistoricalRecipes() async {
    try {
      var conn = await DatabaseService().connection;

      // 查詢該使用者的歷史食譜
      var results = await conn.query(
        '''
        SELECT recipeId, recipeName, url 
        FROM recipedb.recipes 
        WHERE accountId = ? 
        ORDER BY createDate DESC
        ''',
        [widget.accountId],
      );

      // 將查詢結果存入列表
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
      print('載入歷史食譜出錯: $e');
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
          ? Center(child: CircularProgressIndicator())
          : historicalRecipes.isEmpty
              ? Center(child: Text('目前沒有歷史食譜'))
              : ListView.builder(
                  itemCount: historicalRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = historicalRecipes[index];
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        leading: Image.network(
                          recipe['imageUrl'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                        title: Text(recipe['recipeName']),
                        onTap: () {
                          // 導航到確認頁面
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddPostCheckPage(
                                recipe: recipe,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
