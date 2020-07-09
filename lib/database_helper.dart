import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {

  static final _databaseName = "Database.db";
  static final _databaseVersion = 1;

  static final table_boughtlist = 'BoughtList';
  static final columnId = '_id';
  static final columnName = 'productName';
  static final columnStatus = 'status';
  static final columnBuyDate = 'buyDate';
  static final columnPrice = 'price';
  static final columnWarrantyPeriod = 'warrantyPeriod';
  static final columnNotes = 'Notes';

  static final table_categories = 'Categories';
  static final columnCateId = 'cateID';
  static final columnCateName = 'categoryName';
  static final columnCateInfo = 'categoryInfo';

  static final table_categoriesIcon = 'CategoriesIcon';

  static final table_sold = 'SoldList';
  static final columnSoldDate = 'soldDate';
  static final columnSoldPrice = 'soldPrice';

  static final table_lost = 'LostList';
  static final columnLostDate = 'lostDate';

  static final table_broken = 'BrokenList';
  static final columnBrokenDate = 'brokenDate';

  static final table_given = 'GivenList';
  static final columnGivenDate = 'givenDate';
  static final columnGivenTo = 'givenTo';

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  static Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
    debugPrint('Configure Database Completed');
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table_categories (
        $columnCateId INTEGER PRIMARY KEY,
        $columnCateName TEXT NOT NULL UNIQUE,
        $columnCateInfo TEXT NOT NULL
      )
    ''');
    await db.execute('''
          CREATE TABLE $table_boughtlist (
            $columnId INTEGER PRIMARY KEY,
            $columnCateId INTEGER NOT NULL, 
            $columnName TEXT NOT NULL,
            $columnStatus TEXT NOT NULL,
            $columnBuyDate TEXT NOT NULL,
            $columnPrice INTEGER NOT NULL,
            $columnWarrantyPeriod INTEGER,
            $columnNotes TEXT,
            FOREIGN KEY($columnCateId) REFERENCES $table_categories($columnCateId) ON DELETE CASCADE
          )
          ''');
    await db.execute('''
      CREATE TABLE $table_categoriesIcon (
        $columnCateId INTEGER,
        codePoint TEXT,
        fontFamily TEXT,
        fontPackage TEXT,
        matchTextDirection TEXT,
        FOREIGN KEY($columnCateId) REFERENCES $table_categories($columnCateId) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE $table_sold (
        $columnId INTEGER,
        $columnSoldDate TEXT NOT NULL,
        $columnSoldPrice INTEGER NOT NULL,
        FOREIGN KEY($columnId) REFERENCES $table_boughtlist($columnId) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE $table_lost (
        $columnId INTEGER,
        $columnLostDate TEXT NOT NULL,
        FOREIGN KEY($columnId) REFERENCES $table_boughtlist($columnId) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE $table_broken (
        $columnId INTEGER,
        $columnBrokenDate TEXT NOT NULL,
        FOREIGN KEY($columnId) REFERENCES $table_boughtlist($columnId) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE $table_given (
        $columnId INTEGER,
        $columnGivenDate TEXT NOT NULL,
        $columnGivenTo TEXT NOT NULL,
        FOREIGN KEY($columnId) REFERENCES $table_boughtlist($columnId) ON DELETE CASCADE
      )
    ''');
    debugPrint('Finished Initial Database Table');
  }

  Future _createCategoryTable(Database db, String tableName, List<String> columnName) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        $columnId INTEGER,
        $columnCateId INTEGER,
        FOREIGN KEY($columnId) REFERENCES $table_boughtlist($columnId) ON DELETE CASCADE,
        FOREIGN KEY($columnCateId) REFERENCES $table_categories($columnCateId) ON DELETE CASCADE
      )
    ''');
    for(int i = 0; i < columnName.length; i++){
      var name = columnName[i];
      try {
        await db.execute('''
        ALTER TABLE $tableName
          ADD $name TEXT;
      ''');
      } on DatabaseException catch (e) { debugPrint(e.toString()); }
    }
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> boughtInsert(int cateID, Map<String, dynamic> boughtListRow, Map<String, dynamic> categoryRow) async {
    Database db = await instance.database;
    var id = await db.insert(table_boughtlist, boughtListRow);
    var cateTable = await db.rawQuery('''
      SELECT $columnCateName
      FROM $table_categories
      WHERE $columnCateId = $cateID
    ''');
    debugPrint(cateTable.toString());
    Map<String, dynamic> forInsertToCategoryRow = {};
    forInsertToCategoryRow[columnId] = id;
    forInsertToCategoryRow[columnCateId] = cateID;
    for(int i = 0; i < categoryRow.length; i++){
      forInsertToCategoryRow[categoryRow.keys.elementAt(i)] = categoryRow.values.elementAt(i).text;
    }
    await db.insert(cateTable[0][columnCateName], forInsertToCategoryRow);
    return id;
  }

  Future<void> statusInsert(String status, int id, Map<String, dynamic> row) async {
    Database db = await instance.database;
    String statusTableName = statusToTableName(status);
    db.insert(statusTableName, row);
  }

  Future<String> categoryInsert(Map<String, dynamic> row, Map<String, dynamic> icon) async {
    Database db = await instance.database;
    try {
      var cateID = await db.insert(table_categories, row);
      Map<String, dynamic> iconRow = {
        columnCateId : cateID
      };
      if(icon != null) iconRow.addAll(icon);
      await db.insert(table_categoriesIcon, iconRow);
    } on DatabaseException catch (e) { debugPrint(e.toString()); }
    var _infoName = row[columnCateInfo].toString().split(',');
    await _createCategoryTable(db, row[columnCateName], _infoName);
    return row[columnCateName];
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    Database db = await instance.database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> boughtListQuery() async {
    Database db = await instance.database;
    return await db.rawQuery('''
      SELECT *
      FROM $table_boughtlist JOIN $table_categories USING ($columnCateId)
    ''');
  }

  Future<List<Map<String, dynamic>>> boughtItemStatusValueQuery(int itemID, String status) async {
    Database db = await instance.database;
    String statusTableName = statusToTableName(status);
    return await db.rawQuery('''
      SELECT *
      FROM $statusTableName
      WHERE $columnId == $itemID
    ''');
  }

  Future<List<Map<String, dynamic>>> boughtItemStaticValueQuery(int itemID) async {
    Database db = await instance.database;
    return await db.rawQuery('''
      SELECT *
      FROM $table_boughtlist
      WHERE $columnId == $itemID
    ''');
  }

  Future<List<Map<String, dynamic>>> boughtItemDynamicValueQuery(int itemID, String cateName) async {
    Database db = await instance.database;
    return await db.rawQuery('''
      SELECT *
      FROM $cateName
      WHERE $columnId = $itemID
    ''');
  }

  Future<List<Map<String, dynamic>>> queryByID(int id, String table) async {
    Database db = await instance.database;
    return await db.rawQuery('''
      SELECT $columnCateInfo
      FROM $table
      WHERE $columnCateId = $id
    ''');
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table_boughtlist'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  String statusToTableName(String status) {
    if(status == 'SOLD'){
      return table_sold;
    }else if(status == 'LOST'){
      return table_lost;
    }else if(status == 'BROKEN'){
      return table_broken;
    }else if(status == 'GIVEN'){
      return table_given;
    }else{
      return null;
    }
  }

  Future<void> updateStatus(String oldStatus, String status, int id, Map<String, dynamic> row) async {
    Database db = await instance.database;
    String statusTableName = statusToTableName(status);
    String oldStatusTableName = statusToTableName(oldStatus);

    debugPrint(oldStatusTableName);
    debugPrint(statusTableName);

    if(oldStatusTableName == null){
      await db.rawQuery('''
        UPDATE $table_boughtlist
        SET $columnStatus = '$status'
        WHERE $columnId = $id
      ''');
      await db.insert(statusTableName, row);
    }else{
      await db.rawQuery('''
          UPDATE $table_boughtlist
          SET $columnStatus = '$status'
          WHERE $columnId = $id
        ''');
      await db.delete(oldStatusTableName, where: '$columnId = ?', whereArgs: [id]);
      if(statusTableName != null){
        await db.insert(statusTableName, row);
      }
    }
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> boughtDelete(int id) async {
    Database db = await instance.database;
    return await db.delete(table_boughtlist, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> categoryDelete(int id) async {
    Database db = await instance.database;
    var cname = await db.rawQuery('''
      SELECT $columnCateName
      FROM $table_categories
      WHERE $columnCateId = $id
    ''');
    debugPrint(cname.toString());
    var cate_name = await cname[0][columnCateName];
    debugPrint(cate_name);
    try {
      await db.rawQuery('''
      DROP TABLE $cate_name;
    ''');
    } on DatabaseException catch (e) { debugPrint(e.toString()); }
//    await db.delete(table_categoriesIcon, where: '$columnCateId = ?', whereArgs: [id]);
    return await db.delete(table_categories, where: '$columnCateId = ?', whereArgs: [id]);
  }
}
