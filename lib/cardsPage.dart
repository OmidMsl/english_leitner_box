import 'package:english_leitner_box/Card.dart' as litBox;
import 'package:english_leitner_box/addOrEditCard.dart';
import 'package:english_leitner_box/alert_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CardsPage extends StatefulWidget {
  int categoryId;
  bool _isFabExtended = true,
      selectMode = false,
      editMode = false,
      deleteMode = false,
      copyMode = false,
      moveMode = false,
      isSidebarCollapsed = true;
  List<litBox.Card> selecteds = [];
  // this function calls the main page to edit appbar icons
  Function(bool dm, bool em, bool sm, List<litBox.Card> ss, bool cm, bool mm,
      bool isc) editAppbar;

  CardsPage(this.categoryId,
      {Key key,
      @required this.editAppbar,
      this.deleteMode,
      this.editMode,
      this.selectMode,
      this.selecteds,
      this.copyMode,
      this.moveMode,
      this.isSidebarCollapsed})
      : super(key: key);

  @override
  _CardsPageState createState() => _CardsPageState();

  // replace english numbers with hindi numbers
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

class _CardsPageState extends State<CardsPage> {
  bool upDirection = true, flag = true;
  int _numOfCards = 0;
  Future cardsFuture;
  ScrollController _scrollController;
  List<litBox.Card> cards;

  // is this card selected by user
  bool isSelected(int id) {
    for (litBox.Card w in widget.selecteds) {
      if (w.id == id) return true;
    }
    return false;
  }

  // uncheck card
  void removeSelected(int id) {
    for (litBox.Card w in widget.selecteds) {
      if (w.id == id) {
        widget.selecteds.remove(w);
        break;
      }
    }
  }

  List<Color> colors = [
    Colors.blue,
    Colors.green,
    Colors.pink,
    Colors.amber,
    Colors.purple,
    Colors.cyanAccent,
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
    _scrollController = ScrollController()
      ..addListener(() {
        upDirection = _scrollController.position.userScrollDirection ==
            ScrollDirection.forward;

        // makes sure we don't call setState too much, but only when it is needed
        if (upDirection != flag)
          setState(() {
            widget._isFabExtended = !widget._isFabExtended;
          });

        flag = upDirection;
      });
  }

  // getting cards from db
  void fetchCards() {
    cardsFuture = litBox.CardDBHelper.instance.retrieveCards(widget.categoryId);
  }

  Widget build(BuildContext context) {
    fetchCards();
    return Scaffold(
      body: Container(
        // gradient of the background of page
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
              Color(0xff041554),
              Color(0xff232863),
              Color(0xff450086)
            ])),
        // top box of page
        // at select mode it shows select all button. otherwise it shows front and back text
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(30.0),
            child: AppBar(
              leading: Visibility(
                visible: !widget.selectMode &&
                    !widget.deleteMode &&
                    !widget.copyMode &&
                    !widget.moveMode,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                  child: Text(
                    'پاسخ',
                    style:
                        TextStyle(color: Colors.black87, fontFamily: 'Vazir'),
                  ),
                ),
              ),
              actions: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.only(top: 5.0, bottom: 5.0, right: 8.0),
                  child: (widget.selectMode ||
                          widget.deleteMode ||
                          widget.copyMode ||
                          widget.moveMode)
                      ? InkWell(
                          child: Row(
                            children: <Widget>[
                              Text(
                                'انتخاب همه  ',
                                style: TextStyle(
                                    color: Colors.black87, fontFamily: 'Vazir'),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 7.0),
                                child: Icon(
                                  widget.selecteds.length == _numOfCards
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: widget.selecteds.length == _numOfCards
                                      ? Colors.green
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            if (widget.selecteds.length == _numOfCards) {
                              widget.selecteds = [];
                            } else {
                              setState(() {
                                if (cards != null) widget.selecteds = cards;
                              });
                            }

                            widget.editAppbar(
                                widget.deleteMode,
                                widget.editMode,
                                widget.selectMode,
                                widget.selecteds,
                                widget.copyMode,
                                widget.moveMode,
                                widget.isSidebarCollapsed);
                          },
                        )
                      : Text('جلوی کارت   ',
                          style: TextStyle(
                              color: Colors.black87, fontFamily: 'Vazir')),
                )
              ],
              backgroundColor: Colors.white,
            ),
          ),
          // future builder for building cards list
          body: FutureBuilder<List<litBox.Card>>(
            future: cardsFuture,
            builder: (context, snapshot) {
              // if there is any card
              if (snapshot.hasData) {
                _numOfCards = snapshot.data.length;
                cards = snapshot.data;
                return ListView.builder(
                  padding: EdgeInsets.only(bottom: 70),
                  controller: _scrollController,
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    litBox.Card w = snapshot.data[index];
                    return Card(
                      color: Colors.white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8.0),
                              topRight: Radius.circular(8.0))),
                      child: InkWell(
                        onTap: () {
                          // if any mode (except edit mode) is enabled
                          if (widget.selectMode ||
                              widget.deleteMode ||
                              widget.copyMode ||
                              widget.moveMode) {
                            // if this card is already selected
                            if (isSelected(w.id)) {
                              // if this card is only card that is selected
                              if (widget.selecteds.length == 1) {
                                // disable all modes
                                widget.selectMode = false;
                                widget.deleteMode = false;
                                widget.copyMode = false;
                                widget.moveMode = false;
                                widget.selecteds = [];
                              } else {
                                // if this card is not only card that is selected
                                // uncheck this card
                                removeSelected(w.id);
                              }
                            } else {
                              // if this card isn't selected
                              widget.selecteds.add(w);
                            }
                            // if just edit mode is selected
                          } else if (widget.editMode) {
                            // edit card
                            _navigateToDetail(context, w);
                            widget.editMode = false;
                            widget.selectMode = false;
                            widget.selecteds = [];
                          }
                          // update appbar
                          widget.editAppbar(
                              widget.deleteMode,
                              widget.editMode,
                              widget.selectMode,
                              widget.selecteds,
                              widget.copyMode,
                              widget.moveMode,
                              widget.isSidebarCollapsed);
                        },
                        onLongPress: () {
                          // if any mode is enabled
                          if (widget.selectMode ||
                              widget.editMode ||
                              widget.deleteMode ||
                              widget.copyMode ||
                              widget.moveMode) {
                          } else {
                            widget.selectMode = true;
                            widget.selecteds.add(w);
                          }
                          print('ooo: on long click');
                          // update appbar
                          widget.editAppbar(
                              widget.deleteMode,
                              widget.editMode,
                              widget.selectMode,
                              widget.selecteds,
                              widget.copyMode,
                              widget.moveMode,
                              widget.isSidebarCollapsed);
                          return false;
                        },
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                textDirection: TextDirection.rtl,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Text(w.front.length > 20
                                          ? w.front.substring(0, 20) + '...'
                                          : w.front),
                                      Visibility(
                                        visible: widget.selectMode ||
                                            widget.deleteMode ||
                                            widget.copyMode ||
                                            widget.moveMode,
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
                                  Text(w.back.length > 20
                                      ? w.back.substring(0, 20) + '...'
                                      : w.back),
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
      ),
      backgroundColor: Colors.transparent,
      floatingActionButton: AnimatedContainer(
          duration: Duration(),
          child: Visibility(
            visible: !(widget.deleteMode && widget.selecteds.isEmpty),
            child: FloatingActionButton.extended(
              onPressed: () {
                _fabOnClick();
              },
              backgroundColor: Colors.pink,
              isExtended: widget._isFabExtended,
              label: widget._isFabExtended
                  ? Text(
                      widget.deleteMode
                          ? 'حذف'
                          : widget.copyMode
                              ? widget.selecteds.isEmpty ? 'لغو' : 'کپی به'
                              : widget.moveMode
                                  ? widget.selecteds.isEmpty
                                      ? 'لغو'
                                      : 'انتقال به'
                                  : widget.editMode || widget.selectMode
                                      ? 'لغو'
                                      : 'کارت جدید',
                      style: TextStyle(fontFamily: "Homa"))
                  : Icon(widget.deleteMode
                      ? Icons.delete
                      : widget.copyMode
                          ? widget.selecteds.isEmpty
                              ? Icons.clear
                              : Icons.content_copy
                          : widget.moveMode
                              ? widget.selecteds.isEmpty
                                  ? Icons.clear
                                  : Icons.content_cut
                              : widget.editMode || widget.selectMode
                                  ? Icons.clear
                                  : Icons.add),
              icon: widget._isFabExtended
                  ? Icon(widget.deleteMode
                      ? Icons.delete
                      : widget.copyMode
                          ? widget.selecteds.isEmpty
                              ? Icons.clear
                              : Icons.content_copy
                          : widget.moveMode
                              ? widget.selecteds.isEmpty
                                  ? Icons.clear
                                  : Icons.content_cut
                              : widget.editMode || widget.selectMode
                                  ? Icons.clear
                                  : Icons.add)
                  : null,
            ),
          )),
    );
  }

  _fabOnClick() {
    if (widget.deleteMode) {
      _showDeleteDialog();
    } else if (widget.editMode) {
      widget.editMode = false;
      widget.selecteds = [];
    } else if (widget.copyMode) {
      if (widget.selecteds.isEmpty) {
        widget.copyMode = false;
      } else {
        widget.isSidebarCollapsed = false;
      }
    } else if (widget.moveMode) {
      if (widget.selecteds.isEmpty) {
        widget.moveMode = false;
      } else {
        widget.isSidebarCollapsed = false;
      }
    } else if (widget.selectMode) {
      widget.selecteds = [];
      widget.selectMode = false;
    } else {
      Navigator.of(context)
          .push(MaterialPageRoute(
              builder: (context) => AddOrEditCard(widget.categoryId)))
          .then((value) {
        fetchCards();
      });
    }
    // update appbar
    widget.editAppbar(
        widget.deleteMode,
        widget.editMode,
        widget.selectMode,
        widget.selecteds,
        widget.copyMode,
        widget.moveMode,
        widget.isSidebarCollapsed);
  }

  _showDeleteDialog() {
    deleteDialog(
        context,
        (widget.selecteds.length == 1
            ? (isEnglish(widget.selecteds[0].front)
                ? 'را حذف می کنید؟ ' + widget.selecteds[0].front
                : widget.selecteds[0].front + 'را حذف می کنید؟ ')
            : CardsPage.replaceWithArabicNumbers(
                widget.selecteds.length.toString() + ' آیتم را حذف می کنید؟ ')),
        positiveAction: () {
      for (litBox.Card w in widget.selecteds) {
        _deleteCard(w);
      }
      fetchCards();
      widget.deleteMode = false;
      widget.selectMode = false;
      widget.selecteds = [];
      widget.editAppbar(
          widget.deleteMode,
          widget.editMode,
          widget.selectMode,
          widget.selecteds,
          widget.copyMode,
          widget.moveMode,
          widget.isSidebarCollapsed);
    }, neutralAction: () {
      widget.deleteMode = false;
      widget.selectMode = false;
      widget.selecteds = [];
      widget.editAppbar(
          widget.deleteMode,
          widget.editMode,
          widget.selectMode,
          widget.selecteds,
          widget.copyMode,
          widget.moveMode,
          widget.isSidebarCollapsed);
    });
  }

  // is all words of this string english?
  bool isEnglish(String s) {
    int n = s.codeUnitAt(0);
    if (n > 23 && n < 127) {
      return true;
    }
    return false;
  }

  // go to edit page
  _navigateToDetail(BuildContext context, litBox.Card card) async {
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => AddOrEditCard(
                  widget.categoryId,
                  card: card,
                )))
        .then((value) {
      fetchCards();
    });
    // update appbar
    widget.editAppbar(
        widget.deleteMode,
        widget.editMode,
        widget.selectMode,
        widget.selecteds,
        widget.copyMode,
        widget.moveMode,
        widget.isSidebarCollapsed);
  }

  _deleteCard(litBox.Card card) {
    litBox.CardDBHelper.instance.deleteCard(card.id, widget.categoryId);
    fetchCards();
    widget.editAppbar(
        widget.deleteMode,
        widget.editMode,
        widget.selectMode,
        widget.selecteds,
        widget.copyMode,
        widget.moveMode,
        widget.isSidebarCollapsed);
  }
}
