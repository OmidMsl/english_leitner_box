import 'package:english_leitner_box/Word.dart';
import 'package:english_leitner_box/wordsPage.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ReviewPage extends StatefulWidget {
  final List<Word> words;
  final bool isAll;
  ReviewPage({this.words, this.isAll});
  @override
  _ReviewPageState createState() => _ReviewPageState();
}

enum TtsState { playing, stopped, paused, continued }

class _ReviewPageState extends State<ReviewPage> {
  int _index = -1;
  bool _questionMode = true;

  // pronunciation stuff
  FlutterTts flutterTts;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;

  get isPaused => ttsState == TtsState.paused;

  get isContinued => ttsState == TtsState.continued;

  @override
  initState() {
    super.initState();
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
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (_index != -1 && _index < widget.words.length) {
      if (widget.words[_index].word != '') {
        var result = await flutterTts.speak(widget.words[_index].word);
        if (result == 1) setState(() => ttsState = TtsState.playing);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      appBar: AppBar(
        title: Text(widget.isAll ? 'مرور همه کلمات' : 'مرور کلمات مرور نشده',
            style: TextStyle(color: Colors.black54, fontFamily: "Vazir")),
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
      body: Padding(
          padding: const EdgeInsets.only(
              left: 8.0, top: 4.0, right: 8.0, bottom: 4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                child: Container(
                  // top card (for num of words and words)
                  height: 150,
                  child: Center(
                      child: Column(
                    children: <Widget>[
                      Visibility(
                        visible: _index != -1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                // pronounciation
                                child: Icon(
                                  Icons.volume_up,
                                  color: Color(0xff00003f),
                                  size: 35,
                                ),
                                onTap: () => _speak(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: (_index != -1 ? 8 : 55)),
                        child: Text(
                          _index == -1
                              ? ('تعداد کلمات : n'.replaceFirst(
                                  'n',
                                  WordsPage.replaceWithArabicNumbers(
                                      widget.words.length.toString())))
                              : _index < widget.words.length
                                  ? widget.words[_index].word
                                  : '',
                          style: TextStyle(fontFamily: 'Vazir', fontSize: 25),
                        ),
                      ),
                      Visibility(
                        visible: _index != -1,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Text(
                              'باقیمانده : n'.replaceFirst(
                                  'n',
                                  WordsPage.replaceWithArabicNumbers(
                                      (widget.words.length - _index - 1)
                                          .toString())),
                              style: TextStyle(fontFamily: 'Vazir')),
                        ),
                      )
                    ],
                  )),
                ),
              ),
              Visibility(
                // show translation card
                visible: _index != -1 && !_questionMode,
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Container(
                    height: 50,
                    child: Center(
                      child: Text(
                        _index < widget.words.length && _index != -1
                            ? widget.words[_index].translation
                            : '',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),
              ),
              Card(
                // controller card for next
                color: _index != -1
                    ? (_questionMode ? Colors.amber[600] : Colors.white)
                    : Color(0xff00db54),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (_index == -1)
                        _index++;
                      else if (_questionMode) _questionMode = false;
                    });
                    if (_index == widget.words.length) Navigator.pop(context);
                  },
                  child: Container(
                    height: 50,
                    child: Center(
                      child: Text(
                        _index == -1
                            ? 'شروع'
                            : _questionMode ? 'مشاهده پاسخ' : 'بلد بودی؟',
                        style: TextStyle(fontFamily: 'Vazir', fontSize: 15),
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                  // yes and no card
                  visible: _index != -1 && !_questionMode,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Card(
                        color: Color(0xff00db54),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        child: InkWell(
                          onTap: () {
                            widget.words[_index].lastReview = DateTime.now();
                            widget.words[_index].isLastReviewSuessful = true;
                            WordDBHelper.instance
                                .updateWord(widget.words[_index]);
                            setState(() {
                              _questionMode = true;
                              _index++;
                              if (_index == widget.words.length)
                                Navigator.pop(context);
                            });
                          },
                          child: Container(
                            height: 50,
                            width: (MediaQuery.of(context).size.width - 32) / 2,
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
                            widget.words[_index].lastReview = DateTime.now();
                            widget.words[_index].isLastReviewSuessful = false;
                            WordDBHelper.instance
                                .updateWord(widget.words[_index]);
                            setState(() {
                              _questionMode = true;
                              _index++;
                              if (_index == widget.words.length)
                                Navigator.pop(context);
                            });
                          },
                          child: Container(
                            height: 50,
                            width: (MediaQuery.of(context).size.width - 32) / 2,
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
    );
  }
}
