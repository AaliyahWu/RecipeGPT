// this is chat_screen.dart

import 'package:flutter/material.dart';
import 'chat_service.dart';

class ChatPage extends StatefulWidget {
  final String prompt;
  final int people;
  final String recipe;

  ChatPage({required this.prompt, required this.people, required this.recipe});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String _chatResponse = '';
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _startChat(widget.recipe, widget.prompt, widget.people);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 196, 106),
        title: Text('生成食譜'),
      ),
      backgroundColor: Color.fromARGB(255, 247, 238, 163),
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
                    color: Color.fromARGB(255, 255, 216, 157),
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
                                : '食譜生成中...',
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // void _startChat(String prompt, int people) async {
  //   String? response = await ChatService().request(prompt, people);
  //   setState(() {
  //     _chatResponse = response ?? 'No response';
  //     _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  //   });
  // }

    void _startChat(String recipe, String prompt, int people) async {
    String? response =
        await ChatService().request(recipe, prompt, people);
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
