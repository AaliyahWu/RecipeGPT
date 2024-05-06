import 'package:flutter/material.dart';
import 'chat_service.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String _chatResponse = '';
  TextEditingController _textEditingController = TextEditingController();
  int _selectedPeople = 1; // 選擇的人數，預設為1
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('生成食譜'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: 1,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Center(
                          child: Text(
                            _chatResponse.isNotEmpty
                                ? _chatResponse
                                : '輸入食材，產生食譜吧!',
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            DropdownButtonFormField<int>(
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
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                hintText: '請輸入食材...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _startChat(_textEditingController.text);
              },
              child: Text('產生食譜'),
            ),
          ],
        ),
      ),
    );
  }

  void _startChat(String prompt) async {
    // String? response = await ChatService().request(prompt); //原本只有食材內容
    String? response = await ChatService().request(prompt,
        _selectedPeople); //在 _startChat 方法中，將 _selectedPeople 傳遞給 ChatService 的 request 方法
    setState(() {
      _chatResponse = response ?? 'No response';
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
