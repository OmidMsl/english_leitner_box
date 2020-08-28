import 'dart:ui';
import 'package:commons/commons.dart';
import 'package:english_leitner_box/Category.dart';
import 'package:english_leitner_box/IntroSliderpage.dart';
import 'package:english_leitner_box/Card.dart' as litBox;
import 'package:english_leitner_box/addOrEditCard.dart';
import 'package:english_leitner_box/alert_dialogs.dart';
import 'package:english_leitner_box/homePage.dart';
import 'package:english_leitner_box/setttingsPage.dart';
import 'package:english_leitner_box/cardsPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bubbled_navigation_bar/bubbled_navigation_bar.dart';
import 'package:flutter/rendering.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getPrefrences(),
        builder: (context, snapshot) {
          return MaterialApp(
            title: 'لایتنر فارسی',
            home: (snapshot.hasData ? MyHomePage() : IntroSliderPage()),
            theme: ThemeData(primaryColor: Colors.white),
          );
        });
  }

  Future<bool> getPrefrences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('firstEnter');
  }
}

class MyHomePage extends StatefulWidget {
  final titles = ['خانه', 'کارت ها', 'تنظیمات']; // bottom navigation bar titles
  // bottom navigation bar colors
  final colors = [
    Color(0xff04cfe2),
    Color(0xff232863),
    Color(0xff760fd6),
  ];
  // bottom navigation bar icons
  final icons = [
    Icons.home,
    Icons.library_books,
    Icons.settings,
  ];

  List<Category> categories;
  int currentCategory = -2;

  @override
  _MyHomePageState createState() => _MyHomePageState();

  bool _editMode = false,
      _deleteMode = false,
      _copyMode = false,
      _moveMode = false,
      _selectMode = false;
  List<litBox.Card> _selecteds = List();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  // bottom navigation bar stuff
  PageController _pageController;
  MenuPositionController _menuPositionController;
  bool userPageDragging = false;
  bool actionsVisibility = false;
  int renameIndex = -1;
  bool newCategoryMode = false;

  // sidebar stuff
  bool isSidebarCollapsed = true;
  double screenWidth, screenHeight;
  final Duration duration = const Duration(milliseconds: 500);
  AnimationController _controller;

  AppBar appBar = AppBar();
  double borderRadius = 0.0;

  int _navBarIndex = 0;
  TabController tabController;

  @override
  void initState() {
    getCategories();
    if (widget.categories == null) {
      widget.categories = [];
      // initial category
      Category category = Category(name: 'بدون دسته بندی', id: -1);
      setState(() {
        widget.categories.add(category);
        widget.currentCategory = 0;
      });
    }
    _menuPositionController = MenuPositionController(initPosition: 0);

    _controller = AnimationController(vsync: this, duration: duration);

    _pageController =
        PageController(initialPage: 0, keepPage: false, viewportFraction: 1.0);
    _pageController.addListener(handlePageChange);

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      setState(() {
        _navBarIndex = tabController.index;
      });
    });
    super.dispose();
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
    Size size = MediaQuery.of(context).size;
    screenHeight = size.height;
    screenWidth = size.width;

    return WillPopScope(
      onWillPop: () async {
        if (!isSidebarCollapsed) {
          setState(() {
            _controller.reverse();
            borderRadius = 0.0;
            isSidebarCollapsed = !isSidebarCollapsed;
          });
          return false;
        } else
          return true;
      },
      child: Scaffold(
        backgroundColor: Color.fromRGBO(32, 33, 36, 1.0),
        body: Stack(
          children: <Widget>[
            Scaffold(
              backgroundColor: Colors.transparent,
              floatingActionButton: Padding(
                padding: EdgeInsets.only(left: 10),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Visibility(
                    visible: !widget._copyMode && !widget._moveMode,
                    // adding new category
                    child: FloatingActionButton.extended(
                      heroTag: 'categoryFAB',
                      onPressed: () {
                        Category category = Category(name: 'دسته بندی جدید');
                        setState(() {
                          widget.categories.add(category);
                          renameIndex = widget.categories.length - 1;
                          newCategoryMode = true;
                        });
                      },
                      label: Text(
                        'دسته جدید',
                        style: TextStyle(fontFamily: 'Homa'),
                      ),
                      icon: Icon(Icons.add),
                    ),
                  ),
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
            ),
            menu(context),
            // to manage sidebar collaosation
            AnimatedPositioned(
                left: isSidebarCollapsed ? 0 : 0.6 * screenWidth,
                right: isSidebarCollapsed ? 0 : -0.2 * screenWidth,
                top: isSidebarCollapsed ? 0 : screenHeight * 0.1,
                bottom: isSidebarCollapsed ? 0 : screenHeight * 0.1,
                duration: duration,
                curve: Curves.fastOutSlowIn,
                child: dashboard(context)),
          ],
        ),
      ),
    );
  }

  Widget menu(context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 32.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: 0.6,
            heightFactor: 0.8,
            child: ListView.builder(
                itemCount:
                    widget.categories == null ? 0 : widget.categories.length,
                itemBuilder: (context, index) {
                  TextEditingController catTextController =
                      TextEditingController();
                  catTextController.text = widget.categories[index].name;
                  return Padding(
                    padding: EdgeInsets.all(10.0),
                    child: renameIndex == index
                        ? Center(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  // for new category
                                  width: 150,
                                  child: TextField(
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelStyle:
                                            TextStyle(color: Colors.white),
                                        labelText: "نام جدید"),
                                    maxLines: 1,
                                    style: TextStyle(color: Colors.white),
                                    controller: catTextController,
                                  ),
                                ),
                                // done and cancel new category
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    IconButton(
                                        icon: Icon(
                                          Icons.done,
                                          color: Colors.green[700],
                                        ),
                                        onPressed: () {
                                          if (catTextController.text
                                              .trim()
                                              .isNotEmpty) {
                                            setState(() {
                                              widget.categories[index].name =
                                                  catTextController.text.trim();
                                              renameIndex = -1;
                                            });
                                            if (newCategoryMode)
                                              CategoryDBHelper.instance
                                                  .insertCategory(
                                                      widget.categories[index])
                                                  .then((value) {
                                                setState(() {
                                                  widget.categories[index].id =
                                                      value;
                                                });
                                              });
                                            else
                                              CategoryDBHelper.instance
                                                  .updateCategory(
                                                      widget.categories[index]);
                                          }
                                        }),
                                    IconButton(
                                        icon: Icon(
                                          Icons.clear,
                                          color: Colors.red[700],
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            if (newCategoryMode) {
                                              widget.categories.removeAt(
                                                  widget.categories.length - 1);
                                              newCategoryMode = false;
                                            }
                                            renameIndex = -1;
                                          });
                                        }),
                                  ],
                                )
                              ],
                            ),
                          )
                        : InkWell(
                            onTap: () {
                              if (widget._copyMode) {
                                for (litBox.Card c in widget._selecteds) {
                                  c.id = null;
                                  litBox.CardDBHelper.instance.insertCard(
                                      c, widget.categories[index].id);
                                  print('ooo: ' + c.front + ' copied.');
                                }
                                super.setState(() {
                                  widget._selecteds = [];
                                  widget._copyMode = false;
                                  widget._selectMode = false;
                                  isSidebarCollapsed = true;
                                });
                              } else if (widget._moveMode) {
                                for (litBox.Card c in widget._selecteds) {
                                  litBox.CardDBHelper.instance.insertCard(
                                      c, widget.categories[index].id);
                                  print('ooo: ' + c.front + ' moved.');
                                }
                                super.setState(() {
                                  widget._selecteds = [];
                                  widget._moveMode = false;
                                  widget._selectMode = false;
                                  isSidebarCollapsed = true;
                                });
                              }
                              super.setState(() {
                                widget.currentCategory = index;
                              });
                            },
                            onLongPress: () {
                              // options dialog for categories
                              var options = List<Option>()
                                ..add(Option.edit(
                                    title: Text('تغیر نام'),
                                    action: () {
                                      setState(() {
                                        renameIndex = index;
                                      });
                                    }))
                                ..add(Option.view(
                                    title: Text('انتخاب'),
                                    icon: Icon(Icons.done),
                                    action: () {
                                      setState(() {
                                        widget.currentCategory = index;
                                      });
                                    }))
                                ..add(Option.delete(
                                    title: Text('حذف'),
                                    action: () {
                                      CategoryDBHelper.instance.deleteCategory(
                                          widget.categories[index].id);
                                      setState(() {
                                        widget.currentCategory = 0;
                                        widget.categories.removeAt(index);
                                      });
                                    }));
                              optionsDialog(context, "Options", options);
                            },
                            child: Container(
                              color: index == widget.currentCategory
                                  ? Color(0x4400bfff)
                                  : Colors.transparent,
                              child: Text(
                                widget.categories[index].name,
                                style: TextStyle(
                                    fontFamily: 'Homa',
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                  );
                }),
          ),
        ),
      ),
    );
  }

  // getting categories from db
  void getCategories() {
    print('ooo: getting categories...');
    CategoryDBHelper.instance.retrieveCategories().then((value) {
      setState(() {
        widget.categories = value;
        if (value != null) widget.currentCategory = 0;
        print('ooo: categories received.');
      });
      if (value == null || value.isEmpty) {
        Category category = Category(name: 'بدون دسته بندی', id: -1);
        CategoryDBHelper.instance.insertCategory(category).then((value) {
          setState(() {
            if (widget.categories == null || widget.categories.isEmpty) {
              widget.categories = [];
              widget.categories.add(category);
            }
          });
        });
      }
    });
  }

  refreshCategories() {
    CategoryDBHelper.instance.retrieveCategories().then((value) {
      setState(() {
        widget.categories = value;
      });
    });
  }

  editAppbar(bool _dm, bool _em, bool _sm, List<litBox.Card> _ss, bool _cm,
      bool _mm, bool _isc) {
    setState(() {
      widget._deleteMode = _dm;
      widget._editMode = _em;
      widget._selectMode = _sm;
      widget._selecteds = _ss;
      widget._copyMode = _cm;
      widget._moveMode = _mm;
    });
    if (isSidebarCollapsed != _isc) {
      setState(() {
        if (isSidebarCollapsed) {
          _controller.forward();

          borderRadius = 16.0;
        } else {
          _controller.reverse();

          borderRadius = 0.0;
        }

        isSidebarCollapsed = !isSidebarCollapsed;
      });
    }
  }

  Widget dashboard(context) {
    if (widget.currentCategory == -2)
      return null;
    else {
      HomePage homePage = HomePage(
          widget.categories.isEmpty
              ? null
              : widget.categories[widget.currentCategory],
          refreshCategories);
      CardsPage cardsPage = CardsPage(
        widget.categories.isEmpty
            ? -1
            : widget.categories[widget.currentCategory].id,
        editAppbar: editAppbar,
        deleteMode: widget._deleteMode,
        editMode: widget._editMode,
        selectMode: widget._selectMode,
        selecteds: widget._selecteds,
        copyMode: widget._copyMode,
        moveMode: widget._moveMode,
        isSidebarCollapsed: isSidebarCollapsed,
      );
      SettingsPage settingsPage =
          SettingsPage(widget.categories[widget.currentCategory]);
      List<Widget> pages = [
        // pages
        homePage,
        cardsPage,
        settingsPage
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
            style: TextStyle(
                color: Colors.white, fontSize: 12, fontFamily: "Homa"),
          ),
        );
      }).toList();
      return SafeArea(
        child: Material(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          type: MaterialType.card,
          animationDuration: duration,
          color: Theme.of(context).scaffoldBackgroundColor,
          elevation: 8,
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  widget.categories == null || widget.categories.isEmpty
                      ? 'لایتنر فارسی'
                      : widget.categories[widget.currentCategory].name,
                  style: TextStyle(
                      color: Colors.black54,
                      fontFamily: 'Homa',
                      fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                leading: IconButton(
                    icon: AnimatedIcon(
                      icon: AnimatedIcons.menu_close,
                      progress: _controller,
                    ),
                    onPressed: () {
                      setState(() {
                        if (widget._copyMode) {
                          widget._copyMode = false;
                          widget._selectMode = false;
                          widget._selecteds = [];
                        } else if (widget._moveMode) {
                          widget._moveMode = false;
                          widget._selectMode = false;
                          widget._selecteds = [];
                        }
                        if (isSidebarCollapsed) {
                          _controller.forward();

                          borderRadius = 16.0;
                        } else {
                          _controller.reverse();

                          borderRadius = 0.0;
                        }

                        isSidebarCollapsed = !isSidebarCollapsed;
                      });
                    }),
                actions: <Widget>[
                  Visibility(
                    visible: actionsVisibility &&
                        !widget._editMode &&
                        !widget._copyMode &&
                        !widget._moveMode,
                    child: IconButton(
                      icon: Icon(
                        widget._deleteMode
                            ? Icons.delete_forever
                            : Icons.delete,
                        color:
                            widget._deleteMode ? Colors.blue : Colors.black54,
                      ),
                      onPressed: () {
                        setState(() {
                          if (widget._deleteMode) {
                            widget._deleteMode = false;
                            widget._selecteds = [];
                          } else if (widget._selectMode) {
                            _showDeleteDialog();
                          } else {
                            widget._deleteMode = true;
                          }
                        });
                      },
                    ),
                  ),
                  Visibility(
                    visible: actionsVisibility &&
                        widget._selecteds.length < 2 &&
                        !widget._deleteMode &&
                        !widget._copyMode &&
                        !widget._moveMode,
                    child: IconButton(
                        icon: Icon(
                          Icons.edit,
                          color:
                              widget._editMode ? Colors.blue : Colors.black54,
                        ),
                        onPressed: () {
                          setState(() {
                            if (widget._selectMode) {
                              _navigateToDetail(context, widget._selecteds[0]);
                              widget._selectMode = false;
                              widget._selecteds = [];
                            } else if (widget._editMode) {
                              widget._editMode = false;
                              widget._selecteds = [];
                            } else {
                              widget._editMode = true;
                            }
                          });
                        }),
                  ),
                  Visibility(
                    // overflow menu
                    visible: actionsVisibility &&
                        !widget._deleteMode &&
                        !widget._editMode,
                    child: PopupMenuButton<String>(
                      onSelected: (String value) {
                        switch (value) {
                          case 'کپی':
                            setState(() {
                              if (widget._copyMode) {
                                widget._copyMode = false;
                                widget._selecteds = [];
                              } else if (widget._selectMode) {
                                widget._copyMode = true;
                                widget._selectMode = false;
                                if (widget._selecteds.isNotEmpty) {
                                  isSidebarCollapsed = false;
                                }
                              } else {
                                widget._copyMode = true;
                              }
                            });
                            break;
                          case 'انتقال':
                            setState(() {
                              if (widget._moveMode) {
                                widget._moveMode = false;
                                widget._selecteds = [];
                              } else if (widget._selectMode) {
                                widget._moveMode = true;
                                widget._selectMode = false;
                                if (widget._selecteds.isNotEmpty) {
                                  isSidebarCollapsed = false;
                                }
                              } else {
                                widget._moveMode = true;
                              }
                            });
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return {'کپی', 'انتقال'}.map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ],
              ),
              body: Scaffold(
                  body: NotificationListener<ScrollNotification>(
                    onNotification: (scrollNotification) {
                      checkUserDragging(scrollNotification);
                    },
                    child: PageView(
                      controller: _pageController,
                      children: pages,
                      onPageChanged: (page) {
                        setState(() {
                          actionsVisibility = page == 1;
                        });
                      },
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
                  )),
            ),
          ),
        ),
      );
    }
  }

  _showDeleteDialog() {
    deleteDialog(
        context,
        (widget._selecteds.length == 1
            ? (isEnglish(widget._selecteds[0].front)
                ? 'را حذف می کنید؟ ' + widget._selecteds[0].front
                : widget._selecteds[0].front + 'را حذف می کنید؟ ')
            : CardsPage.replaceWithArabicNumbers(
                widget._selecteds.length.toString() +
                    ' آیتم را حذف می کنید؟ ')), positiveAction: () {
      setState(() {
        for (litBox.Card c in widget._selecteds) {
          _deleteCard(c);
        }
        widget._deleteMode = false;
        widget._selectMode = false;
        widget._selecteds = [];
      });
    }, neutralAction: () {
      // cancel
      setState(() {
        widget._deleteMode = false;
        widget._selectMode = false;
        widget._selecteds = [];
      });
    });
  }

  // is all words of this string enghish charracters
  bool isEnglish(String s) {
    int n = s.codeUnitAt(0);
    if (n > 23 && n < 127) {
      return true;
    }
    return false;
  }

  // edit card
  _navigateToDetail(BuildContext context, litBox.Card card) async {
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => AddOrEditCard(
                  widget.categories[widget.currentCategory].id,
                  card: card,
                )))
        .then((value) {
      setState(() {});
    });
  }

  _deleteCard(litBox.Card card) {
    litBox.CardDBHelper.instance
        .deleteCard(card.id, widget.categories[widget.currentCategory].id);
    setState(() {});
  }

  Padding getIcon(int index, Color color) {
    // for bottom navigation bar
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Icon(widget.icons[index], size: 30, color: color),
    );
  }

  void addCard(BuildContext context) async {
    // go to add card page
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) =>
                AddOrEditCard(widget.categories[widget.currentCategory].id)))
        .then((value) {});
  }
}
