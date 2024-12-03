import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:recipe_gpt/controller/pick_image.dart';
import 'package:recipe_gpt/login.dart';
import 'package:recipe_gpt/login/splash.dart';
import 'package:recipe_gpt/main.dart';
import 'package:recipe_gpt/services/openai/chat_response.dart';
import 'package:recipe_gpt/services/openai/chat_screen.dart';
import 'package:recipe_gpt/camerafunction.dart';
import 'package:recipe_gpt/history.dart';
import 'package:recipe_gpt/addpost.dart';
import 'package:recipe_gpt/post.dart';
import 'package:recipe_gpt/pm.dart';
import 'package:recipe_gpt/favorite.dart';
import 'package:mysql1/mysql1.dart';
import 'package:recipe_gpt/db/db.dart';
import 'dart:math';

void main() => runApp(MaterialApp(home: LoginCard()));

class HomePage extends StatefulWidget {
  final int accountId;
  HomePage({Key? key, required this.accountId})
      : super(key: key); //向父繼承accountId資料

  @override
  _HomePageState createState() => _HomePageState();
}

class PopularItem {
  final String imageUrl;
  final String title;
  final String rating;

  PopularItem(
      {required this.imageUrl, required this.title, required this.rating});
}

class _HomePageState extends State<HomePage> {
  int _currentPageIndex = 2; // 当前頁面索引
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  String userInput = '';
  TextEditingController _controller = TextEditingController();
  List<String> userInputList = [];
  List<PopularItem> popularItems = [];
  List<PopularItem> recentItems = [];
  List<Map<String, dynamic>> historicalRecipes = []; // 定義變數來儲存歷史食譜資料
  List<Map<String, dynamic>> posts = []; // 在 State 類中添加 `posts` 列表
  String profileImageUrl = ''; // Holds the profile image URL
  File? _image; // Stores the selected image file

  bool _isNotificationEnabled = false;
  String userName = 'Loading...'; // Placeholder for user name
  String userEmail = 'Loading...';
  @override
  void initState() {
    super.initState();
    _loadRecentRecipes();
    _loadTopRecipes();
    _fetchUserInfo();
    _loadPreferences(); // Load preferences when the page is opened
    _fetchRecipes(); // 初始化時載入歷史食譜
    _fetchPosts();
  }

  // bool _isNotificationEnabled = true; // 管理通知開關狀態(預設開)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _currentPageIndex,
        height: 60.0,
        items: <Widget>[
          Icon(Icons.group, size: 30, color: Color(0xFFF1E9E6)),
          Icon(Icons.list, size: 30, color: Color(0xFFF1E9E6)),
          Icon(Icons.camera, size: 45, color: Color(0xFFF1E9E6)),
          Icon(Icons.history, size: 30, color: Color(0xFFF1E9E6)),
          Icon(Icons.perm_identity, size: 30, color: Color(0xFFF1E9E6)),
        ],
        color: Color(0xFFDD8A62),
        buttonBackgroundColor: Color(0xFFDD8A62),
        backgroundColor: Color(0xFFF1E9E6), // 設定背景顏色
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 350),
        onTap: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        letIndexChange: (index) => true,
      ),
      body: _buildBody(),
    );
  }

  Future<void> _fetchPosts() async {
    try {
      var conn = await DatabaseService().connection;

      // 查詢 posts 與 recipes 表的關聯資料
      var results = await conn.query('''
        SELECT p.postId, p.postTime, r.recipeName, r.url
        FROM recipedb.posts AS p
        JOIN recipedb.recipes AS r
        ON p.recipeID = r.recipeId
        ORDER BY p.postTime DESC
        ''');

      // 將查詢結果存入 posts 列表
      setState(() {
        posts = results.map((row) {
          return {
            'postId': row['postId'],
            'postTime':
                row['postTime'].toLocal().toString().split(' ')[0], // 日期格式化
            'recipeName': row['recipeName'],
            'url': row['url'], // 食譜圖片 URL
          };
        }).toList();
      });

      print('貼文載入成功');
    } catch (e) {
      print('載入貼文出錯: $e');
    }
  }

  Future<void> _fetchUserInfo() async {
    try {
      var conn = await DatabaseService().connection;
      var results = await conn.query(
        'SELECT name, email, profileImageUrl FROM recipedb.accounts WHERE accountId = ?',
        [widget.accountId],
      );

      if (results.isNotEmpty) {
        var row = results.first;
        setState(() {
          userName = row['name'];
          userEmail = row['email'];
          profileImageUrl = row['profileImageUrl'] ?? ''; // Load profile image
        });
      }
    } catch (e) {
      print('Error loading user info: $e');
    }
  }

  // Method to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _uploadImage(_image!); // Upload the selected image
    }
  }

  Future<void> _uploadImage(File image) async {
    try {
      Dio dio = Dio();
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(image.path,
            filename: 'profile_${widget.accountId}.jpg'),
        "accountId":
            widget.accountId.toString(), // Send the accountId with the upload
      });

      var response =
          await dio.post("http://152.42.163.75/upload.php", data: formData);

      // Print the full response for debugging
      print('Response Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}'); // Check what the server returns

      // Check the status code and response type
      if (response.statusCode == 200) {
        // Manually parse the response data
        final responseData =
            jsonDecode(response.data); // Decode JSON string to Map

        // Check if responseData is a Map
        if (responseData is Map<String, dynamic>) {
          // Check if the keys we expect are present
          if (responseData.containsKey('status') &&
              responseData.containsKey('imageUrl')) {
            if (responseData['status'] == 'success') {
              String imageUrl = responseData['imageUrl'];
              setState(() {
                profileImageUrl = imageUrl;
              });

              // Update the profile image URL in the database
              var conn = await DatabaseService().connection;
              await conn.query(
                'UPDATE accounts SET profileImageUrl = ? WHERE accountId = ?',
                [imageUrl, widget.accountId],
              );
            } else {
              print('Server Error: ${responseData['message']}');
            }
          } else {
            print('Response does not contain expected keys: $responseData');
          }
        } else {
          print('Unexpected response format: $responseData');
        }
      } else {
        print('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> _loadRecentRecipes() async {
    try {
      var conn = await DatabaseService().connection;
      var results = await conn.query(
        'SELECT recipeName, rating, url FROM recipedb.recipes WHERE accountId = ? ORDER BY createDate DESC LIMIT 4',
        [widget.accountId], // Use the accountId to filter
      );

      setState(() {
        recentItems = results
            .map((row) => PopularItem(
                  imageUrl: row['url'], // URL for the image
                  title: row['recipeName'], // Title of the recipe
                  rating: row['rating'], // Rating of the recipe
                ))
            .toList();
      });

      print('Recent recipes loaded for accountId: ${widget.accountId}');
    } catch (e) {
      print('Error loading recent recipes from database: $e');
    }
  }

  // Method to fetch top 3 recipes from the database based on 'share' column
  Future<void> _loadTopRecipes() async {
    try {
      var conn = await DatabaseService().connection;
      var results = await conn.query(
        'SELECT recipeName, rating, url FROM recipedb.recipes ORDER BY rating DESC LIMIT 3',
      );

      setState(() {
        popularItems = results
            .map((row) => PopularItem(
                  imageUrl: row['url'], // URL for the image
                  title: row['recipeName'], // Title of the recipe
                  rating: row['rating'], // Rating of the recipe
                ))
            .toList();
      });

      print('Top recipes loaded from database.');
    } catch (e) {
      print('Error loading recipes from database: $e');
    }
  }

  Future<void> _savePreferenceToDatabase(String preference) async {
    try {
      var conn = await DatabaseService().connection;

      // Insert the new preference into the database
      await conn.query(
        'INSERT INTO recipedb.preference (accountId, preference) VALUES (?, ?)',
        [widget.accountId, preference],
      );

      print('Preference saved to database.');
    } catch (e) {
      print('Error saving preference to database: $e');
    }
  }

  Future<void> _deletePreferenceFromDatabase(String preference) async {
    try {
      var conn = await DatabaseService().connection;

      // Delete the preference from the database
      await conn.query(
        'DELETE FROM recipedb.preference WHERE accountId = ? AND preference = ?',
        [widget.accountId, preference],
      );

      print('Preference deleted from database.');
    } catch (e) {
      print('Error deleting preference from database: $e');
    }
  }

  Future<void> _loadPreferences() async {
    try {
      var conn = await DatabaseService().connection;

      // Retrieve preferences from the database
      var results = await conn.query(
        'SELECT preference FROM recipedb.preference WHERE accountId = ?',
        [widget.accountId],
      );

      setState(() {
        userInputList = results.map((row) => row[0] as String).toList();
      });

      print('Preferences loaded from database.');
    } catch (e) {
      print('Error loading preferences from database: $e');
    }
  }

  Future<void> _fetchRecipes() async {
    try {
      var conn = await DatabaseService().connection;

      // 查詢食譜資料
      var results = await conn.query(
          'SELECT recipeId, recipeName, createDate, rating, url FROM recipedb.recipes WHERE accountId = ?',
          [widget.accountId]);

      // 將查詢結果轉換為列表形式
      setState(() {
        historicalRecipes = results.map((row) {
          int? id = row['recipeId'];
          if (id == null) {
            throw Exception('recipeId 為 null，請檢查資料庫資料');
          }

          return {
            'recipeId': id, // 確保填充了 recipeId
            'title': row['recipeName'],
            'date': (row['createDate'] as DateTime)
                .toLocal()
                .toString()
                .split(' ')[0],
            'rating': row['rating'],
            'imageUrl': row['url'] ?? 'assets/default_image.png',
          };
        }).toList();
      });

      print('歷史食譜載入成功');
    } catch (e) {
      print('載入歷史食譜出錯: $e');
    }
  }

// List of random content sets
  final List<Map<String, String>> randomContentSets = [
    {
      'image': 'assets/food/food1.jpg',
      'title': '番茄炒蛋',
      'hashtag': '#美食推薦',
    },
    {
      'image': 'assets/food/food2.jpg',
      'title': '牛肉炒飯',
      'hashtag': '#牛肉好吃好吃！',
    },
    {
      'image': 'assets/food/food3.jpg',
      'title': '炒高麗菜',
      'hashtag': '#太清爽拉～',
    },
    {
      'image': 'assets/food/food4.jpg',
      'title': '雞肉沙拉',
      'hashtag': '#食神駕到！',
    },
    {
      'image': 'assets/food/food7.jpg',
      'title': '牛肉意麵',
      'hashtag': '#美味探索',
    },
    {
      'image': 'assets/food/food6.jpg',
      'title': '水果拼盤',
      'hashtag': '#料理魔法',
    },
  ];
  final Random _random = Random();

  Widget _buildBody() {
    switch (_currentPageIndex) {
      case 0:
        return Scaffold(
          body: Column(
            children: [
              // 顶部带背景颜色的Bar部分，包含搜索栏和图标
              Container(
                color: Color(0xFFF1E9E6),
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Text(
                      '社群',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: '尋找食譜',
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            filled: true,
                            fillColor: Colors.transparent,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // 添加帖子的按钮
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddPostPage(accountId: widget.accountId)),
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Ink(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: Color(0xFFF1E9E6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Icon(Icons.add, color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        // 喜欢按钮
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FavoritePage(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Ink(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: Color(0xFFF1E9E6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child:
                                    Icon(Icons.favorite, color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        // 三条线图标按钮，导航到 PostManagement 页面
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PostManagement(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Ink(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: Color(0xFFF1E9E6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Icon(Icons.menu, color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 動態貼文展示
              Expanded(
                child: posts.isEmpty
                    ? Center(child: CircularProgressIndicator()) // 資料載入中
                    : ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(
                              child: Container(
                                width: 300,
                                height: 400,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // 顯示食譜圖片
                                        ClipRRect(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(16),
                                          ),
                                          child: Image.network(
                                            post['url'], // 動態載入食譜圖片 URL
                                            height: 250,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // 顯示食譜名稱
                                              Text(
                                                post['recipeName'], // 動態載入食譜名稱
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              // 顯示潑文時間
                                              Text(
                                                '潑文時間: ${post['postTime']}', // 動態載入潑文時間
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Spacer(),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6.0,
                                            vertical: 2.0,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              // 功能按鈕
                                              IconButton(
                                                icon: Icon(Icons.close,
                                                    color: Colors.red),
                                                onPressed: () {},
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.skip_next,
                                                    color: Colors.grey),
                                                onPressed: () {},
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.favorite,
                                                    color: Colors.green),
                                                onPressed: () {},
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    // 詳細資訊按鈕
                                    Positioned(
                                      right: 8,
                                      top: 8,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PostPage(index: index),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.orange,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 10,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.info,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );

      case 1:
        return Container(
          color: Color(0xFFF1E9E6), // Background color of the container
          padding: EdgeInsets.all(16.0), // Padding for the container
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                '飲食偏好',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        child: TextFormField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: '輸入偏好',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(color: Color(0xFFF2B892)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(color: Color(0xFFF2B892)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(color: Color(0xFFF2B892)),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                          ),
                          onChanged: (value) {
                            setState(() {
                              userInput = value;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF2B892),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                        onPressed: userInput.isNotEmpty
                            ? () {
                                setState(() {
                                  userInputList.add(userInput);
                                  _savePreferenceToDatabase(userInput);
                                  _controller.clear();
                                  userInput = '';
                                });
                              }
                            : null,
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: userInputList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Card(
                        color: Color(0xFFFFFAF5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(10),
                          title: Text(
                            userInputList[index],
                            style: TextStyle(fontSize: 18.0),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Color(0xFFF2B892)),
                            onPressed: () {
                              setState(() {
                                _deletePreferenceFromDatabase(
                                    userInputList[index]);
                                userInputList.removeAt(index);
                              });
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );

      case 2:
        return Container(
          color: Color(0xFFF1E9E6),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                child: Column(
                  children: [
                    SizedBox(height: 40),
                    Text(
                      '精選食譜',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    if (popularItems
                        .isNotEmpty) // Only display carousel if items are loaded
                      Container(
                        child: CarouselSlider(
                          options: CarouselOptions(
                            height: 250.0,
                            autoPlay: true,
                            enlargeCenterPage: true,
                            aspectRatio: 16 / 9,
                            autoPlayCurve: Curves.fastOutSlowIn,
                            enableInfiniteScroll: true,
                            autoPlayAnimationDuration:
                                Duration(milliseconds: 800),
                            viewportFraction: 0.8,
                          ),
                          items: popularItems.map((item) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage(item
                                                  .imageUrl), // Load image from URL
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        item.title,
                                        style: TextStyle(
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    SizedBox(height: 20),
                    InkResponse(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PickImage(accountId: widget.accountId),
                          ),
                        );
                      },
                      child: Container(
                        width: 300,
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15), // 圓角
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFF2B892).withOpacity(0.6), // 周圍發光
                              spreadRadius: 5,
                              blurRadius: 7,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset('assets/Camera.jpg',
                              fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '    最近做過~',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    if (recentItems.isNotEmpty)
                      Container(
                        height: 125,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: recentItems.length,
                          itemBuilder: (context, index) {
                            PopularItem item = recentItems[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                  left: 10), // Adjust left padding
                              child: Center(
                                child: Container(
                                  width: 120,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 4), // Spacing between images
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: SizedBox(
                                            width: 120, // 設置固定寬度
                                            height: 125, // 設置固定高度
                                            child: Image.network(
                                              item.imageUrl,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        item.title,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.favorite,
                                            color: Colors
                                                .red, // Change to red for a heart shape
                                            size: 14,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            '${item.rating}',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Text('目前還沒生成過任何食譜～'),
                    Expanded(
                      child: SizedBox(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case 3:
        return Container(
          color: Color(0xFFF1E9E6),
          child: Column(
            children: [
              SizedBox(height: 40),
              Text(
                '歷史食譜',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: historicalRecipes.isEmpty
                    ? Center(child: CircularProgressIndicator()) // 顯示加載指示器
                    : ListView.builder(
                        itemCount: historicalRecipes.length,
                        itemBuilder: (context, index) {
                          var recipe = historicalRecipes[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Card(
                              color: Color(0xFFFFFAF5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(10),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    recipe['imageUrl'],
                                    fit: BoxFit.cover,
                                    width: 50,
                                    height: 50,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/default_image.png',
                                        width: 50,
                                        height: 50,
                                      );
                                    },
                                  ),
                                ),
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      recipe['title'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.favorite,
                                            color: Colors.red, size: 20),
                                        Text(
                                          ' ${recipe['rating']}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                subtitle: Text(
                                  '製作時間：${recipe['date']}', // 在日期前加上 "製作時間："
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                onTap: () {
                                  int? recipeId = recipe['recipeId'];
                                  if (recipeId != null) {
                                    // 確保 recipeId 存在
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HistoryPage(
                                            recipeId:
                                                recipeId), // 傳遞 recipeId 到 HistoryPage
                                      ),
                                    );
                                  } else {
                                    print('無效的 recipeId，無法跳轉到 HistoryPage');
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );

      case 4:
        return Scaffold(
          backgroundColor: Color(0xFFF1E9E6),
          body: Padding(
            padding: const EdgeInsets.only(top: 1.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 0.3),
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: profileImageUrl.isNotEmpty
                                ? NetworkImage(profileImageUrl)
                                : AssetImage('assets/images.png')
                                    as ImageProvider,
                          ),
                        ),
                        padding: const EdgeInsets.all(10),
                      ),
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: _pickImage, // Trigger image picker on tap
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              color: Color(0xFFF2B892),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    userName,
                    style: TextStyle(fontSize: 38),
                  ),
                  SizedBox(height: 0),
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontSize: 10,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF2B892),
                      padding:
                          EdgeInsets.symmetric(horizontal: 110, vertical: 10),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                    child: Text('登出', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      default:
        return Container();
    }
  }
}
