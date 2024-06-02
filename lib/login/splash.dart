import 'package:flutter/material.dart';
import 'package:recipe_gpt/login.dart';
import 'package:recipe_gpt/login/onboarding.dart';

class MealPlannerSplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255), // 設定背景顏色為綠色
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Align(
              alignment: AlignmentDirectional(0, 0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      //color: Theme.of(context).primaryColor,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage(
                          'assets/LOGO.png',
                        ),
                      ),
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '好',
                            style: TextStyle(
                              letterSpacing: 0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold, // 粗體字型
                            ),
                          ),
                          TextSpan(
                            text: '食',
                            style: TextStyle(
                              color: Color(0xFFDD8A62),
                              letterSpacing: 0,
                              fontWeight: FontWeight.bold, // 粗體字型
                            ),
                          ),
                          TextSpan(
                            text: '在',
                            style: TextStyle(
                              letterSpacing: 0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold, // 粗體字型
                            ),
                          )
                        ],
                        style: TextStyle(
                          fontSize: 32,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(24, 0, 24, 12),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    // 點擊事件
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OnboardingSlideshow()),
                    );
                  },
                  child: Text(
                    '開始使用',
                    style: TextStyle(
                      color: Colors.black, // 將文字顏色設定為黑色
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF2B892),
                    textStyle: TextStyle(
                      letterSpacing: 0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    // 點擊事件
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Login()),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 24, 0, 24),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '已經加入會員?  ',
                            style: TextStyle(
                              letterSpacing: 0,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: '登入',
                            style: TextStyle(
                              letterSpacing: 0,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              color: Colors.black,
                            ),
                          )
                        ],
                        style: TextStyle(
                          letterSpacing: 0,
                        ),
                      ),
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
}
