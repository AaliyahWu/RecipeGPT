import 'package:flutter/material.dart';
import 'package:recipe_gpt/checkphoto.dart';
import 'package:recipe_gpt/homepage.dart';
import 'package:recipe_gpt/services/openai/chat_screen.dart';

class Camera extends StatelessWidget {
  const Camera({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('CheckPhoto'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CheckPhoto()),
            );
          },
        ),
      ),
    );
  }
}
