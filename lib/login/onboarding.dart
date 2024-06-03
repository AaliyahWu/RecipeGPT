import 'package:flutter/material.dart';
import 'package:recipe_gpt/login.dart';
import 'package:recipe_gpt/login/splash.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingSlideshow extends StatefulWidget {
  @override
  _OnboardingSlideshowState createState() => _OnboardingSlideshowState();
}

class _OnboardingSlideshowState extends State<OnboardingSlideshow> {
  final _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1E9E6), // 設定背景顏色
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1E9E6), // 設定 AppBar 顏色
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // 點擊事件
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MealPlannerSplashScreen()),
            );
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: <Widget>[
                buildPage(
                    '\n你是否曾面對著食材滿當當的冰箱，卻不知道該煮什麼?\n一直一直買新的食材，卻造成許多食物過期而浪費。\n那就快來使用好食在吧！\n',
                    'assets/Page1.png',
                    '跳過'),
                buildPage('\n透過影像辨識及可自動生成食譜的功能\n輕易解決糧食浪費問題\n讓你每天都有新菜色，不僅吃的開心還健康。\n',
                    'assets/Page2.png', '跳過'),
                buildPage('\n感興趣嗎！快點擊下方按鈕\n立即加入「好食在」這個大家庭吧！', 'assets/Page3.png', '登入'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0), // 將頁面指示器向上移動
            child: Column(
              children: <Widget>[
                SmoothPageIndicator(
                  controller: _pageController, // PageController
                  count: 3, // 頁面數量
                  effect: ExpandingDotsEffect(
                    activeDotColor: Color(0xFFDD8A62), // 活動點的顏色
                    dotColor: Colors.grey, // 點的顏色
                  ), // 指示器效果
                ),
                SizedBox(height: 20), // 添加間距
                ElevatedButton(
                  onPressed: () {
                    // 點擊事件
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  },
                  child: Text(
                    '繼續',
                    style: TextStyle(
                      color: Colors.black, // 將文字顏色設定為黑色
                      fontSize: 12, // 將文字大小設定為 12
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF2B892),
                    foregroundColor: Colors.white,
                    minimumSize: Size(200, 30),
                    textStyle: TextStyle(
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPage(String text, String imagePath, String buttonText) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            imagePath,
            width: 200,
            height: 200,
          ), // 添加圖片
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
          // ElevatedButton(
          //   onPressed: () {
          //     // 點擊事件
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => Login()),
          //     );
          //   },
          //   child: Text(
          //     buttonText,
          //     style: TextStyle(
          //       color: Colors.black, // 將文字顏色設定為黑色
          //       fontSize: 12, // 將文字大小設定為 12
          //     ),
          //   ),
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: Color(0xFFF2B892),
          //     minimumSize: Size(200, 30),
          //     textStyle: TextStyle(
          //       letterSpacing: 0,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
