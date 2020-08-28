import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  //Create a private constructor
  DBHelper._();

  static const databaseName = 'leitner_database.db';
  static final DBHelper instance = DBHelper._();
  static Database _database;

  Future<Database> get database async {
    if (_database == null) {
      return await initializeDatabase();
    }
    return _database;
  }

  Future onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  initializeDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), databaseName),
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
            "CREATE TABLE category(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name VARCHAR NOT NULL, " +
                "timeLimit INTEGER, ttsEnable INTEGER, writeMode INTEGER, shuffle INTEGER, rate REAL, " +
                "volume REAL, pitch REAL)");
        await db.execute(
            "CREATE TABLE card(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, front VARCHAR NOT NULL" +
                ", back VARCHAR NOT NULL, lastReview INTEGER, boxLocation INTEGER" +
                ", categoryId INTEGER NOT NULL, FOREIGN KEY (categoryId) REFERENCES category(id) ON DELETE CASCADE)");
      },
      onConfigure: (db) => onConfigure(db),
    );
  }
}
