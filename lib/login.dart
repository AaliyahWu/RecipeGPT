import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'homepage.dart'; // 假設HomePage的widget在homepage.dart中定義

void main() {
  runApp(const Login());
}

class Login extends StatelessWidget {
  const Login({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('RecipeGPT'),
            centerTitle: true, //移到中間
            bottom: const TabBar(
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

class LoginCard extends StatefulWidget {
  @override
  _LoginCardState createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<bool> authenticateUser(String username, String password) async {
    try {
      var conn = await DatabaseService().connection;
      var results = await conn.query(
          'SELECT * FROM recipedb.accounts WHERE email = ? AND password = ?',
          [username, password]);
      return results.isNotEmpty;
    } catch (e) {
      print('Failed to authenticate user: $e');
      return false;
    }
  }

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
        content: Text('登入成功！'),
        backgroundColor: Colors.green,
      ));
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => HomePage(), // 導航到 HomePage
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('無效的使用者名稱或密碼'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(20.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: '帳號'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: '密碼'),
                obscureText: true,
              ),
              SizedBox(height: 20), //按鈕位置
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _handleLogin,
                      child: const Text('登入'),
                    ), //跳轉按鈕
            ],
          ),
        ),
      ),
    );
  }
}

class SignupCard extends StatefulWidget {
  @override
  _SignupCardState createState() => _SignupCardState();
}

class _SignupCardState extends State<SignupCard> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> registerUser(String name, String email, String password) async {
    try {
      var conn = await DatabaseService().connection;
      await conn.query(
        'INSERT INTO recipedb.accounts (name, email, password) VALUES (?, ?, ?)',
        [name, email, password]
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('註冊成功！'),
        backgroundColor: Colors.green,
      ));
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => HomePage(), // Assuming HomePage exists
      ));
    } catch (e) {
      print('Failed to register user: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('註冊失敗'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleRegister() async {
    setState(() {
      _isLoading = true;
    });
    await registerUser(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(20.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: '名字'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: '電子信箱'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: '密碼'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _handleRegister,
                      child: const Text('註冊'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}


// class SignupCard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Card(
//         margin: const EdgeInsets.all(20.0),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               SizedBox(height: 10),
//               TextField(
//                 decoration: const InputDecoration(labelText: '電子信箱'),
//               ),
//               SizedBox(height: 10),
//               TextField(
//                 decoration: const InputDecoration(labelText: '密碼'),
//                 obscureText: true,
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {},
//                 child: const Text('Signup'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

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
        host: 'recipeedb-2.mysql.database.azure.com',
        port: 3306,
        user: 'yuntech',
        password: 'recipeDB@@',
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
