import 'package:flutter/material.dart';
import 'db/db.dart'; // 假設您有資料庫服務類
import 'favoritev.dart';

class FavoritePage extends StatefulWidget {
  final int accountId; // 接收從首頁傳遞的 accountId

  FavoritePage({required this.accountId});

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<Map<String, dynamic>> favoriteRecipes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavoriteRecipes();
  }

  Future<void> _fetchFavoriteRecipes() async {
    try {
      var conn = await DatabaseService().connection;

      // 查詢我的最愛資料，包含 recipeId
      var results = await conn.query(
        '''
        SELECT l.likeId, l.likeTime, r.recipeId, r.recipeName AS title, r.url AS imageUrl, r.rating, r.recipeText AS description
        FROM recipedb.likes AS l
        JOIN recipedb.recipes AS r
        ON l.recipeId = r.recipeId
        WHERE l.accountId = ?
        ORDER BY l.likeTime DESC
        ''',
        [widget.accountId], // 使用從 homepage.dart 傳遞過來的 accountId
      );

      setState(() {
        favoriteRecipes = results.map((row) {
          return {
            'likeId': row['likeId'],
            'likeTime': row['likeTime'],
            'recipeId': row['recipeId'], // 包含 recipeId
            'title': row['title'],
            'imageUrl': row['imageUrl'],
            'rating': row['rating'],
            'description': row['description'],
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('載入我的最愛失敗: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '我的最愛管理列表',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color(0xFFF1E9E6),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : favoriteRecipes.isEmpty
              ? Center(
                  child: Text(
                    '目前沒有收藏的食譜',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: favoriteRecipes.length,
                    itemBuilder: (context, index) {
                      var recipe = favoriteRecipes[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0.0, vertical: 8.0),
                        child: Card(
                          color: Color(0xFFFFFAF5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(10),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                recipe['imageUrl'],
                                fit: BoxFit.cover,
                                width: 70,
                                height: 70,
                              ),
                            ),
                            title: Text(
                              recipe['title'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // subtitle: Text(
                            //   recipe['description'],
                            //   style: TextStyle(
                            //     fontSize: 14,
                            //     color: Colors.grey[600],
                            //   ),
                            //   maxLines: 2,
                            //   overflow: TextOverflow.ellipsis,
                            // ),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FavoritevPage(
                                    recipeId: recipe['recipeId'],
                                    accountId: widget.accountId,
                                  ),
                                ),
                              );

                              // 如果從 FavoritevPage 返回，且返回值為 true，則重新加載數據
                              if (result == true) {
                                _fetchFavoriteRecipes(); // 重新查詢收藏列表
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
