import 'package:flutter/material.dart';

class AddPostCheckPage extends StatelessWidget {
  final Map<String, dynamic> recipe;

  AddPostCheckPage({required this.recipe});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Color(0xFFF1E9E6);

    return Scaffold(
      appBar: AppBar(
        title: Text('新增貼文詳情'),
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: Container(
        color: backgroundColor,
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 显示食谱图片
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage(recipe['imageUrl']), // 使用传入的图片 URL
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16),
            // 食材和步骤区域
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 250, // 固定高度
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
                              '- 2個番茄\n- 3個雞蛋\n- 1小勺鹽\n- 適量油 ',
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
                      height: 250, // 固定高度，與食材框框一致
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
                              '1. 番茄切片，雞蛋打散。\n'
                              '2. 熱鍋，加入油，煎雞蛋至金黃。\n'
                              '3. 加入番茄，炒至軟爛。\n'
                              '4. 加入鹽調味，即可出鍋。',
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
            // 备注区域
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
                    '新增標籤',
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
                      hintText: '#',
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Spacer(), // 将按钮推到右边
                      ElevatedButton(
                        onPressed: () {
                          // 加入儲存備註的邏輯
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('已上傳')),
                          );
                        },
                        child: Text('上傳'),
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
