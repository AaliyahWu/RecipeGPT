import 'package:flutter/material.dart';

class FavoritevPage extends StatelessWidget {
  final Map<String, dynamic> recipe;

  FavoritevPage({required this.recipe});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Color(0xFFF1E9E6);

    return Scaffold(
      appBar: AppBar(
        title: Text('好實在'),
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
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
                        image: AssetImage(recipe['imageUrl']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // 食材部分
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
                          '食材',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '- 2個番茄\n- 3個雞蛋\n- 1小勺鹽\n- 適量油\n',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

                  // 步骤部分
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
                          '步驟',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '1. 番茄切片，雞蛋打散。\n'
                          '2. 熱鍋，加入油，煎雞蛋至金黃。\n'
                          '3. 加入番茄，炒至軟爛。\n'
                          '4. 加入鹽調味，即可出鍋。\n',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // 右下角的 "取消我的最爱" 按钮
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton.extended(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('已取消我的最愛')),
                );
              },
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
