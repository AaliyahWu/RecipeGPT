import 'package:flutter/material.dart';

class PostPage extends StatelessWidget {
  final int index;

  PostPage({required this.index});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Color(0xFFF1E9E6);

    return Scaffold(
      appBar: AppBar(
        title: Text('好實在'),
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: backgroundColor,
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 帖子图片
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: AssetImage('assets/food/food1.jpg'), // 替换为帖子的图片
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
            ],
          ),
        ),
      ),
    );
  }
}
