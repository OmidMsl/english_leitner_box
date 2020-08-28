import 'dart:io';

import 'package:english_leitner_box/Category.dart' as msl;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SettingsPage extends StatefulWidget {
  final msl.Category category;
  SettingsPage(this.category);
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

enum TtsState { playing, stopped, paused, continued }

class _SettingsPageState extends State<SettingsPage> {
  FlutterTts flutterTts;
  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;

  get isPaused => ttsState == TtsState.paused;

  get isContinued => ttsState == TtsState.continued;
  TextEditingController _testTextController =
          TextEditingController(text: 'hello'),
      _timeLimitTextController;
  TextStyle _textStyle = TextStyle(fontFamily: 'Vazir');

  @override
  void initState() {
    // TODO: implement initState
    initTts();
    super.initState();
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

    if (_testTextController != null || _testTextController.text.trim() != '') {
      var result = await flutterTts.speak(_testTextController.text);
      if (result == 1) setState(() => ttsState = TtsState.playing);
    }
  }

  @override
  void dispose() {
    msl.CategoryDBHelper.instance.updateCategory(widget.category);
    super.dispose();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    _timeLimitTextController = TextEditingController(
        text: widget.category == null || widget.category.timeLimit == -1
            ? '12'
            : widget.category.timeLimit.toString());
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xff450086), Color(0xff760fd6), Color(0xffff00e3)])),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'تلفظ',
                        style: _textStyle,
                      ),
                      Checkbox(
                          value: widget.category.ttsEnable,
                          onChanged: (value) {
                            setState(() {
                              widget.category.ttsEnable = value;
                            });
                          }),
                    ],
                  ),
                  Visibility(
                      visible: widget.category.ttsEnable,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'میزان صدا',
                            style: _textStyle,
                          ),
                          Slider(
                              value: widget.category.volume,
                              onChanged: (newVolume) {
                                _speak();
                                setState(
                                    () => widget.category.volume = newVolume);
                              },
                              min: 0.0,
                              max: 1.0,
                              divisions: 10,
                              label: "میزان: " +
                                  widget.category.volume.toString()),
                          Text(
                            'زیر و بمی صدا',
                            style: _textStyle,
                          ),
                          Slider(
                            value: widget.category.pitch,
                            onChanged: (newPitch) {
                              _speak();
                              setState(() => widget.category.pitch = newPitch);
                            },
                            min: 0.5,
                            max: 2.0,
                            divisions: 15,
                            label: "بمی: " + widget.category.pitch.toString(),
                            activeColor: Colors.red,
                          ),
                          Text(
                            'سرعت تلفظ',
                            style: _textStyle,
                          ),
                          Slider(
                            value: widget.category.rate,
                            onChanged: (newRate) {
                              _speak();
                              setState(() => widget.category.rate = newRate);
                            },
                            min: 0.0,
                            max: 1.0,
                            divisions: 10,
                            label: "سرعت: " + widget.category.rate.toString(),
                            activeColor: Colors.green,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                RaisedButton(
                                  onPressed: () => _speak(),
                                  color: Colors.deepPurple[800],
                                  child: Text(
                                    'آزمایش',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Vazir',
                                        color: Colors.white),
                                  ),
                                ),
                                Container(
                                  width: 200,
                                  child: TextField(
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: " عبارت آزمایش      "),
                                    maxLines: 1,
                                    controller: _testTextController,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ))
                ],
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'محدودیت زمانی',
                        style: _textStyle,
                      ),
                      Checkbox(
                          value: widget.category.timeLimit != -1,
                          onChanged: (value) {
                            setState(() {
                              widget.category.timeLimit = value
                                  ? int.parse(_timeLimitTextController.text)
                                  : -1;
                            });
                          }),
                    ],
                  ),
                  Visibility(
                    visible: widget.category.timeLimit != -1,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Container(
                        width: 200,
                        child: TextField(
                          keyboardType: TextInputType.numberWithOptions(
                              decimal: true, signed: false),
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: " (زمان(به ثانیه      "),
                          maxLines: 1,
                          controller: _timeLimitTextController,
                          onChanged: (value) {
                            widget.category.timeLimit = int.parse(value);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'در هم سازی کارت ها هنگام مرور',
                    style: _textStyle,
                  ),
                  Checkbox(
                      value: widget.category.shuffle,
                      onChanged: (value) {
                        setState(() {
                          widget.category.shuffle = value;
                        });
                      }),
                ],
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DropdownButton(
                    items: [
                      DropdownMenuItem(
                          value: false, child: Text('جواب بله یا خیر')),
                      DropdownMenuItem(value: true, child: Text('نوشتن پاسخ'))
                    ],
                    onChanged: (bool value) {
                      setState(() {
                        widget.category.writeMode = value;
                      });
                    },
                    value: widget.category.writeMode,
                  ),
                  Text(
                    'روش مرور کارت ها',
                    style: _textStyle,
                  ),
                ],
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RaisedButton(
                      child: Text(
                        'بازنشانی به تنظیمات اولیه',
                        style: _textStyle,
                        textAlign: TextAlign.center,
                      ),
                      color: Colors.orange[800],
                      onPressed: () {
                        setState(() {
                          widget.category.pitch = 1.0;
                          widget.category.rate = 0.5;
                          widget.category.volume = 0.5;
                          widget.category.timeLimit = -1;
                          widget.category.ttsEnable = true;
                          widget.category.writeMode = false;
                          widget.category.shuffle = true;
                        });
                      },
                    ),
                    RaisedButton(
                      child: Text(
                        'تنظیم برای همه ی دسته بندی ها',
                        textAlign: TextAlign.center,
                        style: _textStyle,
                      ),
                      color: Colors.blue,
                      onPressed: () {
                        msl.CategoryDBHelper.instance
                            .retrieveCategories()
                            .then((value) {
                          for (msl.Category category in value) {
                            category.pitch = widget.category.pitch;
                            category.rate = widget.category.rate;
                            category.volume = widget.category.volume;
                            category.timeLimit = widget.category.timeLimit;
                            category.ttsEnable = widget.category.ttsEnable;
                            category.writeMode = widget.category.writeMode;
                            category.shuffle = widget.category.shuffle;

                            msl.CategoryDBHelper.instance
                                .updateCategory(category);
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
