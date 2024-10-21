import 'package:flutter/material.dart';
import 'favoritev.dart';

class FavoritePage extends StatelessWidget {
  final List<Map<String, dynamic>> favoriteRecipes = [
    {
      'imageUrl': 'assets/food/food1.jpg',
      'title': '番茄炒蛋',
      'description': '簡單易做的番茄炒蛋，營養豐富。這道菜品非常適合家庭聚餐，也可以搭配白米飯食用。',
      'rating': 9.5,
    },
    {
      'imageUrl': 'assets/food/food2.jpg',
      'title': '牛肉麵',
      'description': '香濃的牛肉麵，回味無窮。湯頭鮮美，牛肉嫩滑，非常受歡迎。',
      'rating': 9.2,
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
                  '我的最愛管理',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: favoriteRecipes.length,
                    itemBuilder: (context, index) {
                      var recipe = favoriteRecipes[index];
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
                                Expanded(
                                  child: Text(
                                    recipe['title'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FavoritevPage(
                                    recipe: recipe,
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
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
