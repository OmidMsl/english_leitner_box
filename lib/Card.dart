import 'package:english_leitner_box/DBHelper.dart';
import 'package:sqflite/sqflite.dart';

// card model
class Card {
  static const String TABLENAME = "card";

  int id, boxLocation = 0;
  String front, back;
  DateTime lastReview;

  Card({this.id, this.front, this.back, this.lastReview, this.boxLocation});

  Map<String, dynamic> toMap(int categoryId) {
    return {
      'id': id,
      'front': front,
      'back': back,
      'lastReview':
          lastReview == null ? null : lastReview.millisecondsSinceEpoch,
      'categoryId': categoryId,
      'boxLocation': boxLocation
    };
  }

  factory Card.fromJson(Map<String, dynamic> json) {
    return Card(
      front: json['front'] as String,
      back: json['back'] as String,
      id: json['categoryId'] as int,
    );
  }
}

// card database helper
class CardDBHelper {
  //Create a private constructor
  CardDBHelper._();
  static final CardDBHelper instance = CardDBHelper._();
  insertCard(Card card, int categoryId) async {
    final db = await DBHelper.instance.database;
    var res = await db.insert(Card.TABLENAME, card.toMap(categoryId),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  Future<List<Card>> retrieveCards(int categoryId) async {
    final db = await DBHelper.instance.database;

    final List<Map<String, dynamic>> maps = await db.query(Card.TABLENAME,
        where: 'categoryId = ?', whereArgs: [categoryId]);

    return List.generate(maps.length, (i) {
      var lr = maps[i]['lastReview'];
      var ilr = maps[i]['isLastReviewSuessful'];
      return Card(
        id: maps[i]['id'],
        front: maps[i]['front'],
        back: maps[i]['back'],
        lastReview: lr == null ? null : DateTime.fromMillisecondsSinceEpoch(lr),
        boxLocation: maps[i]['boxLocation'],
      );
    });
  }

  Future<List<Card>> isUnique(int id, String name, int categoryId) async {
    final db = await DBHelper.instance.database;

    final List<Map<String, dynamic>> maps = await db.query(Card.TABLENAME,
        where: 'front = ? AND categoryId = ? AND id <> ?',
        whereArgs: [name, categoryId, id]);

    return List.generate(maps.length, (i) {
      var lr = maps[i]['lastReview'];
      var ilr = maps[i]['isLastReviewSuessful'];
      return Card(
        id: maps[i]['id'],
        front: maps[i]['front'],
        back: maps[i]['back'],
        lastReview: lr == null ? null : DateTime.fromMillisecondsSinceEpoch(lr),
        boxLocation: maps[i]['boxLocation'],
      );
    });
  }

  Future<DateTime> getLastReview(int categoryId) async {
    final db = await DBHelper.instance.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT MAX(lastReview) as lr FROM card WHERE categoryId = $categoryId');

    if (result.length > 0) {
      return DateTime.fromMillisecondsSinceEpoch(result[0]['lr']);
    }
    return null;
  }

  updateCard(Card card, int categoryId) async {
    final db = await DBHelper.instance.database;

    await db.update(Card.TABLENAME, card.toMap(categoryId),
        where: 'id = ?',
        whereArgs: [card.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  deleteCard(int id, int categoryId) async {
    var db = await DBHelper.instance.database;
    db.delete(Card.TABLENAME,
        where: 'id = ? AND categoryId = ?', whereArgs: [id, categoryId]);
  }
}
