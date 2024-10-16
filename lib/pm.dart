import 'package:flutter/material.dart';
import 'pmc.dart'; // 导入 Pmc 页面

class PostManagement extends StatelessWidget {
  final List<Map<String, dynamic>> historicalRecipes = [
    {
      'imageUrl': 'assets/food/food1.jpg',
      'title': '番茄炒蛋',
      'description': '簡單易做的番茄炒蛋，營養豐富。',
      'rating': 8.8,
    },
    // 添加其他食谱...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Color(0xFFF1E9E6),
            child: Column(
              children: [
                SizedBox(height: 40),
                Text(
                  '貼文管理',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: historicalRecipes.length,
                    itemBuilder: (context, index) {
                      var recipe = historicalRecipes[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Card(
                          color: Color(0xFFFFFAF5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(10),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                recipe['imageUrl'],
                                fit: BoxFit.cover,
                                width: 50,
                                height: 50,
                              ),
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  recipe['title'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.favorite,
                                        color: Colors.red, size: 20),
                                    Text(
                                      ' ${recipe['rating']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            subtitle: Text(
                              recipe['description'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            onTap: () {
                              // 当点击某个贴文时，导航到 Pmc 页面
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PmcPage(
                                    recipe: recipe, // 传递该帖子的详情
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // 左上角的返回按钮
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context); // 返回上一页
              },
            ),
          ),
        ],
      ),
    );
  }
}
