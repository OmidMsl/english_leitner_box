import 'dart:math';

import 'package:english_leitner_box/Card.dart' as litBox;
import 'package:english_leitner_box/Category.dart' as litBox;
import 'package:english_leitner_box/addOrEditCard.dart';
import 'package:english_leitner_box/cardsPage.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:quiver/async.dart';

class ReviewPage extends StatefulWidget {
  final List<litBox.Card> cards;
  final bool isAll;
  final litBox.Category category;

  ReviewPage(this.category, {this.cards, this.isAll});

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

enum TtsState { playing, stopped, paused, continued }

class _ReviewPageState extends State<ReviewPage> with TickerProviderStateMixin {
  litBox.Card card;
  int selectedPart = -1, resPart = -1, numOfNotReviewed = 0, nw = 0;
  bool _questionMode = true;
  List<List<litBox.Card>> box = List(32);
  List<litBox.Card> wrongAnswer = [];
  Random random = Random();
  bool answer = true;
  StreamSubscription<CountdownTimer> sub;

  TextEditingController _inputController = TextEditingController();

  AnimationController _controller;

  String get timeRemaining {
    Duration duration = _controller.duration * _controller.value;
    return '${duration.inMinutes} ${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  // pronunciation stuff
  FlutterTts flutterTts;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;

  get isPaused => ttsState == TtsState.paused;

  get isContinued => ttsState == TtsState.continued;

  @override
  initState() {
    // preparing box
    for (int i = 0; i < 32; i++) {
      box[i] = [];
    }
    for (litBox.Card c in widget.cards) {
      box[c.boxLocation].add(c);
    }
    numOfNotReviewed = box[0].length +
        box[2].length +
        box[6].length +
        box[14].length +
        box[30].length;
    if (numOfNotReviewed == 0) numOfNotReviewed = -1;
    super.initState();
    _controller = new AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.category.timeLimit),
    )..reverse(from: 0);
    initTts();
  }

  initTts() {
    flutterTts = FlutterTts();

    if (!kIsWeb) {
      if (Platform.isAndroid) {
        _getEngines();
      }
    }

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    if (kIsWeb || Platform.isIOS) {
      flutterTts.setPauseHandler(() {
        setState(() {
          print("Paused");
          ttsState = TtsState.paused;
        });
      });

      flutterTts.setContinueHandler(() {
        setState(() {
          print("Continued");
          ttsState = TtsState.continued;
        });
      });
    }

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future _getEngines() async {
    var engines = await flutterTts.getEngines;
    if (engines != null) {
      for (dynamic engine in engines) {
        print(engine);
      }
    }
  }

  Future _speak() async {
    await flutterTts.setVolume(widget.category.volume);
    await flutterTts.setSpeechRate(widget.category.rate);
    await flutterTts.setPitch(widget.category.pitch);

    if (selectedPart != -1 && card != null && card.front != '') {
      var result = await flutterTts.speak(card.front);
      if (result == 1) setState(() => ttsState = TtsState.playing);
    }
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  void startTimer() {
    CountdownTimer countDownTimer = new CountdownTimer(
      new Duration(seconds: widget.category.timeLimit),
      new Duration(seconds: 1),
    );

    sub = countDownTimer.listen(null);

    sub.onDone(() {
      print('time is up');
      if (_questionMode) {
        if (widget.category.writeMode) {
          answer = false;
        }
        setState(() {
          _questionMode = false;
        });
      }
      if (sub != null) sub.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = (MediaQuery.of(context).size.width - 64.0) / 32;
    double height = 50.0;
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      appBar: AppBar(
        title: Text(widget.isAll ? 'مرور همه کارت ها' : 'مرور کارت ها',
            style: TextStyle(color: Colors.black, fontFamily: "Homa")),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black54,
          ),
          onPressed: () {
            Navigator.of(context).pop(context);
          },
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.only(
                left: 8.0, top: 4.0, right: 8.0, bottom: 4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // leitner box
                Column(
                  children: <Widget>[
                    Container(
                      height: 1,
                      width: (width + 1) * 32,
                      color: Colors.black,
                    ),
                    RotatedBox(
                      quarterTurns: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            color: Colors.black,
                            height: 1,
                            width: height,
                          ),
                          Container(
                            color: Colors.red,
                            height: width,
                            width: height,
                            child: Text(
                              CardsPage.replaceWithArabicNumbers(
                                  (box[0].length + wrongAnswer.length)
                                      .toString()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8.0,
                                fontFamily: 'Vazir',
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.black,
                            height: 1,
                            width: height,
                          ),
                          Container(
                            color: Colors.orange,
                            height: width,
                            width: height,
                            child: Text(
                              CardsPage.replaceWithArabicNumbers(
                                  box[1].length.toString()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8.0,
                                fontFamily: 'Vazir',
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.grey,
                            height: 1,
                            width: height,
                          ),
                          Container(
                            color: Colors.orange,
                            height: width,
                            width: height,
                            child: Text(
                              CardsPage.replaceWithArabicNumbers(
                                  box[2].length.toString()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8.0,
                                fontFamily: 'Vazir',
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.black,
                            height: 1,
                            width: height,
                          ),
                          Container(
                            color: Colors.yellow,
                            height: width,
                            width: height,
                            child: Text(
                              CardsPage.replaceWithArabicNumbers(
                                  box[3].length.toString()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8.0,
                                fontFamily: 'Vazir',
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.grey,
                            height: 1,
                            width: height,
                          ),
                          Container(
                            color: Colors.yellow,
                            height: width,
                            width: height,
                            child: Text(
                              CardsPage.replaceWithArabicNumbers(
                                  box[4].length.toString()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8.0,
                                fontFamily: 'Vazir',
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.grey,
                            height: 1,
                            width: height,
                          ),
                          Container(
                            color: Colors.yellow,
                            height: width,
                            width: height,
                            child: Text(
                              CardsPage.replaceWithArabicNumbers(
                                  box[5].length.toString()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8.0,
                                fontFamily: 'Vazir',
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.grey,
                            height: 1,
                            width: height,
                          ),
                          Container(
                            color: Colors.yellow,
                            height: width,
                            width: height,
                            child: Text(
                              CardsPage.replaceWithArabicNumbers(
                                  box[6].length.toString()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8.0,
                                fontFamily: 'Vazir',
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.black,
                            height: 1,
                            width: height,
                          ),
                          Container(
                            color: Color(0xff00db54),
                            height: width,
                            width: height,
                            child: Text(
                              CardsPage.replaceWithArabicNumbers(
                                  box[7].length.toString()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8.0,
                                fontFamily: 'Vazir',
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.grey,
                            height: 1,
                            width: height,
                          ),
                          Container(
                            color: Color(0xff00db54),
                            height: width,
                            width: height,
                            child: Text(
                              CardsPage.replaceWithArabicNumbers(
                                  box[8].length.toString()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8.0,
                                fontFamily: 'Vazir',
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.grey,
                            height: 1,
                            width: height,
                          ),
                          Container(
                            color: Color(0xff00db54),
                            height: width,
                            width: height,
                            child: Text(
                              CardsPage.replaceWithArabicNumbers(
                                  box[9].length.toString()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8.0,
                                fontFamily: 'Vazir',
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.grey,
                            height: 1,
                            width: height,
                          ),
                          Container(
                            color: Color(0xff00db54),
                            height: width,
                            width: height,
                            child: Text(
                              CardsPage.replaceWithArabicNumbers(
                                  box[10].length.toString()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8.0,
                                fontFamily: 'Vazir',
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.grey,
                            height: 1,
                            width: height,
                          ),
                          Container(
                            color: Color(0xff00db54),
                            height: width,
                            width: height,
                            child: Text(
                              CardsPage.replaceWithArabicNumbers(
                                  box[11].length.toString()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8.0,
                                fontFamily: 'Vazir',
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.grey,
                            height: 1,
                            width: height,
                          ),
                          Container(
                            color: Color(0xff00db54),
                            height: width,
                            width: height,
                            child: Text(
                              CardsPage.replaceWithArabicNumbers(
                                  box[12].length.toString()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8.0,
                                fontFamily: 'Vazir',
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.grey,
                            height: 1,
                            width: height,
                          ),
                          Container(
                            color: Color(0xff00db54),
                            height: width,
                            width: height,
                            child: Text(
                              CardsPage.replaceWithArabicNumbers(
                                  box[13].length.toString()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8.0,
                                fontFamily: 'Vazir',
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.grey,
                            height: 1,
                            width: height,
                          ),
                          Container(
                            color: Color(0xff00db54),
                            height: width,
                            width: height,
                            child: Text(
                              CardsPage.replaceWithArabicNumbers(
                                  box[14].length.toString()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8.0,
                                fontFamily: 'Vazir',
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.black,
                            height: 1,
                            width: height,
                          ),
                          Container(
                            color: Colors.blue,
                            height: width,
                            width: height,
                            child: Text(
                              CardsPage.replaceWithArabicNumbers(
                                  box[15].length.toString()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8.0,
                                fontFamily: 'Vazir',
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.grey,
                            height: 1,
                            width: height,
                          ),
                          Container(
                            color: Colors.blue,
                            height: width,
                            width: height,
                            child: Text(
                              CardsPage.replaceWithArabicNumbers(
                                  box[16].length.toString()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8.0,
                                fontFamily: 'Vazir',
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.grey,
                            height: 1,
                            width: height,
                          ),
                          Container(
                            color: Colors.blue,
                            height: width,
                            width: height,
                            child: Text(
                              CardsPage.replaceWithArabicNumbers(
                                  box[17].length.toString()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8.0,
                                fontFamily: 'Vazir',
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.grey,
                            height: 1,
                            width: height,
                          ),
                          Container(
                            color: Colors.blue,
                            height: width,
                            width: height,
                            child: Text(
                              CardsPage.replaceWithArabicNumbers(
                                  box[18].length.toString()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8.0,
                                fontFamily: 'Vazir',
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.grey,
                            height: 1,
                            width: height,
                          ),
                          Container(
                            color: Colors.blue,
                            height: width,
                            width: height,
                            child: Text(
                              CardsPage.replaceWithArabicNumbers(
                                  box[19].length.toString()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8.0,
                                fontFamily: 'Vazir',
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.grey,
                            height: 1,
                            width: height,
                          ),
                          Container(
                            color: Colors.blue,
                            height: width,
                            width: height,
                            child: Text(
                              CardsPage.replaceWithArabicNumbers(
                                  box[20].length.toString()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8.0,
                                fontFamily: 'Vazir',
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.grey,
                            height: 1,
                            width: height,
                          ),
                          Container(
                            color: Colors.blue,
                            height: width,
                            width: height,
                            child: Text(
                              CardsPage.replaceWithArabicNumbers(
                                  box[21].length.toString()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8.0,
                                fontFamily: 'Vazir',
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.grey,
                            height: 1,
                            width: height,
                          ),
                          Container(
                            color: Colors.blue,
                            height: width,
                            width: height,
                            child: Text(
                              CardsPage.replaceWithArabicNumbers(
                                  box[22].length.toString()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8.0,
                                fontFamily: 'Vazir',
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.grey,
                            height: 1,
                            width: height,
                          ),
                          Container(
                            color: Colors.blue,
                            height: width,
                            width: height,
                            child: Text(
                              CardsPage.replaceWithArabicNumbers(
                                  box[23].length.toString()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8.0,
                                fontFamily: 'Vazir',
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.grey,
                            height: 1,
                            width: height,
                          ),
                          Container(
                            color: Colors.blue,
                            height: width,
                            width: height,
                            child: Text(
                              CardsPage.replaceWithArabicNumbers(
                                  box[24].length.toString()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8.0,
                                fontFamily: 'Vazir',
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.grey,
                            height: 1,
                            width: height,
                          ),
                          Container(
                            color: Colors.blue,
                            height: width,
                            width: height,
                            child: Text(
                              CardsPage.replaceWithArabicNumbers(
                                  box[25].length.toString()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8.0,
                                fontFamily: 'Vazir',
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.grey,
                            height: 1,
                            width: height,
                          ),
                          Container(
                            color: Colors.blue,
                            height: width,
                            width: height,
                            child: Text(
                              CardsPage.replaceWithArabicNumbers(
                                  box[26].length.toString()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8.0,
                                fontFamily: 'Vazir',
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.grey,
                            height: 1,
                            width: height,
                          ),
                          Container(
                            color: Colors.blue,
                            height: width,
                            width: height,
                            child: Text(
                              CardsPage.replaceWithArabicNumbers(
                                  box[27].length.toString()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8.0,
                                fontFamily: 'Vazir',
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.grey,
                            height: 1,
                            width: height,
                          ),
                          Container(
                            color: Colors.blue,
                            height: width,
                            width: height,
                            child: Text(
                              CardsPage.replaceWithArabicNumbers(
                                  box[28].length.toString()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8.0,
                                fontFamily: 'Vazir',
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.grey,
                            height: 1,
                            width: height,
                          ),
                          Container(
                            color: Colors.blue,
                            height: width,
                            width: height,
                            child: Text(
                              CardsPage.replaceWithArabicNumbers(
                                  box[29].length.toString()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8.0,
                                fontFamily: 'Vazir',
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.grey,
                            height: 1,
                            width: height,
                          ),
                          Container(
                            color: Colors.blue,
                            height: width,
                            width: height,
                            child: Text(
                              CardsPage.replaceWithArabicNumbers(
                                  box[30].length.toString()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8.0,
                                fontFamily: 'Vazir',
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.black,
                            height: 1,
                            width: height,
                          ),
                          Container(
                            color: Colors.grey,
                            height: width,
                            width: height,
                            child: Text(
                              CardsPage.replaceWithArabicNumbers(
                                  box[31].length.toString()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8.0,
                                fontFamily: 'Vazir',
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.black,
                            height: 1,
                            width: height,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 1,
                      width: (width + 1) * 32,
                      color: Colors.black,
                    ),
                  ],
                ),
                // if today or tomarrow cards are empty
                Visibility(
                  visible: numOfNotReviewed == -1,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'برای مرور کارتی ندارید. یا کارتی اضافه کنید و یا به روز بعد جهش کنید.',
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(fontFamily: 'Vazir'),
                          ),
                          RaisedButton(
                            child: Text(
                              'افزودن کارت',
                              style: TextStyle(
                                  fontFamily: 'Vazir', color: Colors.white),
                            ),
                            color: Colors.pink,
                            onPressed: () {
                              Navigator.of(context).pop(context);
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      AddOrEditCard(widget.category.id)));
                            },
                          ),
                          RaisedButton(
                            child: Text(
                              'جهش به روز بعد',
                              style: TextStyle(
                                  fontFamily: 'Vazir', color: Colors.white),
                            ),
                            color: Colors.blue[900],
                            onPressed: () {
                              // shifting all cards in box to left
                              if (box[1].isNotEmpty) {
                                setState(() {
                                  box[2].addAll(box[1]);
                                  box[1] = [];
                                  numOfNotReviewed = box[2].length;
                                  if (numOfNotReviewed == 0)
                                    numOfNotReviewed = -1;
                                });
                                for (litBox.Card w in box[2]) {
                                  w.boxLocation = 2;
                                  litBox.CardDBHelper.instance
                                      .updateCard(w, widget.category.id);
                                }
                              } else if (box[3].isNotEmpty ||
                                  box[4].isNotEmpty ||
                                  box[5].isNotEmpty) {
                                setState(() {
                                  box[6].addAll(box[5]);
                                  box[5] = [];
                                  box[5].addAll(box[4]);
                                  box[4] = [];
                                  box[4].addAll(box[3]);
                                  box[3] = [];
                                  numOfNotReviewed = box[6].length;
                                  if (numOfNotReviewed == 0)
                                    numOfNotReviewed = -1;
                                });
                                for (litBox.Card w in box[4]) {
                                  w.boxLocation = 4;
                                  litBox.CardDBHelper.instance
                                      .updateCard(w, widget.category.id);
                                }
                                for (litBox.Card w in box[5]) {
                                  w.boxLocation = 5;
                                  litBox.CardDBHelper.instance
                                      .updateCard(w, widget.category.id);
                                }
                                for (litBox.Card w in box[6]) {
                                  w.boxLocation = 6;
                                  litBox.CardDBHelper.instance
                                      .updateCard(w, widget.category.id);
                                }
                              } else if (box[7].isNotEmpty ||
                                  box[8].isNotEmpty ||
                                  box[9].isNotEmpty ||
                                  box[10].isNotEmpty ||
                                  box[11].isNotEmpty ||
                                  box[12].isNotEmpty ||
                                  box[13].isNotEmpty) {
                                setState(() {
                                  box[14].addAll(box[13]);
                                  box[13] = [];
                                  box[13].addAll(box[12]);
                                  box[12] = [];
                                  box[12].addAll(box[11]);
                                  box[11] = [];
                                  box[11].addAll(box[10]);
                                  box[10] = [];
                                  box[10].addAll(box[9]);
                                  box[9] = [];
                                  box[9].addAll(box[8]);
                                  box[8] = [];
                                  box[8].addAll(box[7]);
                                  box[7] = [];
                                  numOfNotReviewed = box[14].length;
                                  if (numOfNotReviewed == 0)
                                    numOfNotReviewed = -1;
                                });
                                for (litBox.Card w in box[8]) {
                                  w.boxLocation = 8;
                                  litBox.CardDBHelper.instance
                                      .updateCard(w, widget.category.id);
                                }
                                for (litBox.Card w in box[9]) {
                                  w.boxLocation = 9;
                                  litBox.CardDBHelper.instance
                                      .updateCard(w, widget.category.id);
                                }
                                for (litBox.Card w in box[10]) {
                                  w.boxLocation = 10;
                                  litBox.CardDBHelper.instance
                                      .updateCard(w, widget.category.id);
                                }
                                for (litBox.Card w in box[11]) {
                                  w.boxLocation = 11;
                                  litBox.CardDBHelper.instance
                                      .updateCard(w, widget.category.id);
                                }
                                for (litBox.Card w in box[12]) {
                                  w.boxLocation = 12;
                                  litBox.CardDBHelper.instance
                                      .updateCard(w, widget.category.id);
                                }
                                for (litBox.Card w in box[13]) {
                                  w.boxLocation = 13;
                                  litBox.CardDBHelper.instance
                                      .updateCard(w, widget.category.id);
                                }
                                for (litBox.Card w in box[14]) {
                                  w.boxLocation = 14;
                                  litBox.CardDBHelper.instance
                                      .updateCard(w, widget.category.id);
                                }
                              } else {
                                setState(() {
                                  box[30].addAll(box[29]);
                                  box[29] = [];
                                  box[29].addAll(box[28]);
                                  box[28] = [];
                                  box[28].addAll(box[27]);
                                  box[27] = [];
                                  box[27].addAll(box[26]);
                                  box[26] = [];
                                  box[26].addAll(box[25]);
                                  box[25] = [];
                                  box[25].addAll(box[24]);
                                  box[24] = [];
                                  box[24].addAll(box[23]);
                                  box[23] = [];
                                  box[23].addAll(box[22]);
                                  box[22] = [];
                                  box[22].addAll(box[21]);
                                  box[21] = [];
                                  box[21].addAll(box[20]);
                                  box[20] = [];
                                  box[20].addAll(box[19]);
                                  box[19] = [];
                                  box[19].addAll(box[18]);
                                  box[18] = [];
                                  box[18].addAll(box[17]);
                                  box[17] = [];
                                  box[17].addAll(box[16]);
                                  box[16] = [];
                                  box[16].addAll(box[15]);
                                  box[15] = [];
                                  numOfNotReviewed = box[30].length;
                                  if (numOfNotReviewed == 0)
                                    numOfNotReviewed = -1;
                                });
                                for (litBox.Card w in box[15]) {
                                  w.boxLocation = 15;
                                  litBox.CardDBHelper.instance
                                      .updateCard(w, widget.category.id);
                                }
                                for (litBox.Card w in box[16]) {
                                  w.boxLocation = 16;
                                  litBox.CardDBHelper.instance
                                      .updateCard(w, widget.category.id);
                                }
                                for (litBox.Card w in box[17]) {
                                  w.boxLocation = 17;
                                  litBox.CardDBHelper.instance
                                      .updateCard(w, widget.category.id);
                                }
                                for (litBox.Card w in box[18]) {
                                  w.boxLocation = 18;
                                  litBox.CardDBHelper.instance
                                      .updateCard(w, widget.category.id);
                                }
                                for (litBox.Card w in box[19]) {
                                  w.boxLocation = 19;
                                  litBox.CardDBHelper.instance
                                      .updateCard(w, widget.category.id);
                                }
                                for (litBox.Card w in box[20]) {
                                  w.boxLocation = 20;
                                  litBox.CardDBHelper.instance
                                      .updateCard(w, widget.category.id);
                                }
                                for (litBox.Card w in box[21]) {
                                  w.boxLocation = 21;
                                  litBox.CardDBHelper.instance
                                      .updateCard(w, widget.category.id);
                                }
                                for (litBox.Card w in box[22]) {
                                  w.boxLocation = 22;
                                  litBox.CardDBHelper.instance
                                      .updateCard(w, widget.category.id);
                                }
                                for (litBox.Card w in box[23]) {
                                  w.boxLocation = 23;
                                  litBox.CardDBHelper.instance
                                      .updateCard(w, widget.category.id);
                                }
                                for (litBox.Card w in box[24]) {
                                  w.boxLocation = 24;
                                  litBox.CardDBHelper.instance
                                      .updateCard(w, widget.category.id);
                                }
                                for (litBox.Card w in box[25]) {
                                  w.boxLocation = 25;
                                  litBox.CardDBHelper.instance
                                      .updateCard(w, widget.category.id);
                                }
                                for (litBox.Card w in box[26]) {
                                  w.boxLocation = 26;
                                  litBox.CardDBHelper.instance
                                      .updateCard(w, widget.category.id);
                                }
                                for (litBox.Card w in box[27]) {
                                  w.boxLocation = 27;
                                  litBox.CardDBHelper.instance
                                      .updateCard(w, widget.category.id);
                                }
                                for (litBox.Card w in box[28]) {
                                  w.boxLocation = 28;
                                  litBox.CardDBHelper.instance
                                      .updateCard(w, widget.category.id);
                                }
                                for (litBox.Card w in box[29]) {
                                  w.boxLocation = 29;
                                  litBox.CardDBHelper.instance
                                      .updateCard(w, widget.category.id);
                                }
                                for (litBox.Card w in box[30]) {
                                  w.boxLocation = 30;
                                  litBox.CardDBHelper.instance
                                      .updateCard(w, widget.category.id);
                                }
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                // main card
                // for info of start page, review and...
                Visibility(
                  visible: numOfNotReviewed != -1,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Center(
                      child: Container(
                        width: 200,
                        height: 200,
                        child: Column(
                          children: [
                            Expanded(
                              child: new Align(
                                alignment: FractionalOffset.center,
                                child: new AspectRatio(
                                  aspectRatio: 1.0,
                                  child: new Stack(
                                    children: <Widget>[
                                      Visibility(
                                        // timer circle
                                        visible: !widget.isAll &&
                                            widget.category.timeLimit != -1 &&
                                            selectedPart != -1,
                                        child: new Positioned.fill(
                                          bottom: 10,
                                          top: 10,
                                          left: 10,
                                          right: 10,
                                          child: new AnimatedBuilder(
                                              animation: _controller,
                                              builder: (BuildContext context,
                                                  Widget child) {
                                                return new CustomPaint(
                                                  painter: new ProgressPainter(
                                                    animation: _controller,
                                                    color: Colors.pink,
                                                    backgroundColor:
                                                        Colors.white,
                                                  ),
                                                );
                                              }),
                                        ),
                                      ),
                                      new Align(
                                        alignment: FractionalOffset.center,
                                        child: new Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Visibility(
                                                visible:
                                                    widget.category.ttsEnable &&
                                                        selectedPart != -1,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: InkWell(
                                                        // pronounciation
                                                        child: Icon(
                                                          Icons.volume_up,
                                                          color:
                                                              Color(0xff00003f),
                                                          size: 35,
                                                        ),
                                                        onTap: () => _speak(),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(top: 8),
                                                child: Text(
                                                  selectedPart == -1
                                                      ? ('تعداد کارت ها : n'.replaceFirst(
                                                          'n',
                                                          CardsPage.replaceWithArabicNumbers(
                                                              (widget.isAll
                                                                      ? widget
                                                                          .cards
                                                                          .length
                                                                      : numOfNotReviewed)
                                                                  .toString())))
                                                      : selectedPart != -2
                                                          ? card.front
                                                          : '',
                                                  style: TextStyle(
                                                      fontFamily: 'Vazir',
                                                      fontSize: 25),
                                                ),
                                              ),
                                              Visibility(
                                                visible: selectedPart != -1,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 30),
                                                  child: Text(
                                                      'باقیمانده : n'.replaceFirst(
                                                          'n',
                                                          CardsPage.replaceWithArabicNumbers((widget
                                                                      .isAll
                                                                  ? widget.cards
                                                                          .length -
                                                                      nw
                                                                  : numOfNotReviewed)
                                                              .toString())),
                                                      style: TextStyle(
                                                          fontFamily: 'Vazir')),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  // show back of card
                  visible: numOfNotReviewed != -1 &&
                      selectedPart != -1 &&
                      !_questionMode,
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Container(
                      height: 50,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              selectedPart != -1 && selectedPart != -2
                                  ? card.back
                                  : '',
                              style: TextStyle(fontSize: 20),
                            ),
                            Visibility(
                              // showing if answer is correct or not in write mode
                              visible: widget.category.writeMode,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0),
                                child: Image.asset(
                                  answer
                                      ? 'images/correct_answer_icon.png'
                                      : 'images/wrong_answer_icon.png',
                                  width: 40,
                                  height: 40,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  // get input card
                  visible: numOfNotReviewed != -1 &&
                      !widget.isAll &&
                      widget.category.writeMode &&
                      selectedPart != -1 &&
                      _questionMode,
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    child: TextField(
                      // text field for answer in write mode
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), labelText: 'پاسخ'),
                      maxLines: 1,
                      controller: _inputController,
                      onChanged: (value) {
                        if (widget.category.timeLimit != -1 &&
                            value == card.back) {
                          setState(() {
                            answer = true;
                          });
                          print('timer stopped.');
                          _controller.stop();
                          sub.cancel();
                          setState(() {
                            _questionMode = false;
                          });
                        }
                      },
                    ),
                  ),
                ),
                Visibility(
                  visible: numOfNotReviewed != -1,
                  child: Card(
                    // controller card for next
                    color: selectedPart != -1
                        ? (_questionMode ? Colors.amber[600] : Colors.white)
                        : Color(0xff00db54),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    child: InkWell(
                      onTap: () {
                        if (widget.isAll) {
                          if (selectedPart == -1)
                            gotoNextCard(true);
                          else if (_questionMode) {
                            setState(() {
                              _questionMode = false;
                            });
                          } else {
                            setState(() {
                              _questionMode = true;
                            });
                            gotoNextCard(true);
                          }
                        } else {
                          if (selectedPart == -1) {
                            gotoNextCard(true);
                            if (widget.category.timeLimit != -1) {
                              print('timer started');
                              _controller.reverse(
                                from: 1.0,
                              );
                              startTimer();
                            }
                          } else if (_questionMode) {
                            if (widget.category.writeMode) {
                              if (widget.category.timeLimit != -1)
                                answer = false;
                              else
                                answer =
                                    _inputController.text.trim() == card.back;
                            }
                            print('timer stopped.');
                            _controller.stop();
                            if (sub != null) sub.cancel();
                            setState(() {
                              _questionMode = false;
                            });
                          } else if (widget.category.writeMode) {
                            setState(() {
                              _questionMode = true;
                            });
                            gotoNextCard(answer);
                            if (widget.category.timeLimit != -1) {
                              _controller.reverse(
                                from: 1.0,
                              );
                              startTimer();
                            }
                          }
                        }
                      },
                      // continue button
                      child: Container(
                        height: 50,
                        child: Center(
                          child: Text(
                            selectedPart == -1
                                ? 'شروع'
                                : _questionMode
                                    ? 'مشاهده پاسخ'
                                    : widget.isAll
                                        ? 'سوال بعدی'
                                        : widget.category.writeMode
                                            ? 'سوال بعدی'
                                            : 'بلد بودی؟',
                            style: TextStyle(fontFamily: 'Vazir', fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                    // yes and no card
                    visible: numOfNotReviewed != -1 &&
                        !widget.isAll &&
                        !widget.category.writeMode &&
                        selectedPart != -1 &&
                        !_questionMode,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Card(
                          color: Color(0xff00db54),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _questionMode = true;
                              });
                              gotoNextCard(true);
                              if (widget.category.timeLimit != -1) {
                                _controller.reverse(
                                  from: 1.0,
                                );
                                startTimer();
                              }
                            },
                            child: Container(
                              height: 50,
                              width:
                                  (MediaQuery.of(context).size.width - 32) / 2,
                              child: Center(
                                child: Text('بله',
                                    style: TextStyle(
                                        fontFamily: 'Vazir', fontSize: 15)),
                              ),
                            ),
                          ),
                        ),
                        Card(
                          color: Color(0xffff2045),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _questionMode = true;
                              });
                              gotoNextCard(false);
                              if (widget.category.timeLimit != -1) {
                                _controller.reverse(
                                  from: 1.0,
                                );
                                startTimer();
                              }
                            },
                            child: Container(
                              height: 50,
                              width:
                                  (MediaQuery.of(context).size.width - 32) / 2,
                              child: Center(
                                child: Text('خیر',
                                    style: TextStyle(
                                        fontFamily: 'Vazir', fontSize: 15)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ))
              ],
            )),
      ),
    );
  }

  void gotoNextCard(bool didYouKnow) {
    // if review all mode
    if (widget.isAll) {
      // if all card are reviewed
      if (nw >= widget.cards.length)
        Navigator.pop(context);
      else // go to next card
        setState(() {
          card = widget.cards[nw++];
          if (selectedPart == -1) selectedPart++;
        });
    } else {
      if (selectedPart == -1 && card != null) {
        Navigator.pop(context);
        // update review time
        for (litBox.Card w in widget.cards) {
          w.lastReview = DateTime.now();
          litBox.CardDBHelper.instance.updateCard(w, widget.category.id);
        }
      }
      // finding last full part of box
      if (selectedPart == -1) {
        if (box[30].isNotEmpty) {
          selectedPart = 30;
        } else if (box[14].isNotEmpty) {
          selectedPart = 14;
        } else if (box[6].isNotEmpty) {
          selectedPart = 6;
        } else if (box[2].isNotEmpty) {
          selectedPart = 2;
        } else {
          selectedPart = 0;
        }
        resPart = selectedPart + 1;
        while (box[resPart].isNotEmpty && resPart != 31) {
          resPart++;
        }
      } else {
        // set answer and update in db
        if (didYouKnow) {
          card.boxLocation = resPart;
          setState(() {
            box[card.boxLocation].add(card);
          });
        } else {
          card.boxLocation = 0;
          wrongAnswer.add(card);
        }
        litBox.CardDBHelper.instance.updateCard(card, widget.category.id);
        setState(() {
          box[selectedPart].remove(card);
        });
        if (box[selectedPart].isEmpty) {
          if (selectedPart == 0) {
            Navigator.pop(context);
            for (litBox.Card w in widget.cards) {
              w.lastReview = DateTime.now();
              litBox.CardDBHelper.instance.updateCard(w, widget.category.id);
            }
          }
          int tail = getTailOfPartition(selectedPart);
          selectedPart--;
          for (; selectedPart >= tail; selectedPart--) {
            for (litBox.Card w in box[selectedPart]) {
              w.boxLocation++;
              litBox.CardDBHelper.instance.updateCard(w, widget.category.id);
            }
            setState(() {
              box[selectedPart + 1] = box[selectedPart];
              box[selectedPart] = [];
            });
          }
          resPart = selectedPart + 1;
          while (box[resPart].isNotEmpty && resPart != 31) {
            resPart++;
          }
        }
      }
      setState(() {
        numOfNotReviewed--;
        if (numOfNotReviewed == -1 && selectedPart == -1 ||
            box[selectedPart].isEmpty) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
            for (litBox.Card w in widget.cards) {
              w.lastReview = DateTime.now();
              litBox.CardDBHelper.instance.updateCard(w, widget.category.id);
            }
          }
        } else {
          card = box[selectedPart][widget.category.shuffle
              ? random.nextInt(box[selectedPart].length)
              : 0];
        }
      });
      print('ooo: selected part = ' + selectedPart.toString());
      print('ooo: res part = ' + resPart.toString());
      print('ooo: card = ' + (card == null ? 'null' : card.front));
    }
  }

  int getHeadOfPartition(int pNum) {
    while (pNum != 0 && pNum != 2 && pNum != 6 && pNum != 14 && pNum != 30) {
      pNum++;
    }
    return pNum;
  }

  int getTailOfPartition(int pNum) {
    while (pNum != 0 && pNum != 1 && pNum != 3 && pNum != 7 && pNum != 15) {
      pNum--;
    }
    return pNum;
  }
}

class ProgressPainter extends CustomPainter {
  ProgressPainter({
    @required this.animation,
    @required this.backgroundColor,
    @required this.color,
  }) : super(repaint: animation);

  /// Animation representing what we are painting
  final Animation<double> animation;

  /// The color in the background of the circle
  final Color backgroundColor;

  /// The foreground color used to indicate progress
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = backgroundColor
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint.color = color;
    double progressRadians = (1.0 - animation.value) * 2 * pi;
    canvas.drawArc(
        Offset.zero & size, pi * 1.5, -progressRadians, false, paint);
  }

  @override
  bool shouldRepaint(ProgressPainter other) {
    return animation.value != other.animation.value ||
        color != other.color ||
        backgroundColor != other.backgroundColor;
  }
}
