import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class DBUtil {
  final String DB_NAME = 'easy-upload.db';
  final String SQL_CREATE_TABLE_TASK = ''
      'CREATE TABLE task ('
        'id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'name TEXT, '
        'total_size INTEGER DEFAULT 0, '
        'transferred_size INTEGER DEFAULT 0, '
        'state INTEGER DEFAULT 0, '
        'thumbnail_url TEXT'
      ')';

  Database db;

  DBUtil() {
    _getDB();
  }

  _getDBPath() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, DB_NAME);
    return path;
  }

  Future<Database> _getDB() async {
    String path = await _getDBPath();
    if (db == null) {
      db = await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
        await db.execute(SQL_CREATE_TABLE_TASK);
      });
    }
    return db;
  }

  // 返回insert后返回的id值
  Future<int> insert(String sql) async {
    Database db = await _getDB();
    int id;
    await db.transaction((txn) async {
      id = await txn.rawInsert(sql);
    });
    return id;
  }

  // 返回更新的记录数
  Future<int> update(String sql) async {
    Database db = await _getDB();
    int count = await db.rawUpdate(sql);
    return count;
  }

  // 查询
  Future<List<Map>> query(String sql) async {
    Database db = await _getDB();
    List<Map> list = await db.rawQuery(sql);
    print('list = $list');
    return list;
  }
}