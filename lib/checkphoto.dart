import 'package:flutter/material.dart';
import 'package:recipe_gpt/homepage.dart';
import 'package:recipe_gpt/camerafunction.dart';
import 'package:recipe_gpt/checkphoto.dart';
import 'package:recipe_gpt/checklist.dart';
import 'package:recipe_gpt/services/openai/chat_screen.dart';

class CheckPhoto extends StatelessWidget {
  const CheckPhoto({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CheckPhoto'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('CheckList'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CheckList()),
            );
          },
        ),
      ),
    );
  }
}
