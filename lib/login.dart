import 'package:flutter/material.dart';
import 'package:recipe_gpt/homepage.dart';

void main() {
  runApp(const Login());
}

class Login extends StatelessWidget {
  const Login({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('RecipeGPT'),
            centerTitle: true, //移到中間
            bottom: TabBar(
              tabs: [
                Tab(text: '登入'),
                Tab(text: '註冊'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              LoginCard(),
              SignupCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(20.0),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(labelText: '帳號'),
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(labelText: '密碼'),
                obscureText: true,
              ),
              SizedBox(height: 20), //按鈕位置
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                  // Handle login logic here
                },
                child: Text('登入'),
              ), //跳轉按鈕
            ],
          ),
        ),
      ),
    );
  }
}

class SignupCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(20.0),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(labelText: '電子信箱'),
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(labelText: '密碼'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                child: Text('Signup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
