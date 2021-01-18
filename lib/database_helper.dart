import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseEntry {
  DatabaseEntry({this.id, this.data});

  final String id;
  final String data;

  Map<String, dynamic> toMap() {
    return {
      'data': data,
      'id': id,
    };
  }
}

class DatabaseHelper {
  DatabaseHelper(
      this.eventTableName, this.colorTableName, this.settingsTableName);

  static const databaseName = 'calendar_database.db';
  final String eventTableName;
  final String colorTableName;
  final String settingsTableName;
  static Database _database;

  Future<Database> get database async {
    if (_database == null) {
      return await initializeDatabase();
    }
    return _database;
  }

  initializeDatabase() async {
    var path =
        join((await getApplicationDocumentsDirectory()).path, databaseName);
//    deleteDatabase(path);
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          "CREATE TABLE $eventTableName (id TEXT PRIMARY KEY NOT NULL, data TEXT)");
      await db.execute(
          "CREATE TABLE $colorTableName (id TEXT PRIMARY KEY NOT NULL, data TEXT)");
      await db.execute(
          "CREATE TABLE $settingsTableName (id TEXT PRIMARY KEY NOT NULL, data TEXT)");
    });
  }

  addEntry(DatabaseEntry entry, String tableName) async {
    final db = await database;
    var res = await db.insert(tableName, entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  Future<List<DatabaseEntry>> getEntry(String tableName) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(tableName);

    return List.generate(maps.length, (i) {
      return DatabaseEntry(
        data: maps[i]['data'],
        id: maps[i]['id'],
      );
    });
  }

  updateEntry(DatabaseEntry entry, String tableName) async {
    final db = await database;

    await db.update(tableName, entry.toMap(),
        where: 'id = ?',
        whereArgs: [entry.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  deleteEntry(String id, String tableName) async {
    var db = await database;
    db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  removeTable(String tableName) async {
    var db = await database;
    await db.rawQuery('DELETE FROM ' + tableName);
    return db;
  }
}
