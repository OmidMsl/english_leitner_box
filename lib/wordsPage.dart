import 'package:english_leitner_box/Word.dart';
import 'package:english_leitner_box/addOrEditWord.dart';
import 'package:english_leitner_box/alert_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class WordsPage extends StatefulWidget {
  @override
  _WordsPageState createState() => _WordsPageState();

  static String replaceWithArabicNumbers(String original) {
    return original
        .replaceAll('0', '٠')
        .replaceAll("1", "١")
        .replaceAll("2", "٢")
        .replaceAll("3", "٣")
        .replaceAll('4', '٤')
        .replaceAll('5', '٥')
        .replaceAll('6', '٦')
        .replaceAll('7', '٧')
        .replaceAll('8', '٨')
        .replaceAll('9', '٩');
  }
}

class _WordsPageState extends State<WordsPage> {
  bool _isFabExtended = true,
      _selectMode = false,
      _editMode = false,
      _deleteMode = false,
      upDirection = true,
      flag = true;
  int _numOfWords = 0;
  List<Word> _selecteds = [];
  Future wordsFuture;
  ScrollController _scrollController;
  bool isSelected(int id) {
    for (Word w in _selecteds) {
      if (w.id == id) return true;
    }
    return false;
  }

  void removeSelected(int id) {
    for (Word w in _selecteds) {
      if (w.id == id) {
        _selecteds.remove(w);
        break;
      }
    }
  }

  List<Color> colors = [
    Colors.blue,
    Colors.pink,
    Colors.amber,
    Colors.purple,
    Colors.deepOrange,
    Colors.lightBlue,
    Colors.lime,
    Colors.black,
    Colors.red,
    Colors.lightGreen,
    Colors.indigo,
    Colors.yellow
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchWords();
    _scrollController = ScrollController()
      ..addListener(() {
        upDirection = _scrollController.position.userScrollDirection ==
            ScrollDirection.forward;

        // makes sure we don't call setState too much, but only when it is needed
        if (upDirection != flag)
          setState(() {
            _isFabExtended = !_isFabExtended;
          });

        flag = upDirection;
      });
  }

  void fetchWords() {
    wordsFuture = WordDBHelper.instance.retrieveWords();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("کلمات",
            style: TextStyle(color: Colors.black54, fontFamily: "Vazir")),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: <Widget>[
          Visibility(
            visible: !_editMode,
            child: IconButton(
              icon: Icon(
                _deleteMode ? Icons.delete_forever : Icons.delete,
                color: _deleteMode ? Colors.blue : Colors.black54,
              ),
              onPressed: () {
                setState(() {
                  if (_deleteMode) {
                    _deleteMode = false;
                    _selecteds = [];
                  } else if (_selectMode) {
                    _showDeleteDialog();
                  } else {
                    _deleteMode = true;
                  }
                });
              },
            ),
          ),
          Visibility(
            visible: _selecteds.length < 2 && !_deleteMode,
            child: IconButton(
                icon: Icon(
                  Icons.edit,
                  color: _editMode ? Colors.blue : Colors.black54,
                ),
                onPressed: () {
                  setState(() {
                    if (_selectMode) {
                      _navigateToDetail(context, _selecteds[0]);
                      _selectMode = false;
                      _selecteds = [];
                    } else if (_editMode) {
                      _editMode = false;
                      _selecteds = [];
                    } else {
                      _editMode = true;
                    }
                  });
                }),
          )
        ],
      ),
      body: Scaffold(
        backgroundColor: Colors.green[700],
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(30.0),
          child: AppBar(
            leading: Visibility(
              visible: !_selectMode && !_deleteMode,
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 5.0, bottom: 5.0, left: 10.0),
                child: Text(
                  'ترجمه',
                  style: TextStyle(color: Colors.black87, fontFamily: 'Vazir'),
                ),
              ),
            ),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: (_selectMode || _deleteMode)
                    ? InkWell(
                        child: Row(
                          children: <Widget>[
                            Text(
                              'انتخاب همه  ',
                              style: TextStyle(
                                  color: Colors.black87, fontFamily: 'Vazir'),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 7.0),
                              child: Icon(
                                _selecteds.length == _numOfWords
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: _selecteds.length == _numOfWords
                                    ? Colors.green
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            if (_selecteds.length == _numOfWords) {
                              _selecteds = [];
                            } else
                              WordDBHelper.instance
                                  .retrieveWords()
                                  .then((value) => _selecteds = value);
                          });
                        },
                      )
                    : Text('کلمه',
                        style: TextStyle(
                            color: Colors.black87, fontFamily: 'Vazir')),
              )
            ],
            backgroundColor: Colors.white,
          ),
        ),
        body: FutureBuilder<List<Word>>(
          future: wordsFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _numOfWords = snapshot.data.length;
              return ListView.builder(
                padding: EdgeInsets.only(bottom: 70),
                controller: _scrollController,
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  Word w = snapshot.data[index];
                  return Card(
                    color: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(8.0))),
                    child: InkWell(
                      onTap: () {
                        if (_selectMode || _deleteMode) {
                          if (isSelected(w.id)) {
                            if (_selecteds.length == 1) {
                              setState(() {
                                _selectMode = false;
                                _deleteMode = false;
                                _selecteds = [];
                              });
                            } else {
                              setState(() {
                                removeSelected(w.id);
                              });
                            }
                          } else {
                            setState(() {
                              _selecteds.add(w);
                            });
                          }
                        } else if (_editMode) {
                          _navigateToDetail(context, w);
                          setState(() {
                            _editMode = false;
                            _selectMode = false;
                            _selecteds = [];
                          });
                        }
                      },
                      onLongPress: () {
                        if (_selectMode || _editMode || _deleteMode) {
                        } else {
                          setState(() {
                            _selectMode = true;
                            _selecteds.add(w);
                          });
                        }
                        return false;
                      },
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              textDirection: TextDirection.rtl,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(w.word),
                                    Visibility(
                                      visible: _selectMode || _deleteMode,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Icon(
                                          isSelected(w.id)
                                              ? Icons.check_circle
                                              : Icons.radio_button_unchecked,
                                          color: isSelected(w.id)
                                              ? Colors.green
                                              : Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(w.translation),
                              ],
                            ),
                          ),
                          Container(
                              height: 5, color: colors[index % colors.length])
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text("Oops!");
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
      backgroundColor: Colors.green[700],
      floatingActionButton: AnimatedContainer(
          duration: Duration(),
          child: Visibility(
            visible: !(_deleteMode && _selecteds.isEmpty),
            child: FloatingActionButton.extended(
              onPressed: () {
                _fabOnClick();
              },
              backgroundColor: Color(0xff00003f),
              isExtended: _isFabExtended,
              label: _isFabExtended
                  ? Text(
                      _deleteMode
                          ? 'حذف'
                          : _editMode || _selectMode ? 'لغو' : 'کلمه جدید',
                      style: TextStyle(fontFamily: "Vazir"))
                  : Icon(_deleteMode
                      ? Icons.delete
                      : _editMode || _selectMode ? Icons.clear : Icons.add),
              icon: _isFabExtended
                  ? Icon(_deleteMode
                      ? Icons.delete
                      : _editMode || _selectMode ? Icons.clear : Icons.add)
                  : null,
            ),
          )),
    );
  }

  _fabOnClick() {
    setState(() {
      if (_deleteMode) {
        _showDeleteDialog();
      } else if (_editMode) {
        _editMode = false;
        _selecteds = [];
      } else if (_selectMode) {
        _selecteds = [];
        _selectMode = false;
      } else {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => AddOrEditWord()))
            .then((value) {
          setState(() {
            fetchWords();
          });
        });
      }
    });
  }

  _showDeleteDialog() {
    deleteDialog(
        context,
        (_selecteds.length == 1
            ? (isEnglish(_selecteds[0].word)
                ? 'را حذف می کنید؟ ' + _selecteds[0].word
                : _selecteds[0].word + 'را حذف می کنید؟ ')
            : WordsPage.replaceWithArabicNumbers(
                _selecteds.length.toString() + ' آیتم را حذف می کنید؟ ')),
        positiveAction: () {
      setState(() {
        for (Word w in _selecteds) {
          _deleteBusiness(w);
        }
        fetchWords();
        _deleteMode = false;
        _selectMode = false;
        _selecteds = [];
      });
    }, neutralAction: () {
      setState(() {
        _deleteMode = false;
        _selectMode = false;
        _selecteds = [];
      });
    });
  }

  bool isEnglish(String s) {
    int n = s.codeUnitAt(0);
    if (n > 23 && n < 127) {
      return true;
    }
    return false;
  }

  _navigateToDetail(BuildContext context, Word word) async {
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => AddOrEditWord(
                  word: word,
                )))
        .then((value) {
      setState(() {
        fetchWords();
      });
    });
  }

  _deleteBusiness(Word word) {
    WordDBHelper.instance.deleteWord(word.id);
    setState(() {
      fetchWords();
    });
  }
}
