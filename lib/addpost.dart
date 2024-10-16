import 'package:flutter/material.dart';
import 'addpostcheck.dart'; // 导入AddPostCheckPage页面

class AddPostPage extends StatelessWidget {
  final List<Map<String, dynamic>> historicalRecipes = [
    {
      'imageUrl': 'assets/food/food1.jpg',
      'title': '番茄炒蛋',
      'description': '簡單易做的番茄炒蛋，營養豐富。',
      'rating': 8.8,
    },
    {
      'imageUrl': 'assets/food/food2.jpg',
      'title': '牛肉炒飯',
      'description': '新鮮的牛肉與香脆的蔬菜完美結合，豐富的層次感。',
      'rating': 8.1,
    },
    {
      'imageUrl': 'assets/food/food3.jpg',
      'title': '炒高麗菜',
      'description': '口感鮮嫩，營養豐富的炒高麗菜。',
      'rating': 9.2,
    },
    {
      'imageUrl': 'assets/food/food4.jpg',
      'title': '雞肉沙拉',
      'description': '健康清爽的雞肉沙拉,適合夏日輕食。',
      'rating': 9.1,
    },
    {
      'imageUrl': 'assets/food/food7.jpg',
      'title': '牛肉意面',
      'description': '香濃美味的牛肉意面,百吃不厭。',
      'rating': 8.6,
    },
    {
      'imageUrl': 'assets/food/food6.jpg',
      'title': '早餐水果拼盤',
      'description': '各種新鮮水果的精彩組合。',
      'rating': 8.2,
    },
    {
      'imageUrl': 'assets/food/food8.jpg',
      'title': '香菇炒麵',
      'description': '香氣四溢的香菇炒麵，美味可口。',
      'rating': 9.0,
    },
    {
      'imageUrl': 'assets/food/food9.jpg',
      'title': '鮮蝦沙拉',
      'description': '清爽可口的鮮蝦沙拉，滿滿的海鮮風味。',
      'rating': 8.9,
    },
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
                  '新增貼文',
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
                              // 当点击某个贴文时，导航到 AddPostCheckPage，并传递该帖子的详情
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddPostCheckPage(
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
