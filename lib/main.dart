import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_gpt/user/user_provider.dart';
import 'package:recipe_gpt/login/splash.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        // Add any additional routes here
      },
      debugShowCheckedModeBanner: false,
      home: MealPlannerSplashScreen(),
    );
  }
}