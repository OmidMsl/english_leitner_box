import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// word model
class Word {
  static const String TABLENAME = "word";

  int id;
  String word, translation;
  DateTime lastReview;
  bool isLastReviewSuessful;

  Word(
      {this.id,
      this.word,
      this.translation,
      this.lastReview,
      this.isLastReviewSuessful});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'translation': translation,
      'lastReview':
          lastReview == null ? null : lastReview.millisecondsSinceEpoch,
      'isLastReviewSuessful':
          isLastReviewSuessful == null ? 0 : isLastReviewSuessful ? 1 : 0
    };
  }
}

// word database helper
class WordDBHelper {
  //Create a private constructor
  WordDBHelper._();

  static const databaseName = 'leitner_database.db';
  static final WordDBHelper instance = WordDBHelper._();
  static Database _database;

  Future<Database> get database async {
    if (_database == null) {
      return await initializeDatabase();
    }
    return _database;
  }

  initializeDatabase() async {
    return await openDatabase(join(await getDatabasesPath(), databaseName),
        version: 1, onCreate: (Database db, int version) async {
      await db.execute(
          "CREATE TABLE word(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, word VARCHAR NOT NULL" +
              ", translation VARCHAR NOT NULL, lastReview INTEGER, isLastReviewSuessful INTEGER)");
    });
  }

  insertWord(Word word) async {
    final db = await database;
    var res = await db.insert(Word.TABLENAME, word.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  Future<List<Word>> retrieveWords() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(Word.TABLENAME);

    return List.generate(maps.length, (i) {
      var lr = maps[i]['lastReview'];
      var ilr = maps[i]['isLastReviewSuessful'];
      return Word(
        id: maps[i]['id'],
        word: maps[i]['word'],
        translation: maps[i]['translation'],
        lastReview: lr == null ? null : DateTime.fromMillisecondsSinceEpoch(lr),
        isLastReviewSuessful: ilr == null ? null : ilr == 1,
      );
    });
  }

  Future<List<Word>> isUnique(int id, String name) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(Word.TABLENAME,
        where: 'word = ? AND id <> ?', whereArgs: [name, id]);

    return List.generate(maps.length, (i) {
      var lr = maps[i]['lastReview'];
      var ilr = maps[i]['isLastReviewSuessful'];
      return Word(
        id: maps[i]['id'],
        word: maps[i]['word'],
        translation: maps[i]['translation'],
        lastReview: lr == null ? null : DateTime.fromMillisecondsSinceEpoch(lr),
        isLastReviewSuessful: ilr == null ? null : ilr == 1,
      );
    });
  }

  Future<DateTime> getLastReview() async {
    final db = await database;
    final List<Map<String, dynamic>> result =
        await db.rawQuery('SELECT MAX(lastReview) as lr FROM word');

    if (result.length > 0) {
      return DateTime.fromMillisecondsSinceEpoch(result[0]['lr']);
    }
    return null;
  }

  updateWord(Word word) async {
    final db = await database;

    await db.update(Word.TABLENAME, word.toMap(),
        where: 'id = ?',
        whereArgs: [word.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  deleteWord(int id) async {
    var db = await database;
    db.delete(Word.TABLENAME, where: 'id = ?', whereArgs: [id]);
  }
}
