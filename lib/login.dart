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
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFF1E9E6),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFF2B892)),
            borderRadius: BorderRadius.circular(10.0),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Color(0xFFF2B892),
        ),
      ),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 200, // Increase toolbar height for larger logo
            flexibleSpace: Center(
              child: Image.asset(
                'assets/LOGO.png',
                height: 150, // Adjust the height as needed
              ),
            ),
            bottom: const TabBar(
              indicatorColor: Color(0xFFF2B892),
              labelColor: Color(0xFFF2B892),
              unselectedLabelColor: Colors.black,
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
  bool _obscurePassword = true;

  Future<bool> authenticateUser(String username, String password) async {
    try {
      var conn = await DatabaseService().connection;
      var results = await conn.query(
          'SELECT * FROM recipedb.accounts WHERE email = ? AND password = ?',
          [username, password]);
      return results.isNotEmpty;
    } catch (e) {
      print('驗證失敗: $e');
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
        content: Text('登入成功!'),
        backgroundColor: Colors.green,
      ));
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => HomePage(), // 導航到 HomePage
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('帳號或密碼錯誤'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        heightFactor: 0.9, // Adjust the height factor to move the form upwards or downwards
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: '電子信箱',
                    hintText: '輸入電子信箱...',
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: '密碼',
                    hintText: '輸入密碼...',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                ),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            backgroundColor: Color(0xFFF2B892),
                          ),
                          child: const Text(
                            '登入',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
              ],
            ),
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
  bool _obscurePassword = true;

  Future<void> registerUser(String name, String email, String password) async {
    try {
      var conn = await DatabaseService().connection;
      await conn.query(
        'INSERT INTO recipedb.accounts (name, email, password) VALUES (?, ?, ?)',
        [name, email, password],
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('註冊成功!'),
        backgroundColor: Colors.green,
      ));
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => HomePage(), // Assuming HomePage exists
      ));
    } catch (e) {
      print('註冊失敗: $e');
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
      child: FractionallySizedBox(
        heightFactor: 0.9, // Adjust the height factor to move the form upwards or downwards
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: '暱稱',
                    hintText: '輸入暱稱...',
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: '電子信箱',
                    hintText: '輸入電子信箱...',
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: '密碼',
                    hintText: '輸入密碼...',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                ),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleRegister,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            backgroundColor: Color(0xFFF2B892),
                          ),
                          child: const Text(
                            '註冊',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
              ],
            ),
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
