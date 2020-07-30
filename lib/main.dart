import 'dart:ui';
import 'package:english_leitner_box/Word.dart';
import 'package:english_leitner_box/addOrEditWord.dart';
import 'package:english_leitner_box/homePage.dart';
import 'package:english_leitner_box/wordsPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bubbled_navigation_bar/bubbled_navigation_bar.dart';
import 'package:flutter/rendering.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'جعبه لایتنر', home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  final titles = ['خانه', 'کلمات', 'تنظیمات']; // bottom navigation bar titles
   // bottom navigation bar colors
  final colors = [
    Colors.blue[700],
    Colors.green[700],
    Colors.red[700],
  ];
   // bottom navigation bar icons
  final icons = [
    CupertinoIcons.home,
    Icons.library_books,
    Icons.settings,
    Icons.code
  ];

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  PageController _pageController;
  MenuPositionController _menuPositionController;
  bool userPageDragging = false;
  AnimationController rotationToPlusController, rotationToCancelController;
  Future words;

  @override
  void initState() {
    _menuPositionController = MenuPositionController(initPosition: 0);

    _pageController =
        PageController(initialPage: 0, keepPage: false, viewportFraction: 1.0);
    _pageController.addListener(handlePageChange);

    super.initState();

    rotationToPlusController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 200),
        upperBound: pi / 25);
    rotationToCancelController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 200),
        upperBound: pi / 25);

    words = WordDBHelper.instance.retrieveWords();
  }

  void handlePageChange() {
    _menuPositionController.absolutePosition = _pageController.page;
  }

  void checkUserDragging(ScrollNotification scrollNotification) {
    if (scrollNotification is UserScrollNotification &&
        scrollNotification.direction != ScrollDirection.idle) {
      userPageDragging = true;
    } else if (scrollNotification is ScrollEndNotification) {
      userPageDragging = false;
    }
    if (userPageDragging) {
      _menuPositionController.findNearestTarget(_pageController.page);
    }
  }

  @override
  Widget build(BuildContext context) {
    rotationToPlusController.forward(from: 0.0);
    HomePage homePage = HomePage();
    WordsPage wordsPage = WordsPage();
    List<Widget> pages = [ // pages
      homePage,
      wordsPage,
      Container(
        color: Colors.red[700],
        child: Center(child: Text('در نسخه های بعدی')),
      ),
    ];
    List<BubbledNavigationBarItem> pageItems = widget.titles.map((title) {
      var index = widget.titles.indexOf(title);
      var color = widget.colors[index];
      return BubbledNavigationBarItem(
        icon: getIcon(index, color),
        activeIcon: getIcon(index, Colors.white),
        bubbleColor: color,
        title: Text(
          title,
          style:
              TextStyle(color: Colors.white, fontSize: 12, fontFamily: "Vazir"),
        ),
      );
    }).toList();
    return Scaffold(
        body: NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            checkUserDragging(scrollNotification);
          },
          child: PageView(
            controller: _pageController,
            children: pages,
            onPageChanged: (page) {},
          ),
        ),
        bottomNavigationBar: BubbledNavigationBar(
          controller: _menuPositionController,
          itemMargin: EdgeInsets.symmetric(horizontal: 8),
          backgroundColor: Colors.white,
          defaultBubbleColor: Colors.blue[700],
          onTap: (index) {
            _pageController.animateToPage(index,
                curve: Curves.easeInOutQuad,
                duration: Duration(milliseconds: 500));
          },
          items: pageItems,
          initialIndex: 0,
        ));
  }

  Padding getIcon(int index, Color color) { // for bottom navigation bar
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Icon(widget.icons[index], size: 30, color: color),
    );
  }

  void addWord(BuildContext context) async { // go to add word page
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => AddOrEditWord()))
        .then((value) {
      setState(() {
        words = WordDBHelper.instance.retrieveWords();
      });
    });
  }
}
