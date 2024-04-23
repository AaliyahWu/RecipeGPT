import 'package:flutter/material.dart';
import 'package:recipe_gpt/homepage.dart';
import 'package:recipe_gpt/views/camera_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Realtime Object Detection',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CameraView(),
    );
  }
}
