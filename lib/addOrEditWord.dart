import 'package:english_leitner_box/Word.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// this page is for creating or editing a word
class AddOrEditWord extends StatefulWidget {
  Word word;
  AddOrEditWord({this.word});
  @override
  _AddOrEditWordState createState() => _AddOrEditWordState();
}

class _AddOrEditWordState extends State<AddOrEditWord> {
  bool upDirection = true, flag = true, _extendFab = true;
  ScrollController _scrollController;
  BuildContext scaffoldContext;

  final wordTextController = TextEditingController();
  final translationTextController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.word != null) { // edit mode
      wordTextController.text = widget.word.word;
      translationTextController.text = widget.word.translation;
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
    wordTextController.dispose();
    translationTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          backgroundColor: Colors.pink,
          appBar: AppBar(
            title: Text(widget.word == null ? ("کلمه جدید") : 'ویرایش کلمه',
                style: TextStyle(color: Colors.black54, fontFamily: "Vazir")),
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
            return SingleChildScrollView( // make page scrollable
              controller: _scrollController,
              child: Container(
                color: Colors.pink,
                child: Card(
                  margin: EdgeInsets.all(10),
                  color: Colors.white,
                  shape: RoundedRectangleBorder( // rouding edges of the page
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, bottom: 16, top: 25),
                        child: TextField( // text field for english word
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "(کلمه (انگلیسی"),
                          maxLines: 1,
                          controller: wordTextController,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 16, left: 16, right: 16, bottom: 25),
                        child: TextField( // text field for translation of the word
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "(ترجمه (فارسی یا انگلیسی"),
                          maxLines: 1,
                          controller: translationTextController,
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
                  onPressed: saveWord(),
                  backgroundColor: Colors.green,
                  label: Text("ذخیره",
                      style: TextStyle(fontSize: 14, fontFamily: "Vazir")),
                  icon: Icon(Icons.save))
              : FloatingActionButton(
                  onPressed: saveWord(),
                  backgroundColor: Colors.green,
                  child: Icon(Icons.save))),
    );
  }

  // saving into database
  Function saveWord() {
    return () async {
      if (wordTextController.text.trim() == "") // when the word is not valid
        createSnackBar('.لطفا کلمه را وارد کنید');
      else if (translationTextController.text.trim() == "") // when the translation is not valid
        createSnackBar('.لطفا ترجمه را وارد کنید');
      else {
        if (widget.word == null) { // if create mode
          // check if the word dosent entered before
          Future f =
              WordDBHelper.instance.isUnique(-1, wordTextController.text);
          bool unique = true;
          await f.then((value) {
            unique = (value.toString() == '[]');
          });
          if (!unique)
            createSnackBar('.کلمه وارد شده تکراری است');
          else { // if word is valid inserts the word
            Word w = Word(
              word: wordTextController.text,
              translation: translationTextController.text,
            );
            WordDBHelper.instance.insertWord(w);
            Navigator.pop(context, w);
          }
        } else { //if edit mode
          Future f = WordDBHelper.instance
              .isUnique(widget.word.id, wordTextController.text);
          bool unique = true;
          await f.then((value) {
            unique = (value.toString() == '[]');
          });
          if (!unique)
            createSnackBar('.کلمه وارد شده تکراری است');
          else { // if word is valid updates the word
            Word w = Word(
                id: widget.word.id,
                word: wordTextController.text,
                translation: translationTextController.text);
            WordDBHelper.instance.updateWord(w);
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
