import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:recipe_gpt/controller/pick_image.dart';
import 'package:recipe_gpt/login.dart';
import 'package:recipe_gpt/login/splash.dart';
import 'package:recipe_gpt/main.dart';
import 'package:recipe_gpt/services/openai/chat_response.dart';
import 'package:recipe_gpt/services/openai/chat_screen.dart';
import 'package:recipe_gpt/camerafunction.dart';

void main() => runApp(MaterialApp(home: LoginCard()));

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class PopularItem {
  final String imageUrl;
  final String title;
  final double rating;

  PopularItem(
      {required this.imageUrl, required this.title, required this.rating});
}

class _HomePageState extends State<HomePage> {
  int _currentPageIndex = 2; // 当前页面索引
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  String userInput = '';
  TextEditingController _controller = TextEditingController();
  List<String> userInputList = [];

  bool _isNotificationEnabled = true; // 管理通知開關狀態(預設開)

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

  Widget _buildBody() {
    switch (_currentPageIndex) {
      case 0:
        return Container(
          color: Color(0xFFF1E9E6),
          child: Center(
            child: Text('社群'),
          ),
        );

      case 1:
        return Container(
          color: Color(0xFFF1E9E6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 40),
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
                            //hintStyle: TextStyle(color: Colors.grey),
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
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: Color(0xFFF2B892),
                        //     spreadRadius: 3,
                        //     blurRadius: 5,
                        //   ),
                        // ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          //backgroundColor: Color(0xFFF2B892),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                        onPressed: userInput.isNotEmpty
                            ? () {
                                setState(() {
                                  userInputList.add(userInput);
                                  _controller.clear();
                                  userInput = '';
                                });
                              }
                            : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add),
                            //SizedBox(width: 1),
                            // Text(
                            //   '添加',
                            //   style: TextStyle(color: Colors.white),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount:
                      userInputList.length + 1, // Including the pre-saved data
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Pre-saved data
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
                              '高蛋白質',
                              style: TextStyle(fontSize: 18.0),
                            ),
                            trailing: IconButton(
                              icon:
                                  Icon(Icons.delete, color: Color(0xFFF2B892)),
                              onPressed: () {
                                setState(() {
                                  // Handle delete action for pre-saved data if needed
                                });
                              },
                            ),
                          ),
                        ),
                      );
                    } else {
                      // User input data
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(10),
                            title: Text(
                              userInputList[index - 1],
                              style: TextStyle(fontSize: 18.0),
                            ),
                            trailing: IconButton(
                              icon:
                                  Icon(Icons.delete, color: Color(0xFFF2B892)),
                              onPressed: () {
                                setState(() {
                                  userInputList.removeAt(index - 1);
                                });
                              },
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );

      //     case 1:
      // return Container(
      //   color: Color(0xFFF1E9E6),
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.start,
      //     children: [
      //       SizedBox(height: 50),
      //       Padding(
      //         padding: EdgeInsets.symmetric(horizontal: 20.0),
      //         child: Row(
      //           children: [
      //             Expanded(
      //               child: Container(
      //                 height: 50,
      //                 child: TextFormField(
      //                   controller: _controller,
      //                   decoration: InputDecoration(
      //                     hintText: '輸入偏好',
      //                     border: OutlineInputBorder(
      //                       borderSide: BorderSide(color: Color(0xFFF2B892)),
      //                     ),
      //                     enabledBorder: OutlineInputBorder(
      //                       borderSide: BorderSide(color: Color(0xFFF2B892)),
      //                     ),
      //                     focusedBorder: OutlineInputBorder(
      //                       borderSide: BorderSide(color: Color(0xFFF2B892)),
      //                     ),
      //                     contentPadding: EdgeInsets.symmetric(
      //                         vertical: 10, horizontal: 10),
      //                   ),
      //                   onChanged: (value) {
      //                     setState(() {
      //                       userInput = value;
      //                     });
      //                   },
      //                 ),
      //               ),
      //             ),
      //             SizedBox(width: 10),
      //             Container(
      //               height: 50,
      //               child: ElevatedButton(
      //                 onPressed: userInput.isNotEmpty
      //                     ? () {
      //                         setState(() {
      //                           userInputList.add(userInput);
      //                           _controller.clear();
      //                           userInput = '';
      //                         });
      //                       }
      //                     : null,
      //                 child: Text('添加'),
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //       SizedBox(height: 20),
      //       Expanded(
      //         child: ListView.builder(
      //           itemCount: userInputList.length + 1, // Including the pre-saved data
      //           itemBuilder: (context, index) {
      //             if (index == 0) {
      //               // Pre-saved data
      //               return Padding(
      //                 padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      //                 child: Card(
      //                   shape: RoundedRectangleBorder(
      //                     borderRadius: BorderRadius.circular(10),
      //                   ),
      //                   child: ListTile(
      //                     contentPadding: EdgeInsets.all(10),
      //                     title: Text(
      //                       '高蛋白質',
      //                       style: TextStyle(fontSize: 18.0),
      //                     ),
      //                     trailing: IconButton(
      //                       icon: Icon(Icons.delete, color: Color(0xFFF2B892)),
      //                       onPressed: () {
      //                         setState(() {
      //                           // Handle delete action for pre-saved data if needed
      //                         });
      //                       },
      //                     ),
      //                   ),
      //                 ),
      //               );
      //             } else {
      //               // User input data
      //               return Padding(
      //                 padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      //                 child: Card(
      //                   shape: RoundedRectangleBorder(
      //                     borderRadius: BorderRadius.circular(10),
      //                   ),
      //                   child: ListTile(
      //                     contentPadding: EdgeInsets.all(10),
      //                     title: Text(
      //                       userInputList[index - 1],
      //                       style: TextStyle(fontSize: 18.0),
      //                     ),
      //                     trailing: IconButton(
      //                       icon: Icon(Icons.delete, color: Color(0xFFF2B892)),
      //                       onPressed: () {
      //                         setState(() {
      //                           userInputList.removeAt(index - 1);
      //                         });
      //                       },
      //                     ),
      //                   ),
      //                 ),
      //               );
      //             }
      //           },
      //         ),
      //       ),
      //     ],
      //   ),
      // );

      case 2:
        List<PopularItem> dummyPopularItems() {
          return [
            PopularItem(
              imageUrl: 'assets/food/food1.jpg',
              title: '番茄炒蛋',
              rating: 8.8,
            ),
            PopularItem(
              imageUrl: 'assets/food/food2.jpg',
              title: '牛肉炒飯',
              rating: 8.1,
            ),
            PopularItem(
              imageUrl: 'assets/food/food3.jpg',
              title: '炒高麗菜',
              rating: 9.2,
            ),
            // Add more dummy data as needed
          ];
        }

        return Container(
          color: Color(0xFFF1E9E6),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                // 新加的 Container 包裹原始的 Column
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
                        items: [
                          {'image': 'assets/food/food4.jpg', 'title': '雞肉沙拉'},
                          {'image': 'assets/food/food5.jpg', 'title': '蔬菜湯'},
                          {'image': 'assets/food/food6.jpg', 'title': '早餐水果拼盤'},
                        ].map((item) {
                          final imageUrl = item['image'] ?? '';
                          final title = item['title'] ?? '';

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
                                            image: AssetImage(imageUrl),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      title,
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
                    Positioned(
                      bottom: 50,
                      child: SizedBox(
                        width: 300,
                        height: 140,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PickImage(),
                              ),
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.transparent),
                            padding: MaterialStateProperty.all<EdgeInsets>(
                                EdgeInsets.zero),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images.png'),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                '生成食譜',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                          ),
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
                    Container(
                      height: 125,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: dummyPopularItems()
                            .length, // 使用預先定義的假數據列表的長度 注意這裡調用了 dummyPopularItems 函數並使用其返回值的長度
                        itemBuilder: (context, index) {
                          PopularItem item = dummyPopularItems()[
                              index]; // 注意這裡也調用了 dummyPopularItems 函數並使用其返回值的索引
                          return Padding(
                            padding: EdgeInsets.only(left: 10), // 調整左邊填充量
                            child: Center(
                              child: Container(
                                width: 100,
                                margin: EdgeInsets.symmetric(
                                    horizontal: 4), // 圖片間間隔
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.asset(
                                          item.imageUrl,
                                          fit: BoxFit.cover,
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
                                          '${item.rating}' + '',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    // TextButton(
                                    //   onPressed: () {
                                    //     // 處理 "View Now" 按鈕點擊事件
                                    //   },
                                    // child: Text(
                                    //   '查看食譜',
                                    //   style: TextStyle(
                                    //     fontSize: 16,
                                    //     // fontWeight: FontWeight.bold,
                                    //     color: Color(0xFFDD8A62),
                                    //   ),
                                    //   textAlign: TextAlign.center, // 置中對齊
                                    // ),
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: SizedBox(),
                    ),
                  ],
                ),
              ),

              //  add new container **************************
              // Container(
              //   // 新加的 Container 包裹新的 Column
              //   child: Column(
              //     children: [
              //       // Add your content for the second column here
              //     ],
              //   ),
              // ),
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
          // 可以在這裡添加更多模擬數據
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
              SizedBox(height: 10),
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
                          // trailing: CircleAvatar(
                          //   backgroundColor: Color(0xFFF2B892),
                          //   child: Text(
                          //     recipe['rating'].toString(),
                          //     style: TextStyle(
                          //       fontSize: 16,
                          //       fontWeight: FontWeight.bold,
                          //       color: Colors.black,
                          //     ),
                          //   ),
                          // ),
                          onTap: () {
                            // 導航至食譜詳情頁面
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
                            image: AssetImage('assets/images.png'),
                          ),
                        ),
                        padding: const EdgeInsets.all(10),
                      ),
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: () {},
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
                  // SizedBox(height: 10),
                  Text(
                    'Test',
                    style: TextStyle(fontSize: 38),
                  ),
                  SizedBox(height: 0),
                  Text(
                    'test@test.com',
                    style: TextStyle(
                      fontSize: 10,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  // SizedBox(height: 20),
                  // ElevatedButton(
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Color(0xFFDD8A62),
                  //     padding:
                  //         EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  //     textStyle: TextStyle(fontSize: 14),
                  //   ),
                  //   child: Text('編輯個人資料',
                  //       // style: TextStyle(color: Color(0xFFDD8A62))),
                  //       style: TextStyle(color: Colors.white)),
                  //   onPressed: () {
                  //     //
                  //   },
                  // ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '管理通知',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(width: 100),
                      Transform.scale(
                        scale: 0.6,
                        child: Switch(
                          value: _isNotificationEnabled,
                          //activeColor: Color(0xFFDD8A62), // 這裡是開啟狀態下的顏色
                          inactiveThumbColor: Color(0xFFF2B892), // 這裡是關閉狀態下的顏色
                          //inactiveTrackColor: Color(0xFFF2B892), // 這裡是背景顏色
                          onChanged: (bool value) {
                            setState(() {
                              _isNotificationEnabled = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '找朋友',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(width: 100),
                      // ElevatedButton(
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Color(0xFFF2B892),
                      //     foregroundColor: Colors.white,
                      //     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      //     textStyle: TextStyle(fontSize: 14),
                      //   ),
                      //   child: Text('分享'),
                      //   onPressed: () {
                      //     //
                      //   },
                      // ),

                      ElevatedButton(
                        onPressed: () async {
                          // 點擊事件
                        },
                        child: Text(
                          '分享',
                          style: TextStyle(
                            color: Colors.white, // 文字顏色
                            // color: Colors.black, // 文字顏色
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF2B892),
                          foregroundColor: Colors.white,
                          minimumSize: Size(52, 30),
                          textStyle: TextStyle(
                            letterSpacing: 0,
                            fontSize: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF2B892),
                      padding:
                          EdgeInsets.symmetric(horizontal: 110, vertical: 10),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                    child:
                        // Text('登出', style: TextStyle(color: Color(0xFFDD8A62))),
                        Text('登出', style: TextStyle(color: Colors.white)),
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
