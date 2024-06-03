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
  // TextEditingController _textController = TextEditingController();
  // List<ListItem> _items = [];
  // bool _isButtonEnabled = false;

  String _chatResponse = '';
  TextEditingController _textEditingController = TextEditingController();
  int _selectedPeople = 1; // 選擇的人數，預設為1
  ScrollController _scrollController = ScrollController();

  TextEditingController _textController = TextEditingController();
  List<ListItem> _items = [
    ListItem(title: '雞肉'),
    ListItem(title: '高麗菜'),
    ListItem(title: '胡蘿蔔'),
  ];
  bool _isButtonEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '食材清單',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF262520),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Color(0xFFF4DAB5),
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
                  color: Color.fromRGBO(255, 255, 255, 0.8),
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
                    SizedBox(height: 8.0),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedPeople,
                    onChanged: (value) {
                      setState(() {
                        _selectedPeople = value!;
                      });
                    },
                    items: List.generate(10, (index) {
                      return DropdownMenuItem<int>(
                        value: index + 1,
                        child: Text('${index + 1} 人份'),
                      );
                    }),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 13.0),
                      border: OutlineInputBorder(),
                      hintText: '選擇人數',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
            child: Row(
              children: [
                Expanded(
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
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                SizedBox(
                  height: 60.0, // 你可以根據需要調整這個值
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
                    child: Text('添加食材'),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 60.0, // 你可以根據需要調整這個值
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ChatPage()),
                        );
                      },
                      child: Text('生成食譜'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


void main() {
  runApp(MaterialApp(
    home: CheckList(),
  ));
}
