import 'dart:math';

import 'package:english_leitner_box/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroSliderPage extends StatefulWidget {
  @override
  _IntroSliderPageState createState() => _IntroSliderPageState();
}

class _IntroSliderPageState extends State<IntroSliderPage> {
  int page = 0;
  LiquidController liquidController;
  UpdateType updateType;

  @override
  void initState() {
    liquidController = LiquidController();
    super.initState();
  }

  final pages = [
    Scaffold(
      backgroundColor: Colors.deepPurpleAccent,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 30.0),
        child: FloatingActionButton.extended(
          onPressed: () {},
          label: Text(
            'کارت جدید',
            style: TextStyle(fontFamily: 'Homa'),
          ),
          icon: Icon(Icons.add),
          backgroundColor: Colors.pink,
        ),
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: Image.asset('images/page_1_intro.png'),
          ),
          Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'از این قسمت میتونی کارت ها رو اضافه کنی',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white, fontFamily: 'Homa', fontSize: 30.0),
                ),
              )),

        ],
      ),
    ),
    Container(
      color: Colors.yellowAccent,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Image.asset('images/page_2_intro.png'),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'میتونی با این قسمت کارت ها رو در دسته های مختلف قرار بدی',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Homa', color: Colors.black, fontSize: 30.0),
              ),
            ),
          ),
        ],
      ),
    ),
    Container(
      color: Colors.blue,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50, left: 8, right: 8),
              child: Image.asset('images/page_3_intro.png'),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 32.0, right: 32.0, bottom: 100),
              child: Text(
                'یادت نره \nهر روز کارت های خودتو مرور کن',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Homa', color: Colors.white, fontSize: 30.0),
              ),
            ),
          ],
        ),
      ),
    ),
    Container(
      color: Colors.lightGreenAccent,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(top: 24.0),
              child: Image.asset('images/page_4_intro.png'),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 32.0, right: 32.0, top: 50.0),
              child: Text(
                'میتونی برای کلمات انگلیسی تلفظ صحیح کلمات رو بشنوی',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Homa', color: Colors.black, fontSize: 30.0),
              ),
            ),
          ),
        ],
      ),
    ),
    Container(
      color: Colors.cyanAccent,
      child: Stack(
        children: [
          Image.asset('images/page_5_intro.png'),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 32.0, right: 32.0, top: 100.0),
              child: Text(
                'میتونی از کارت هات پشتیبان بگیری',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Homa', color: Colors.black, fontSize: 30.0),
              ),
            ),
          ),
        ],
      ),
    ),
    Container(
      color: Colors.pink,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'دیگه حرفی نمونده\nوارد برنامه شو',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Homa', color: Colors.white, fontSize: 30.0),
          ),
        ),
      ),
    ),
  ];

  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - ((page ?? 0) - index).abs(),
      ),
    );
    double zoom = 1.0 + (2.0 - 1.0) * selectedness;
    return new Container(
      width: 25.0,
      child: new Center(
        child: new Material(
          color: Colors.white,
          type: MaterialType.circle,
          child: new Container(
            width: 8.0 * zoom,
            height: 8.0 * zoom,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          LiquidSwipe(
            pages: pages,
            onPageChangeCallback: pageChangeCallback,
            waveType: WaveType.liquidReveal,
            liquidController: liquidController,
            ignoreUserGestureWhileAnimating: true,
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                Expanded(child: SizedBox()),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(pages.length, _buildDot),
                ),
              ],
            ),
          ),
          Visibility(
            visible: page == pages.length - 1,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 128.0),
                child: RaisedButton(
                  color: Colors.white,
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => MyHomePage()));
                    setFirstEnter();
                  },
                  child: Text(
                    'ورود به برنامه',
                    style: TextStyle(
                        color: Colors.pink, fontFamily: 'Homa', fontSize: 20.0),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: page!=pages.length-1,
            child: Align(
              alignment: page==0? Alignment.topRight : Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => MyHomePage()));
                    setFirstEnter();
                  },
                  child: Text(
                    "ورود به برنامه",
                    style: TextStyle(fontFamily: 'Homa'),
                  ),
                  color: Colors.white.withOpacity(0.01),
                ),
              ),
            ),
          ),
          Visibility(
            visible: page!=pages.length-1,
            child: Align(
              alignment: page==0? Alignment.topLeft : Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: FlatButton(
                  onPressed: () {
                    liquidController.animateToPage(
                        page: liquidController.currentPage + 1, duration: 500);
                  },
                  child: Text("بعدی", style: TextStyle(fontFamily: 'Homa')),
                  color: Colors.white.withOpacity(0.01),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  pageChangeCallback(int lpage) {
    setState(() {
      page = lpage;
    });
  }

  setFirstEnter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('firstEnter', true);
  }
}
