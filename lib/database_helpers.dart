import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:english_words/english_words.dart';

final String tableNames = 'names';
final String columnId = '_id';
final String columnFirst = 'first';
final String columnSecond = 'second';

class Name {
  int id;
  String first;
  String second;

  Name();

  Name.fromWordPair(WordPair pair) {
    id = null;
    first = pair.first;
    second = pair.second;
  }

  Name.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    first = map[columnFirst];
    second = map[columnSecond];
  }

  WordPair toWordPair() {
    return WordPair(first, second);
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{columnFirst: first, columnSecond: second};
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }
}

class DatabaseHelper {
  static final _databaseName = 'StartupNames.db';
  static final _databaseVersion = 1;

  // singleton instance
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
              CREATE TABLE $tableNames (
                $columnId INTEGER PRIMARY KEY,
                $columnFirst TEXT NOT NULL,
                $columnSecond TEXT NOT NULL
              )
              ''');
  }

  Future<int> insert(Name name) async {
    Database db = await database;
    int id = await db.insert(tableNames, name.toMap());
    return id;
  }

  Future<Name> queryName(int id) async {
    Database db = await database;
    List<Map> maps = await db.query(tableNames,
        columns: [columnId, columnFirst, columnSecond],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return Name.fromMap(maps.first);
    }
    return null;
  }

  Future<Iterable<Name>> queryAllNames() async {
    Database db = await database;
    List<Map> maps = await db
        .query(tableNames, columns: [columnId, columnFirst, columnSecond]);
    return maps.map<Name>((map) => Name.fromMap(map));
  }

  Future<bool> deleteName(String first, String second) async {
    Database db = await database;
    int rowsAffected = await db.delete(tableNames,
        where: '$columnFirst = ? AND $columnSecond = ?',
        whereArgs: [first, second]);
    return rowsAffected == 1;
  }

  Future<bool> deleteNameById(int id) async {
    Database db = await database;
    int rowsAffected =
        await db.delete(tableNames, where: '$columnId = ?', whereArgs: [id]);
    return rowsAffected == 1;
  }
}
