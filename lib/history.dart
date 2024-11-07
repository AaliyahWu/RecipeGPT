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

  @override
  void initState() {
    super.initState();
    _fetchRecipeDetails();
  }

  Future<void> _fetchRecipeDetails() async {
    try {
      var conn = await DatabaseService().connection;

      // 使用 recipeId 查詢食譜的詳細資料
      var result = await conn.query(
        'SELECT recipeName, recipeText, createDate, rating, url FROM recipedb.recipes WHERE recipeId = ?',
        [widget.recipeId],
      );

      if (result.isNotEmpty) {
        var row = result.first;

        setState(() {
          recipeDetails = {
            'title': row['recipeName'],
            'ingredients': row['recipeText'],  // 這裡假設 recipeText 包含了食材和步驟的描述
            'createDate': (row['createDate'] as DateTime).toLocal().toString().split(' ')[0], // 格式化日期
            'rating': row['rating'],
            'imageUrl': row['url'] ?? 'assets/default_image.png'
          };
        });
      }
    } catch (e) {
      print('Error loading recipe details: $e');
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
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 250,
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
                                    '食材',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    recipeDetails!['ingredients'],
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            height: 250,
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
                                    '步驟',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    recipeDetails!['ingredients'], // 假設 recipeText 包含步驟
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(9.0),
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
                        SizedBox(height: 10),
                        TextField(
                          maxLines: 3,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '在這裡寫下你的備註...',
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Spacer(),
                            ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('備註已儲存')),
                                );
                              },
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
