import 'package:english_leitner_box/Word.dart';
import 'package:english_leitner_box/addOrEditWord.dart';
import 'package:english_leitner_box/conactUs.dart';
import 'package:english_leitner_box/reviewPage.dart';
import 'package:english_leitner_box/wordsPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shamsi_date/shamsi_date.dart';

//home page
class HomePage extends StatefulWidget {
  BuildContext buildContext;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String lastReview = '';
  int absentDays = -1;
  List<Word> forReview;
  Future words;
  ScrollController _scrollController;
  bool _fabExtend = true,
      upDirection = true,
      flag = true;

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
    widget.buildContext = context;

    return FutureBuilder<List<Word>>(
        future: words,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data.isNotEmpty) { // if there is eny words
            List<Word> allWords = snapshot.data;
            DateTime lastR = allWords[0].lastReview; // for finding lastest review
            if (lastR == null) {
              lastR = DateTime.fromMillisecondsSinceEpoch(0);
            }
            // 00:00 of today
            DateTime d = DateTime.now();
            d = DateTime.fromMillisecondsSinceEpoch(d.millisecondsSinceEpoch -
                (d.millisecondsSinceEpoch % 86400000));

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
            absentDays =
                ((d.millisecondsSinceEpoch - lastR.millisecondsSinceEpoch) /
                        86400000)
                    .round();
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
                    Card(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('گرفتن پشتیبان از کلمات',
                                style: TextStyle(fontFamily: 'Vazir')),
                            Text('(در نسخه های آینده)',
                                style: TextStyle(fontFamily: 'Vazir'))
                          ],
                        ),
                      ),
                    ),
                    Card(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'وارد کردن کلمات از فایل پشتیبان',
                              style: TextStyle(fontFamily: 'Vazir'),
                              textAlign: TextAlign.center,// manage text overflow
                            ),
                            Text('(در نسخه های آینده)',
                                style: TextStyle(fontFamily: 'Vazir'))
                          ],
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
          } else { // if there is no word
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

  void addWord(BuildContext context) async { // go to add word page
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => AddOrEditWord()))
        .then((value) {
      setState(() {
        words = WordDBHelper.instance.retrieveWords();
      });
    });
  }

  void getWordsFromFile() {} // for next updates
}
