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
  bool _isButtonEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CheckList'),
        backgroundColor: Color.fromARGB(255, 255, 196, 106),
      ),
      backgroundColor: Color.fromARGB(255, 247, 238, 163),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.5,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                  color: Color.fromRGBO(255, 255, 255, 0.8), // 圖片透明度
                  image: DecorationImage(
                    image: AssetImage('assets/image/note.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.5),
                      BlendMode.dstATop,
                    ),
                  ),
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
                color: Colors.white, //字體顏色
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isButtonEnabled
                        ? () {
                            setState(() {
                              _items.add(ListItem(title: _textController.text));
                              _textController.clear();
                              _isButtonEnabled = false;
                            });
                          }
                        : null,
                    child: Text('送出'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatPage()),
                      );
                    },
                    child: const Text('生成食譜'),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _textController,
              onChanged: (text) {
                setState(() {
                  _isButtonEnabled = text.isNotEmpty;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '輸入食材',
                // filled: true,
                // fillColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
