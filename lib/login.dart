import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';
import 'package:recipe_gpt/user/user_provider.dart';
import 'package:recipe_gpt/homepage.dart';
import 'package:recipe_gpt/db/db.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 200,
          flexibleSpace: Center(
            child: Image.asset(
              'assets/LOGO.png',
              height: 150,
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

  // Function to authenticate the user based on username and password
  Future<User?> authenticateUser(String username, String password) async {
    try {
      var conn = await DatabaseService().connection;
      var results = await conn.query(
          'SELECT accountId, name, email FROM recipedb.accounts WHERE email = ? AND password = ?',
          [username, password]);
      if (results.isNotEmpty) {
        var row = results.first;
        return User(
          id: row['accountId'],
          name: row['name'],
          email: row['email'],
        );
      }
      return null;
    } catch (e) {
      print('驗證失敗: $e');
      return null;
    }
  }

  // Handle login function
  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    // Authenticate user and get the user details
    User? user = await authenticateUser(
      _usernameController.text,
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (user != null) {
      // Set the user data in the provider
      Provider.of<UserProvider>(context, listen: false).setUser(user);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('登入成功!'),
        backgroundColor: Colors.green,
      ));

      // Navigate to HomePage and pass the accountId
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => HomePage(accountId: user.id),
      ));
    } else {
      // Show error message
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
        heightFactor: 0.9,
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

  Future<User?> registerUser(String name, String email, String password) async {
    try {
      var conn = await DatabaseService().connection;
      var result = await conn.query(
        'INSERT INTO recipedb.accounts (name, email, password) VALUES (?, ?, ?)',
        [name, email, password],
      );
      
      int accountId = result.insertId!;
      
      return User(id: accountId, name: name, email: email);
    } catch (e) {
      print('註冊失敗: $e');
      return null;
    }
  }

  void _handleRegister() async {
    setState(() {
      _isLoading = true;
    });
    
    User? user = await registerUser(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );
    
    setState(() {
      _isLoading = false;
    });

    if (user != null) {
      Provider.of<UserProvider>(context, listen: false).setUser(user);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('註冊成功!'),
        backgroundColor: Colors.green,
      ));
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => HomePage(accountId: user.id),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('註冊失敗'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        heightFactor: 0.9,
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