import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:recipe_gpt/homepage.dart';
// import 'screen/openai_entry_screen.dart';
import 'package:recipe_gpt/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'Flutter Demo',
      initialRoute: '/',
      routes: {
        // '/openai': (context) => const OpenAIEntryScreen(), //新增連到食譜產生畫面的路徑
      },
      debugShowCheckedModeBanner: false, //右上角紅色東東去掉
      home: Login(),
      //home: HomePage(),
    );
  }
}

