import 'package:flutter/material.dart';
import 'package:recipe_gpt/homepage.dart';
import 'package:recipe_gpt/camerafunction.dart';
import 'package:recipe_gpt/checkphoto.dart';
import 'package:recipe_gpt/checklist.dart';
import 'package:recipe_gpt/services/openai/chat_screen.dart';

class CheckPhoto extends StatelessWidget {
  const CheckPhoto({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CheckPhoto'),
        backgroundColor: Color.fromARGB(255, 255, 196, 106), // bar
      ),
      backgroundColor: Color.fromARGB(255, 247, 238, 163), // background
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 280,
            height: 360,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  //陰影
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
              border: Border.all(color: Colors.black, width: 0.5), // 添加外框
              image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage('assets/image/food.jpg'), //
              ),
            ),
            padding: const EdgeInsets.all(10),
          ),
          SizedBox(height: 20), // Spacer

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('重拍'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => CheckList()),
                  // );
                },
                child: Text('沒問題下一步'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
