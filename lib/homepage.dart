import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:recipe_gpt/controller/pick_image.dart';
import 'package:recipe_gpt/login.dart';
import 'package:recipe_gpt/main.dart';
import 'package:recipe_gpt/services/openai/chat_response.dart';
import 'package:recipe_gpt/empty.dart';
import 'package:recipe_gpt/services/openai/chat_screen.dart';
import 'package:recipe_gpt/views/camera_view.dart';
import 'package:recipe_gpt/camerafunction.dart';

void main() => runApp(MaterialApp(home: LoginCard()));

class HomePage extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<HomePage> {
  int _currentPageIndex = 2; // 默认选中第三个页面（索引从0开始）
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _currentPageIndex, // 初始位置
        height: 60.0,
        items: <Widget>[
          Icon(Icons.group, size: 30),
          Icon(Icons.list, size: 30),
          Icon(Icons.camera, size: 45),
          Icon(Icons.history, size: 30),
          Icon(Icons.perm_identity, size: 30), // 按钮大小
        ],
        color: Color.fromARGB(255, 255, 196, 106), // 下方整体颜色
        buttonBackgroundColor: Color.fromARGB(255, 255, 196, 106),
        backgroundColor: Color.fromARGB(255, 247, 238, 163),
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 350), // 改速度
        onTap: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        letIndexChange: (index) => true, // 动画开关
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_currentPageIndex) {
      case 0:
        // 第一个页面的内容
        return Container(
          color: Color.fromARGB(255, 247, 238, 163), // 背景色
          child: Center(
            child: Text('社群'),
          ),
        );

      case 1:
        // 第二个页面的内容
        return Container(
          color: Color.fromARGB(255, 247, 238, 163), // 背景色
          child: Center(
            child: Text('飲食偏好'),
          ),
        );

      case 2:
        // 第三个页面的内容
        return Container(
          color: Color.fromARGB(255, 247, 238, 163), // 背景色
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  child: Text('生成食谱'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChatPage()),
                    );
                  },
                ),
                SizedBox(height: 20), // +间距

                ElevatedButton(
                  child: Text('CameraView'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      //MaterialPageRoute(builder: (context) => CameraView()),
                      MaterialPageRoute(builder: (context) => PickImage()),
                    );
                  },
                ),
                SizedBox(height: 20), // +间距

                ElevatedButton(
                  child: Text('MainButton'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Camera()),
                    );
                  },
                ),
              ],
            ),
          ),
        );

      case 3:
        // 第四个页面的内容
        return Container(
          color: Color.fromARGB(255, 247, 238, 163), // 背景色
          child: Center(
            child: Text('歷史食譜'),
          ),
        );

      case 4:
      // 第五个页面的内容
      case 4:
        // 第五个页面的内容
        return Scaffold(
          backgroundColor: Color.fromARGB(255, 247, 238, 163), // 背景色
          body: Padding(
            padding: const EdgeInsets.only(top: 50.0), // 向上移動 50 像素
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start, // 將子元件靠左對齊
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.black, width: 0.5), // 添加外框
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: AssetImage('assets/images.png'), //
                          ),
                        ),
                        padding: const EdgeInsets.all(10),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            // 上傳圖片
                          },
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
                  SizedBox(height: 20), // +間距
                  Text(
                    '用戶名稱: Bob\n性別: Man\n電子郵件: Bob@gmail.com',
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 20), // +間距
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
