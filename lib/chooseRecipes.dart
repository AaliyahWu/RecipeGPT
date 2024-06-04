import 'package:flutter/material.dart';

class RecipeListPage extends StatelessWidget {
  final String prompt;
  final int people;

  RecipeListPage({required this.prompt, required this.people});

  final List<String> recipes = [
    '高蛋白雞肉炒蔬菜',
    '高蛋白雞肉炒蔬菜',
    '高蛋白雞肉炒蔬菜',
    '高蛋白雞肉炒蔬菜',
    '高蛋白雞肉炒蔬菜',
    // 在這裡添加更多食譜
  ];

  @override
  Widget build(BuildContext context) {
    backgroundColor:
    const Color(0xFFF1E9E6); // 設定背景顏色
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1E9E6), // 設定背景顏色
        title: Text('食譜列表'),
      ),
      body: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          return Card(
            color: Color(0xFFFFF2EB),
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              leading: Icon(Icons.restaurant_menu, color: Color(0xFFF2B892)),
              title: Text(recipes[index]),
              trailing: Icon(Icons.arrow_forward_ios, color: Color(0xFFF2B892)),
              onTap: () {
                
              },
            ),
          );
        },
      ),
    );
  }
}
