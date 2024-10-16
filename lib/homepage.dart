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
import 'package:mysql1/mysql1.dart';
import 'package:recipe_gpt/db/db.dart';

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
  int _currentPageIndex = 2; // 当前页面索引
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  String userInput = '';
  TextEditingController _controller = TextEditingController();
  List<String> userInputList = [];
  List<PopularItem> popularItems = [];
  List<PopularItem> recentItems = [];
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
        'SELECT recipeName, rating, url FROM recipedb.recipes ORDER BY shared DESC LIMIT 3',
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
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(8),
                            child: Ink(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: Color(0xFFF1E9E6), // 修改图标背景色
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.add,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(8),
                            child: Ink(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: Color(0xFFF1E9E6), // 修改图标背景色
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.favorite,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(8),
                            child: Ink(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: Color(0xFFF1E9E6), // 修改图标背景色
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.menu, // 更改为菜单图标
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 下滑可滚动的内容部分
              Expanded(
                child: ListView.builder(
                  itemCount: 10, // 控制滑动项目的数量
                  itemBuilder: (context, index) {
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16)),
                                child: Image.asset(
                                  'assets/LOGO.png',
                                  height: 250,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '好食在 $index', // 显示不同的索引
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '#創意料理 $index',
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
                                    horizontal: 6.0, vertical: 2.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    IconButton(
                                      icon:
                                          Icon(Icons.close, color: Colors.red),
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
        List<Map<String, dynamic>> historicalRecipes = [
          {
            'imageUrl': 'assets/food/food1.jpg',
            'title': '番茄炒蛋',
            'description': '簡單易做的番茄炒蛋，營養豐富。',
            'rating': 8.8,
          },
          {
            'imageUrl': 'assets/food/food2.jpg',
            'title': '牛肉炒飯',
            'description': '新鮮的牛肉與香脆的蔬菜完美結合，豐富的層次感。',
            'rating': 8.1,
          },
          {
            'imageUrl': 'assets/food/food3.jpg',
            'title': '炒高麗菜',
            'description': '口感鮮嫩，營養豐富的炒高麗菜。',
            'rating': 9.2,
          },
          {
            'imageUrl': 'assets/food/food4.jpg',
            'title': '雞肉沙拉',
            'description': '健康清爽的雞肉沙拉,適合夏日輕食。',
            'rating': 9.1,
          },
          {
            'imageUrl': 'assets/food/food7.jpg',
            'title': '牛肉意面',
            'description': '香濃美味的牛肉意面,百吃不厭。',
            'rating': 8.6,
          },
          {
            'imageUrl': 'assets/food/food6.jpg',
            'title': '早餐水果拼盤',
            'description': '各種新鮮水果的精彩組合。',
            'rating': 8.2,
          },
          {
            'imageUrl': 'assets/food/food8.jpg',
            'title': '香菇炒麵',
            'description': '香氣四溢的香菇炒麵，美味可口。',
            'rating': 9.0,
          },
          {
            'imageUrl': 'assets/food/food9.jpg',
            'title': '鮮蝦沙拉',
            'description': '清爽可口的鮮蝦沙拉，滿滿的海鮮風味。',
            'rating': 8.9,
          },
        ];

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
                child: ListView.builder(
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
                            child: Image.asset(
                              recipe['imageUrl'],
                              fit: BoxFit.cover,
                              width: 50,
                              height: 50,
                            ),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            recipe['description'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HistoryPage()),
                            );
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
