import 'package:english_leitner_box/Card.dart' as litBox;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// this page is for creating or editing a card
class AddOrEditCard extends StatefulWidget {
  litBox.Card card;
  int categoryId;
  AddOrEditCard(this.categoryId, {this.card});
  @override
  _AddOrEditCardState createState() => _AddOrEditCardState();
}

class _AddOrEditCardState extends State<AddOrEditCard> {
  // for manage scroll of screen
  bool upDirection = true, flag = true, _extendFab = true;
  ScrollController _scrollController;

  // BuildContext for creating snakpar
  BuildContext scaffoldContext;

  //text controller for text fields
  final frontTextController = TextEditingController();
  final backTextController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.card != null) {
      // edit mode
      frontTextController.text = widget.card.front;
      backTextController.text = widget.card.back;
    }
    // to extend floating action button after scrolling down
    _scrollController = ScrollController()
      ..addListener(() {
        upDirection = _scrollController.position.userScrollDirection ==
            ScrollDirection.forward;

        // makes sure we don't call setState too much, but only when it is needed
        if (upDirection != flag)
          setState(() {
            _extendFab = !_extendFab;
          });

        flag = upDirection;
      });
  }

  @override
  void dispose() {
    super.dispose();
    frontTextController.dispose();
    backTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          backgroundColor: Colors.pink,
          appBar: AppBar(
            title: Text(widget.card == null ? ("کارت جدید") : 'ویرایش کارت',
                style: TextStyle(color: Colors.black54, fontFamily: "Homa")),
            centerTitle: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black54,
              ),
              onPressed: () {
                Navigator.of(context).pop(context);
              },
            ),
          ),
          body: new Builder(builder: (BuildContext context) {
            scaffoldContext = context;
            return SingleChildScrollView(
              // make page scrollable
              controller: _scrollController,
              child: Container(
                color: Colors.pink,
                child: Card(
                  margin: EdgeInsets.all(10),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      // rouding edges of the page
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, bottom: 16, top: 25),
                        child: TextField(
                          // text field for front of card
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "جلوی کارت"),
                          maxLines: 1,
                          controller: frontTextController,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 16, left: 16, right: 16, bottom: 25),
                        child: TextField(
                          // text field for behind of the card
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "پشت کارت"),
                          maxLines: 1,
                          controller: backTextController,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          floatingActionButton: _extendFab // fab
              ? FloatingActionButton.extended(
                  onPressed: saveCard(),
                  backgroundColor: Colors.green,
                  label: Text("ذخیره",
                      style: TextStyle(fontSize: 14, fontFamily: "Vazir")),
                  icon: Icon(Icons.save))
              : FloatingActionButton(
                  onPressed: saveCard(),
                  backgroundColor: Colors.green,
                  child: Icon(Icons.save))),
    );
  }

  // saving into database
  Function saveCard() {
    return () async {
      if (frontTextController.text.trim() == "") // when the card is not valid
        createSnackBar('.لطفا جلوی کارت را وارد کنید');
      else if (backTextController.text.trim() ==
          "") // when the translation is not valid
        createSnackBar('.لطفا پشت کارت را وارد کنید');
      else {
        if (widget.card == null) {
          // if create mode
          // check if the card dosent entered before
          Future f = litBox.CardDBHelper.instance
              .isUnique(-1, frontTextController.text.trim(), widget.categoryId);
          bool unique = true;
          await f.then((value) {
            unique = (value.toString() == '[]');
          });
          if (!unique)
            createSnackBar('.کارت وارد شده تکراری است');
          else {
            // if card is valid inserts the card
            litBox.Card c = litBox.Card(
                front: frontTextController.text,
                back: backTextController.text,
                boxLocation: 0);
            litBox.CardDBHelper.instance.insertCard(c, widget.categoryId);
            Navigator.pop(context, c);
          }
        } else {
          //if edit mode
          Future f = litBox.CardDBHelper.instance.isUnique(
              widget.card.id, frontTextController.text, widget.categoryId);
          bool unique = true;
          await f.then((value) {
            unique = (value.toString() == '[]');
          });
          if (!unique)
            createSnackBar('.کارت وارد شده تکراری است');
          else {
            // if card is valid updates the card
            litBox.Card w = litBox.Card(
                id: widget.card.id,
                front: frontTextController.text,
                back: backTextController.text);
            litBox.CardDBHelper.instance.updateCard(w, widget.categoryId);
            Navigator.pop(context, w);
          }
        }
      }
    };
  }

  void createSnackBar(String message) {
    final snackBar = new SnackBar(content: new Text(message));
    // Find the Scaffold in the Widget tree and use it to show a SnackBar!
    Scaffold.of(scaffoldContext).showSnackBar(snackBar);
  }
}
