import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

void main() => runApp(MaterialApp(home: HomePage()));

class HomePage extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<HomePage> {
  int _page = 0;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: CurvedNavigationBar(
          key: _bottomNavigationKey,
          index: 2,//初始位置?
          height: 60.0,
          items: <Widget>[
            Icon(Icons.home, size: 30),
            Icon(Icons.list, size: 30),
            Icon(Icons.camera, size: 45),
            Icon(Icons.perm_identity, size: 30),
            Icon(Icons.settings, size: 30),//按鈕大小
          ],
          color: Color.fromARGB(255, 255, 196, 106), //下面整體顏色
          buttonBackgroundColor: Color.fromARGB(255, 255, 196, 106),
          backgroundColor: Color.fromARGB(255, 247, 238, 163),
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 350),//改速度
          onTap: (index) {
            setState(() {
              _page = index;
            });
          },
          letIndexChange: (index) => true, //動畫開關
        ),


        body: Container(
          color: Color.fromARGB(255, 247, 238, 163),//背景色
          child: Center(
            // child: Column(
            //   // mainAxisAlignment: MainAxisAlignment.center,
            //   // children: <Widget>[
            //   //   Text(_page.toString(), textScaleFactor: 2.0),//數字大小
            //     // ElevatedButton(
            //     //   child: Text('Go To Page of index 1'),
            //     //   // onPressed: () {
            //     //   //   // final CurvedNavigationBarState? navBarState =
            //     //   //   //     _bottomNavigationKey.currentState;
            //     //   //   // navBarState?.setPage(1);//返回按鈕1
            //     //   // },
            //     // )
            //   // ],
            // ),
          ),
        ));
  }
}