import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';


class DBProvider {
  final _databaseName = "MyDatabase.db";
  final _databaseVersion = 1;

  static final table = 'score_table'; // テーブル名

  static final columnId = '_id'; // 列1
  static final columnScore = 'score'; // 列2
  static final columnCreatedAt = 'created_at'; // 列3

  // DBProviderクラスをシングルトンにするためのコンストラクタ
  DBProvider._privateConstructor();
  static final DBProvider instance = DBProvider._privateConstructor();

  // DBにアクセスするためのメソッド
  // 宣言後に初期化されるnon-nullable変数の宣言
  static  Database _database;
  Future<Database> get database async {
    _database = await _initDatabase();
    return _database;
  }

  // データベースを開く。データベースがない場合は作る関数
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory(); // アプリケーション専用のファイルを配置するディレクトリへのパスを返す
    String path = join(documentsDirectory.path, _databaseName);
    // pathのDBを開く。なければonCreate
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // DBを作成するメソッド
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnScore TEXT NOT NULL,
            $columnCreatedAt TEXT NOT NULL
          )
          ''');
  }

  // 挿入
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database; //DBにアクセスする
    return await db.insert(table, row); //テーブルにマップ型のものを挿入。追加時のrowIDを返り値にする
  }

  // 全件取得
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database; //DBにアクセスする
    return await db.query(table); //全件取得
  }
  // 全件取得2
  Future<List<Map>> queryAllRows2() async {
    Database db = await instance.database; //DBにアクセスする
    return await db.rawQuery('SELECT * FROM ${table}');
  }
  // // データ件数取得
  // Future<int> queryRowCount() async {
  //   Database db = await instance.database; //DBにアクセスする
  //   return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
  // }

  // 更新
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database; //DBにアクセスする
    int id = row[columnId]; //引数のマップ型のcolumnIDを取得
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // 削除
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}