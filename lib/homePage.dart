import 'dart:convert';

import 'package:english_leitner_box/Category.dart';
import 'package:english_leitner_box/Card.dart' as litBox;
import 'package:english_leitner_box/addOrEditCard.dart';
import 'package:english_leitner_box/alert_dialogs.dart';
import 'package:english_leitner_box/conactUs.dart';
import 'package:english_leitner_box/reviewPage.dart';
import 'package:english_leitner_box/cardsPage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'dart:io';

//home page
class HomePage extends StatefulWidget {
  final Category category;
  Function() refreshCategories;
  HomePage(this.category, this.refreshCategories);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BuildContext scaffoldContext;
  String lastReview = '';
  int absentDays = -1;
  int numOfNotReviewed = 0;
  Future cards;
  ScrollController _scrollController;
  bool _fabExtend = true, upDirection = true, flag = true;
  String _path;

  @override
  void initState() {
    // TODO: implement initState

    // to extend floating action button after scrolling down
    _scrollController = ScrollController()
      ..addListener(() {
        upDirection = _scrollController.position.userScrollDirection ==
            ScrollDirection.forward;

        // makes sure we don't call setState too much, but only when it is needed
        if (upDirection != flag)
          setState(() {
            _fabExtend = !_fabExtend;
          });

        flag = upDirection;
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // getting the cards from databse
    cards = litBox.CardDBHelper.instance.retrieveCards(widget.category.id);
    Size size = MediaQuery.of(context).size;
    scaffoldContext = context;
    return FutureBuilder<List<litBox.Card>>(
        future: cards,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data.isNotEmpty) {
            // if there is eny cards
            List<litBox.Card> allCards = snapshot.data;
            DateTime lastR =
                allCards[0].lastReview; // for finding lastest review
            if (lastR == null) {
              lastR = DateTime.fromMillisecondsSinceEpoch(0);
            }
            // 00:00 of today
            DateTime d = DateTime.now();
            d = DateTime.fromMillisecondsSinceEpoch(
                d.millisecondsSinceEpoch -
                    (d.millisecondsSinceEpoch % 86400000),
                isUtc: true);

            numOfNotReviewed = 0;
            for (litBox.Card card in allCards) {
              // calculate date and time of last review
              if (card.lastReview != null && card.lastReview.isAfter(lastR)) {
                lastR = card.lastReview;
              }
              // calculate today words
              if (card.lastReview == null || card.lastReview.isBefore(d)) {
                if (card.boxLocation == 0 ||
                    card.boxLocation == 2 ||
                    card.boxLocation == 6 ||
                    card.boxLocation == 14 ||
                    card.boxLocation == 30) numOfNotReviewed++;
              }
            }
            absentDays = d.difference(lastR).inDays;
            // convert georgian date to shamsi date
            Jalali j = Jalali.fromDateTime(lastR);
            List<String> monthes = [
              'فروردین',
              'اردیبهشت',
              'خرداد',
              'تیر',
              'مرداد',
              'شهریور',
              'مهر',
              'آبان',
              'آذر',
              'دی',
              'بهمن',
              'اسفند'
            ];

            lastReview = lastR.millisecondsSinceEpoch == 0
                ? 'هیچ وقت'
                : CardsPage.replaceWithArabicNumbers(j.day.toString()) +
                    ' ' +
                    monthes[j.month - 1] +
                    ' ' +
                    CardsPage.replaceWithArabicNumbers(j.year.toString()) +
                    '\n'
                        ' ساعت ' +
                    CardsPage.replaceWithArabicNumbers(lastR.hour.toString()) +
                    ':' +
                    CardsPage.replaceWithArabicNumbers(lastR.minute < 10
                        ? '0' + lastR.minute.toString()
                        : lastR.minute.toString());
            return Container(
              // gradient for background of page
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                    Color(0xff04cfe2),
                    Color(0xff0f9dd6),
                    Color(0xff041554)
                  ])),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: SingleChildScrollView(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        // left buttons
                        children: [
                          // tomarrow review button
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 4.0),
                            child: InkWell(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                      numOfNotReviewed == 0
                                          ? 'images/tomorrow_cards.png'
                                          : 'images/tomorrow_cards_gray.png',
                                      width: (size.width / 2) - 16),
                                  Padding(
                                      padding: const EdgeInsets.only(
                                          left: 64.0, top: 32.0),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(': آخرین مرور',
                                                style: TextStyle(
                                                    fontFamily: 'Homa')),
                                            Text(lastReview,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontFamily: 'Homa',
                                                    color: absentDays == 0
                                                        ? Colors.green[900]
                                                        : absentDays < 3
                                                            ? Colors.amber[700]
                                                            : Colors.red,
                                                    fontSize: 12)),
                                          ]))
                                ],
                              ),
                              onTap: () {
                                if (numOfNotReviewed == 0) {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) => ReviewPage(
                                                widget.category,
                                                cards: allCards,
                                                isAll: false,
                                              )))
                                      .then((value) {
                                    setState(() {
                                      cards = litBox.CardDBHelper.instance
                                          .retrieveCards(widget.category.id);
                                    });
                                  });
                                }
                              },
                            ),
                          ),
                          // review all cards button
                          Padding(
                              padding:
                                  const EdgeInsets.only(top: 4.0, bottom: 4.0),
                              child: InkWell(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.asset('images/review_all.png',
                                        width: (size.width / 2) - 16),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 82.0, top: 48.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(': کل کلمات',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontFamily: 'Homa')),
                                          Text(
                                              CardsPage
                                                  .replaceWithArabicNumbers(
                                                      allCards.length
                                                          .toString()),
                                              style:
                                                  TextStyle(fontFamily: 'Homa'))
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => ReviewPage(
                                            widget.category,
                                            cards: allCards,
                                            isAll: true,
                                          )));
                                },
                              )),
                          // get cards from file button
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 4.0, bottom: 8.0),
                            child: InkWell(
                              child: Image.asset(
                                  'images/get_words_from_file.png',
                                  width: (size.width / 2) - 16),
                              onTap: () => getCardsFromFile(),
                            ),
                          )
                        ],
                      ),
                      // right side cards
                      Column(
                        children: [
                          // review today cards
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 4.0),
                            child: InkWell(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                      numOfNotReviewed == 0
                                          ? 'images/new_cards_gray.png'
                                          : 'images/new_cards.png',
                                      width: (size.width / 2) - 16),
                                  Padding(
                                      padding: const EdgeInsets.only(
                                          right: 48.0, top: 32.0),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(': کارت های مرور نشده',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontFamily: 'Homa')),
                                            Text(
                                                CardsPage
                                                    .replaceWithArabicNumbers(
                                                        numOfNotReviewed
                                                            .toString()),
                                                style: TextStyle(
                                                    fontFamily: 'Homa',
                                                    color: numOfNotReviewed == 0
                                                        ? Colors.green[900]
                                                        : numOfNotReviewed <= 20
                                                            ? Colors.amber[700]
                                                            : Colors.red)),
                                          ])),
                                ],
                              ),
                              onTap: () {
                                if (numOfNotReviewed != 0) {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) => ReviewPage(
                                                widget.category,
                                                cards: allCards,
                                                isAll: false,
                                              )))
                                      .then((value) {
                                    setState(() {
                                      cards = litBox.CardDBHelper.instance
                                          .retrieveCards(widget.category.id);
                                    });
                                  });
                                }
                              },
                            ),
                          ),
                          // save cards to file button
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 4.0, bottom: 4.0),
                            child: InkWell(
                              child: Image.asset(
                                  'images/save_words_to_file.png',
                                  width: (size.width / 2) - 16),
                              onTap: () => saveToFile(),
                            ),
                          ),
                          // contact us button
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 4.0, bottom: 8.0),
                            child: InkWell(
                              child: Image.asset('images/contact_us.png',
                                  width: (size.width / 2) - 16),
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ContactUs()));
                              },
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                // fab
                floatingActionButton: AnimatedContainer(
                    duration: Duration(),
                    child: FloatingActionButton.extended(
                      heroTag: 'homeFAB',
                      onPressed: () {
                        addCard(context);
                      },
                      backgroundColor: Colors.pink,
                      isExtended: _fabExtend,
                      label: _fabExtend
                          ? Text('کارت جدید',
                              style: TextStyle(fontFamily: "Homa"))
                          : Icon(Icons.add),
                      icon: _fabExtend ? Icon(Icons.add) : null,
                    )),
              ),
            );
          } else {
            // if there is no card
            // showing no card dialog
            return Container(
              // gradient for background of the page
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                    Color(0xff04cfe2),
                    Color(0xff0f9dd6),
                    Color(0xff041554)
                  ])),
              child: Center(
                  child: Card(
                color: Colors.white70,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '! هیچ کارتی ندارید',
                        style: TextStyle(fontFamily: 'Homa'),
                      ),
                      RaisedButton.icon(
                          onPressed: () {
                            addCard(context);
                          },
                          icon: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          color: Colors.blue[900],
                          label: Text(
                            'افزودن کارت جدید',
                            style: TextStyle(
                                color: Colors.white, fontFamily: 'Homa'),
                          )),
                      RaisedButton.icon(
                          onPressed: () {
                            getCardsFromFile();
                          },
                          icon: Icon(
                            Icons.insert_drive_file,
                            color: Colors.white,
                          ),
                          color: Colors.red[800],
                          label: Text(
                            'افزودن کارت از فایل',
                            style: TextStyle(
                                color: Colors.white, fontFamily: 'Homa'),
                          ))
                    ],
                  ),
                ),
              )),
            );
          }
        });
  }

  void addCard(BuildContext context) async {
    // go to add card page
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => AddOrEditCard(widget.category.id)))
        .then((value) {
      setState(() {
        cards = litBox.CardDBHelper.instance.retrieveCards(widget.category.id);
      });
    });
  }

  void getCardsFromFile() async {
    if (await Permission.storage.isGranted) {
      try {
        _path = await _importPath;
        if (_path != null) {
          File file = File(_path);
          String jsonStr = await file.readAsString();

          // seperating categoryies and cards
          List<String> str = jsonStr.split('{/\cardsList/\}');

          // convert json of categories to list of Categories
          List<Category> newCategories = jsonDecode(str[0])
              .cast<Map<String, dynamic>>()
              .map<Category>((json) => Category.fromJson(json))
              .toList();

          // to fix a problem in json
          str[1] = str[1].replaceAll('][', ',');
          print(str[1]);
          // convert json of cards to list of Cards
          List<litBox.Card> allNewCards = jsonDecode(str[1])
              .cast<Map<String, dynamic>>()
              .map<litBox.Card>((json) => litBox.Card.fromJson(json))
              .toList();

          // combining new categories with current categories
          await CategoryDBHelper.instance
              .retrieveCategories()
              .then((categories) {
            for (Category c1 in newCategories) {
              int catId = -2;
              for (Category c2 in categories) {
                print('c1: ' + c1.name + '\nc2: ' + c2.name);
                if (c1.name.trim() == c2.name.trim()) {
                  catId = c2.id;
                  break;
                }
              }
              // if the name of category is the same as one of current categories
              if (catId != -2) {
                TextEditingController getNameController =
                    TextEditingController();
                sameNameDialog(
                    context,
                    'نام دسته بندی موجود در فایل با نام دسته بندی شما یکسان است. دسته بندی ها را با هم ادغام میکنید یا اینکه نام آن را تغیر میدهید؟' +
                        '\n(با ادغام کردن، کارت ها نیز ادغام میشوند)',
                    title: 'نام دسته بندی ' + c1.name + ' تکراری است.',
                    negativeAction: () {
                      // override
                      for (litBox.Card w in allNewCards) {
                        if (c1.id == w.id) {
                          w.id = null;
                          w.boxLocation = 0;
                          w.lastReview = null;
                          litBox.CardDBHelper.instance
                              .isUnique(-1, w.front, catId)
                              .then((value) {
                            if (value.toString() == '[]') {
                              litBox.CardDBHelper.instance.insertCard(w, catId);
                            }
                          });
                        }
                      }
                    },
                    // cancel
                    neutralAction: () {},
                    inputTextController: getNameController,
                    validReason: isCatNameUnique(getNameController == null
                        ? ''
                        : getNameController.text.trim()),

                    // rename new category
                    positiveAction: () {
                      c1.name = getNameController == null
                          ? ''
                          : getNameController.text.trim();

                      int c1id = c1.id;
                      c1.id = null;
                      CategoryDBHelper.instance.insertCategory(c1).then((c2id) {
                        print('ooo: c2id = ' + c2id.toString());
                        for (litBox.Card c in allNewCards) {
                          if (c1id == c.id) {
                            c.id = null;
                            c.boxLocation = 0;
                            c.lastReview = null;
                            litBox.CardDBHelper.instance.insertCard(c, c2id);
                          }
                        }
                      });
                    });
                // name of this category is not duplicate
              } else {
                print('ooo: c2id = -2 called.');
                int c1id = c1.id;
                c1.id = null;
                CategoryDBHelper.instance.insertCategory(c1).then((c2id) {
                  for (litBox.Card w in allNewCards) {
                    if (c1id == w.id) {
                      w.id = null;
                      w.boxLocation = 0;
                      w.lastReview = null;
                      litBox.CardDBHelper.instance.insertCard(w, c2id);
                    }
                  }
                });
              }
            }
          });
          widget.refreshCategories();
        }
      } catch (e) {
        print(e.toString());
        createSnackBar('خطا: \n' + e.toString());
      }
    } else {
      // request for storage permission
      await Permission.storage.request();
    }
  }

  // is name of category unique
  bool isCatNameUnique(String name) {
    Future f = CategoryDBHelper.instance.isUnique(-1, name);
    bool unique = true;
    f.then((value) {
      unique = (value.toString() == '[]');
    });
    return unique;
  }

  void saveToFile() async {
    if (await Permission.storage.isGranted) {
      try {
        String path = await _exportPath;
        if (path != null) {
          String folderName = path.substring(path.lastIndexOf('/') + 1);
          path = await path + '/Leitner_box_cards';
          bool isExists = true;

          int i = 0;
          for (; isExists; i++) {
            _path = path + (i == 0 ? '' : i.toString()) + '.json';
            isExists = await _isNameValid;
          }

          final file = File(_path);

          String jsonStr;
          List<Category> categories;
          CategoryDBHelper.instance.retrieveCategories().then((value) {
            categories = value;
            jsonStr = jsonEncode(categories,
                toEncodable: (e) => (e as Category).toMap());
            jsonStr += '{/\cardsList/\}';
            print(jsonStr);
            for (Category category in categories) {
              litBox.CardDBHelper.instance
                  .retrieveCards(category.id)
                  .then((value3) {
                jsonStr += jsonEncode(value3,
                    toEncodable: (e) => (e as litBox.Card).toMap(category.id));
                file.writeAsString(jsonStr);
              });
            }
            createSnackBar(' فایل پشتیبان با نام' +
                ' Leitner_box_cards' +
                (i == 1 ? '' : (i - 1).toString()) +
                ' در پوشه ' +
                folderName +
                ' ذخیره شد. ');
          });
        }
      } catch (e) {
        createSnackBar('خطا: \n' + e.toString());
      }
    } else {
      await Permission.storage.request();
    }
  }

  Future<String> get _exportPath {
    return FilePicker.getDirectoryPath();
  }

  Future<String> get _importPath {
    return FilePicker.getFilePath(
        type: FileType.custom, allowedExtensions: ['json']);
  }

  Future<bool> get _isNameValid {
    return FileSystemEntity.isFile(_path);
  }

  void createSnackBar(String message) {
    final snackBar = new SnackBar(
        content: new Text(
      message,
      textDirection: TextDirection.rtl,
    ));
    // Find the Scaffold in the Widget tree and use it to show a SnackBar!
    Scaffold.of(scaffoldContext).showSnackBar(snackBar);
  }
}
