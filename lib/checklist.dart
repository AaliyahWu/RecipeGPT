import 'package:flutter/material.dart';
import 'package:recipe_gpt/homepage.dart';
import 'package:recipe_gpt/camerafunction.dart';
import 'package:recipe_gpt/checklist.dart';
import 'package:recipe_gpt/checkphoto.dart';
import 'package:recipe_gpt/services/openai/chat_screen.dart';

class ListItem {
  String title;
  bool isChecked;

  ListItem({required this.title, this.isChecked = false});
}

class CheckList extends StatefulWidget {
  const CheckList({Key? key}) : super(key: key);

  @override
  _CheckListState createState() => _CheckListState();
}

class _CheckListState extends State<CheckList> {
  TextEditingController _textController = TextEditingController();
  List<ListItem> _items = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CheckList'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 8.0), // Add spacing at the top
                    Expanded(
                      child: ListView.builder(
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          return CheckboxListTile(
                            title: Text(_items[index].title),
                            value: _items[index].isChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                _items[index].isChecked = value!;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '飲食偏好:豬肉 高蛋白質',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _items.add(ListItem(title: _textController.text));
                        _textController.clear();
                      });
                    },
                    child: Text('送出'),
                  ),
                ),
                SizedBox(width: 10), // Add spacing between the buttons
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatPage()),
                      );
                    },
                    child: const Text('RecipeGPT'),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: '輸入文字...',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
