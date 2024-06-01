import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:recipe_gpt/controller/pick_image.dart';
import 'package:recipe_gpt/login.dart';
import 'package:recipe_gpt/main.dart';
import 'package:recipe_gpt/services/openai/chat_response.dart';
import 'package:recipe_gpt/services/openai/chat_screen.dart';
import 'package:recipe_gpt/camerafunction.dart';

void main() => runApp(MaterialApp(home: LoginCard()));

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentPageIndex = 2; // 当前页面索引
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  String userInput = '';
  TextEditingController _controller = TextEditingController();
  List<String> userInputList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _currentPageIndex,
        height: 60.0,
        items: <Widget>[
          Icon(Icons.group, size: 30),
          Icon(Icons.list, size: 30),
          Icon(Icons.camera, size: 45),
          Icon(Icons.history, size: 30),
          Icon(Icons.perm_identity, size: 30),
        ],
        color: Color.fromARGB(255, 255, 196, 106),
        buttonBackgroundColor: Color.fromARGB(255, 255, 196, 106),
        backgroundColor: Color.fromARGB(255, 247, 238, 163),
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
          color: Color.fromARGB(255, 247, 238, 163),
          child: Center(
            child: Text('社群'),
          ),
        );

      case 1:
        return Container(
          color: Color.fromARGB(255, 247, 238, 163),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 50),
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
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
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
                        height: 50,
                        child: ElevatedButton(
                          onPressed: userInput.isNotEmpty
                              ? () {
                                  setState(() {
                                    userInputList.add(userInput);
                                    _controller.clear();
                                    userInput = '';
                                  });
                                }
                              : null,
                          child: Text('送出'),
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
                      return ListTile(
                        title: Text(
                          userInputList[index],
                          style: TextStyle(fontSize: 18.0),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              userInputList.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );

      case 2:
        return Container(
          color: Color.fromARGB(255, 247, 238, 163),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Column(
                children: [
                  Container(
                    height: 320.0, // 调整高度
                    child: CarouselSlider(
                      options: CarouselOptions(
                        height: 200.0,
                        autoPlay: true,
                        enlargeCenterPage: true,
                        aspectRatio: 16 / 9,
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enableInfiniteScroll: true,
                        autoPlayAnimationDuration: Duration(milliseconds: 800),
                        viewportFraction: 0.8,
                      ),
                      items: [
                        'assets/images.png',
                        'assets/image/food.jpg',
                        'assets/image/note.jpg',
                      ].map((i) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.symmetric(horizontal: 5.0),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(i),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(),
                  ), // 使按钮位置靠下
                ],
              ),
              Positioned(
                bottom: 50, // 调整底部位置
                child: SizedBox(
                  width: 300, // 调整宽度
                  height: 150, // 调整高度
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Camera()),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.transparent),
                      padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.zero),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images.png'), // 替换为您的图片路径
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          'Go to Camera',
                          style: TextStyle(
                            color: Colors.white, // 调整文字颜色
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

      case 3:
        return Container(
          color: Color.fromARGB(255, 247, 238, 163),
          child: Center(
            child: Text('歷史食譜'),
          ),
        );

      case 4:
        return Scaffold(
          backgroundColor: Color.fromARGB(255, 247, 238, 163),
          body: Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 0.5),
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: AssetImage('assets/images.png'),
                          ),
                        ),
                        padding: const EdgeInsets.all(10),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    '用戶名稱: Bob\n性別: Man\n電子郵件: Bob@gmail.com',
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    child: Text('登出'),
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
