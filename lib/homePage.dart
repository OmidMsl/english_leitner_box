import 'dart:convert';

import 'package:english_leitner_box/Word.dart';
import 'package:english_leitner_box/addOrEditWord.dart';
import 'package:english_leitner_box/conactUs.dart';
import 'package:english_leitner_box/reviewPage.dart';
import 'package:english_leitner_box/wordsPage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'dart:io';

//home page
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BuildContext scaffoldContext;
  String lastReview = '';
  int absentDays = -1;
  List<Word> forReview;
  Future words;
  ScrollController _scrollController;
  bool _fabExtend = true, upDirection = true, flag = true;
  String _path;

  @override
  void initState() {
    // TODO: implement initState

    // getting the words from databse
    words = WordDBHelper.instance.retrieveWords();

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
    scaffoldContext = context;
    return FutureBuilder<List<Word>>(
        future: words,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data.isNotEmpty) {
            // if there is eny words
            List<Word> allWords = snapshot.data;
            DateTime lastR =
                allWords[0].lastReview; // for finding lastest review
            if (lastR == null) {
              lastR = DateTime.fromMillisecondsSinceEpoch(0);
            }
            // 00:00 of today
            DateTime d = DateTime.now();
            d = DateTime.fromMillisecondsSinceEpoch(
                d.millisecondsSinceEpoch -
                    (d.millisecondsSinceEpoch % 86400000),
                isUtc: true);

            // these words need to be reviewed
            forReview = List();
            for (Word word in allWords) {
              if (word.lastReview != null && word.lastReview.isAfter(lastR)) {
                lastR = word.lastReview;
              }
              if (word.lastReview == null ||
                  word.lastReview.isBefore(d) ||
                  !word.isLastReviewSuessful) {
                forReview.add(word);
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
                : WordsPage.replaceWithArabicNumbers(j.day.toString()) +
                    ' ' +
                    monthes[j.month - 1] +
                    ' ' +
                    WordsPage.replaceWithArabicNumbers(j.year.toString()) +
                    ' ساعت ' +
                    WordsPage.replaceWithArabicNumbers(lastR.hour.toString()) +
                    ':' +
                    WordsPage.replaceWithArabicNumbers(lastR.minute.toString());
            return Scaffold(
              backgroundColor: Colors.blue[700],
              appBar: AppBar(
                title: Text('جعبه لایتنر',
                    style:
                        TextStyle(color: Colors.black54, fontFamily: "Vazir")),
                centerTitle: true,
                backgroundColor: Colors.white,
              ),
              body: Padding(
                padding: const EdgeInsets.only(
                    left: 8.0, top: 4.0, right: 8.0, bottom: 4.0),
                child: GridView.count(
                  controller: _scrollController,
                  crossAxisCount: 2,
                  children: <Widget>[
                    Card(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(': آخرین مرور',
                                style: TextStyle(fontFamily: 'Vazir')),
                            Text(lastReview,
                                style: TextStyle(
                                    fontFamily: 'Vazir',
                                    color: absentDays == 0
                                        ? Colors.green[900]
                                        : absentDays < 3
                                            ? Colors.amber[700]
                                            : Colors.red)),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: RaisedButton(
                                  child: Text(
                                    'مرور همه کلمات',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Vazir'),
                                  ),
                                  color: Colors.deepPurple,
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) => ReviewPage(
                                                  words: allWords,
                                                  isAll: true,
                                                )))
                                        .then((value) {
                                      setState(() {
                                        words = WordDBHelper.instance
                                            .retrieveWords();
                                      });
                                    });
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(': کلمات مرور نشده',
                                style: TextStyle(fontFamily: 'Vazir')),
                            Text(
                                WordsPage.replaceWithArabicNumbers(
                                    forReview.length.toString()),
                                style: TextStyle(
                                    fontFamily: 'Vazir',
                                    color: forReview.length == 0
                                        ? Colors.green[900]
                                        : forReview.length <= 20
                                            ? Colors.amber[700]
                                            : Colors.red)),
                            Visibility(
                              visible: forReview.isNotEmpty,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: RaisedButton(
                                    child: Text(
                                      'مرور کلمات مرور نشده',
                                      style: TextStyle(fontFamily: 'Vazir'),
                                    ),
                                    color: Color(0xff24ff71),
                                    onPressed: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) => ReviewPage(
                                                    words: forReview,
                                                    isAll: false,
                                                  )))
                                          .then((value) {
                                        setState(() {
                                          words = WordDBHelper.instance
                                              .retrieveWords();
                                        });
                                      });
                                    }),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Card(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(': تعداد کل کلمات',
                                style: TextStyle(fontFamily: 'Vazir')),
                            Text(
                                WordsPage.replaceWithArabicNumbers(
                                    allWords.length.toString()),
                                style: TextStyle(fontFamily: 'Vazir'))
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => saveToFile(),
                      child: Card(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('گرفتن پشتیبان از کلمات',
                                  style: TextStyle(fontFamily: 'Vazir')),
                            ],
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => getWordsFromFile(),
                      child: Card(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'وارد کردن کلمات از فایل پشتیبان',
                                style: TextStyle(fontFamily: 'Vazir'),
                                textAlign:
                                    TextAlign.center, // manage text overflow
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      child: Card(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('تماس با ما',
                                  style: TextStyle(fontFamily: 'Vazir')),
                            ],
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ContactUs()));
                      },
                    ),
                  ],
                ),
              ),
              floatingActionButton: AnimatedContainer(
                  duration: Duration(),
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      addWord(context);
                    },
                    backgroundColor: Color(0xff00003f),
                    isExtended: _fabExtend,
                    label: _fabExtend
                        ? Text('کلمه جدید',
                            style: TextStyle(fontFamily: "Vazir"))
                        : Icon(Icons.add),
                    icon: _fabExtend ? Icon(Icons.add) : null,
                  )),
            );
          } else {
            // if there is no word
            return Container(
              color: Colors.blue[700],
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
                        '! هیچ کلمه ای ندارید',
                        style: TextStyle(fontFamily: 'Vazir'),
                      ),
                      RaisedButton.icon(
                          onPressed: () {
                            addWord(context);
                          },
                          icon: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          color: Colors.blue[900],
                          label: Text(
                            'افزودن کلمه جدید',
                            style: TextStyle(
                                color: Colors.white, fontFamily: 'Vazir'),
                          )),
                      RaisedButton.icon(
                          onPressed: () {
                            getWordsFromFile();
                          },
                          icon: Icon(
                            Icons.insert_drive_file,
                            color: Colors.white,
                          ),
                          color: Colors.red[800],
                          label: Text(
                            'افزودن کلمه از فایل',
                            style: TextStyle(
                                color: Colors.white, fontFamily: 'Vazir'),
                          ))
                    ],
                  ),
                ),
              )),
            );
          }
        });
  }

  void addWord(BuildContext context) async {
    // go to add word page
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => AddOrEditWord()))
        .then((value) {
      setState(() {
        words = WordDBHelper.instance.retrieveWords();
      });
    });
  }

  void getWordsFromFile() async {
    if (await Permission.storage.isGranted) {
      try {
        _path = await _importPath;
        if (_path != null) {
          File file = File(_path);
          String jsonStr = await file.readAsString();

          final parsed = jsonDecode(jsonStr).cast<Map<String, dynamic>>();

          List<Word> newWords =
              parsed.map<Word>((json) => Word.fromJson(json)).toList();

          int numOfNews = 0;
          for (Word w in newWords) {
            Future f = WordDBHelper.instance.isUnique(-1, w.word);
            bool unique = true;
            await f.then((value) {
              unique = (value.toString() == '[]');
            });
            if (unique) {
              await WordDBHelper.instance.insertWord(w);
              numOfNews++;
            }
          }
          createSnackBar(numOfNews == 0
              ? 'کلمه جدیدی اضافه نشد.'
              : numOfNews.toString() + 'کلمه جدید اضافه شد ');
          setState(() {
            words = WordDBHelper.instance.retrieveWords();
          });
        }
      } catch (e) {
        createSnackBar('خطا: \n' + e.toString());
      }
    } else {
      await Permission.storage.request();
    }
  }

  void saveToFile() async {
    if (await Permission.storage.isGranted) {
      try {
        String path = await _exportPath;
        if (path != null) {
          String folderName = path.substring(path.lastIndexOf('/') + 1);
          path = await path + '/Leitner_box_words';
          bool isExists = true;

          int i = 0;
          for (; isExists; i++) {
            _path = path + (i == 0 ? '' : i.toString()) + '.json';
            isExists = await _isNameValid;
          }

          final file = File(_path);

          String jsonStr;
          words.then((value3) {
            jsonStr =
                jsonEncode(value3, toEncodable: (e) => (e as Word).toMap());
            file.writeAsString(jsonStr);
            createSnackBar(' فایل پشتیبان با نام' +
                ' Leitner_box_words' +
                (i == 0 ? '' : i.toString()) +
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
