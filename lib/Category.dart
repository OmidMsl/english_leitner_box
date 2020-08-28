import 'package:english_leitner_box/DBHelper.dart';
import 'package:sqflite/sqflite.dart';

// Category model
class Category {
  static const String TABLENAME = "category";

  int id, timeLimit;
  String name;
  bool ttsEnable, writeMode, shuffle;
  double rate, volume, pitch;

  Category({
    this.id,
    this.name,
    this.timeLimit = -1,
    this.ttsEnable = true,
    this.writeMode = false,
    this.shuffle = true,
    this.rate = 0.5,
    this.volume = .05,
    this.pitch = 1.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'timeLimit': timeLimit,
      'ttsEnable': ttsEnable ? 1 : 0,
      'writeMode': writeMode ? 1 : 0,
      'shuffle': shuffle ? 1 : 0,
      'rate': rate,
      'volume': volume,
      'pitch': pitch,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      timeLimit: json['timeLimit'] as int,
      ttsEnable: (json['ttsEnable'] as int) == 1,
      writeMode: (json['writeMode'] as int) == 1,
      shuffle: (json['shuffle'] as int) == 1,
      rate: json['rate'] as double,
      volume: json['volume'] as double,
      pitch: json['pitch'] as double,
    );
  }
}

// category database helper
class CategoryDBHelper {
  //Create a private constructor
  CategoryDBHelper._();
  static final CategoryDBHelper instance = CategoryDBHelper._();
  Future<int> insertCategory(Category category) async {
    final db = await DBHelper.instance.database;
    var res = await db.insert(Category.TABLENAME, category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  Future<List<Category>> retrieveCategories() async {
    final db = await DBHelper.instance.database;

    final List<Map<String, dynamic>> maps = await db.query(Category.TABLENAME);

    return List.generate(maps.length, (i) {
      return Category(
        id: maps[i]['id'],
        name: maps[i]['name'],
        timeLimit: maps[i]['timeLimit'] as int,
        ttsEnable: (maps[i]['ttsEnable'] as int) == 1,
        writeMode: (maps[i]['writeMode'] as int) == 1,
        shuffle: (maps[i]['shuffle'] as int) == 1,
        rate: maps[i]['rate'] as double,
        volume: maps[i]['volume'] as double,
        pitch: maps[i]['pitch'] as double,
      );
    });
  }

  Future<List<Category>> isUnique(int id, String name) async {
    final db = await DBHelper.instance.database;

    final List<Map<String, dynamic>> maps = await db.query(Category.TABLENAME,
        where: 'name = ? AND id <> ?', whereArgs: [name, id]);

    return List.generate(maps.length, (i) {
      return Category(
        id: maps[i]['id'],
        name: maps[i]['name'],
        timeLimit: maps[i]['timeLimit'] as int,
        ttsEnable: (maps[i]['ttsEnable'] as int) == 1,
        writeMode: (maps[i]['writeMode'] as int) == 1,
        shuffle: (maps[i]['shuffle'] as int) == 1,
        rate: maps[i]['rate'] as double,
        volume: maps[i]['volume'] as double,
        pitch: maps[i]['pitch'] as double,
      );
    });
  }

  Future<int> getCategoryId(String name) async {
    final db = await DBHelper.instance.database;

    final List<Map<String, dynamic>> maps = await db
        .query(Category.TABLENAME, where: 'name = ?', whereArgs: [name]);

    return maps.isEmpty ? null : maps[0]['id'];
  }

  updateCategory(Category category) async {
    final db = await DBHelper.instance.database;

    await db.update(Category.TABLENAME, category.toMap(),
        where: 'id = ?',
        whereArgs: [category.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  deleteCategory(int id) async {
    var db = await DBHelper.instance.database;
    db.delete(Category.TABLENAME, where: 'id = ?', whereArgs: [id]);
  }
}
