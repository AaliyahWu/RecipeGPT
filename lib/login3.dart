import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:recipe_gpt/homepage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Demo',
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<bool> authenticateUser(String username, String password) async {
    try {
      var conn = await DatabaseService().connection;
      var results = await conn.query(
        'SELECT * FROM recipedb.accounts WHERE email = ? AND password = ?',
        [username, password]
      );
      return results.isNotEmpty;
    } catch (e) {
      print('Failed to authenticate user: $e');
      return false;
    }
  }

  // void _handleLogin() async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   bool result = await authenticateUser(
  //     _usernameController.text,
  //     _passwordController.text,
  //   );
  //   if (result) {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text('Login successful!'),
  //       backgroundColor: Colors.green,
  //     ));
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text('Invalid username or password'),
  //       backgroundColor: Colors.red,
  //     ));
  //   }
  //   setState(() {
  //     _isLoading = false;
  //   });
  // }

  void _handleLogin() async {
  setState(() {
    _isLoading = true;
  });
  bool result = await authenticateUser(
    _usernameController.text,
    _passwordController.text,
  );
  setState(() {
    _isLoading = false;
  });

  if (result) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Login successful!'),
      backgroundColor: Colors.green,
    ));
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => HomePage(), // Navigate to HomePage
    ));
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Invalid username or password'),
      backgroundColor: Colors.red,
    ));
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _handleLogin,
                      child: Text('Login'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  MySqlConnection? _connection;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<MySqlConnection> get connection async {
    if (_connection == null) {
      final settings = ConnectionSettings(
        host: 'recipe-database.cyg3ezxgvj0g.us-east-1.rds.amazonaws.com',
        port: 3306,
        user: 'admin',
        password: 'recipegpt',
        db: 'recipedb',
      );
      _connection = await MySqlConnection.connect(settings);
    }
    return _connection!;
  }

  Future<void> closeConnection() async {
    await _connection?.close();
    _connection = null;
  }
}