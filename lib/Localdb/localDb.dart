import 'dart:io';
import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class LocalDatabase {
  static Database? _MyDataBase;

  Future<Database?> get MyDataBase async {
    if (_MyDataBase == null) {
      _MyDataBase = await initialize();
      return _MyDataBase;
    } else {
      return _MyDataBase;
    }
  }

  int Version=1;

  initialize() async {
    String mypath = await getDatabasesPath();
    String path = join(mypath, 'myDataBasesss.db');
    Database mydb = await openDatabase(path, version: Version,
        onCreate: (db, Version) async {

          await db.execute('''CREATE TABLE Users (
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          preferences TEXT,
          password TEXT NOT NULL,
          role INTEGER NOT NULL DEFAULT 0,
          profilePic TEXT,
          number INTEGER NOT NULL
          )
          ''');
          //role 0 for regular user, 1 for admin

          await db.execute(''' CREATE TABLE IF NOT EXISTS 'Events'(
          'id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          'name' TEXT NOT NULL,
          'date' TEXT NOT NULL,
          'location' TEXT NOT NULL,
          'description' TEXT,
          'userId' INTEGER NOT NULL,
          FOREIGN KEY (userId) REFERENCES Users (id)
          )
          ''');

          await db.execute('''CREATE TABLE IF NOT EXISTS Gifts (
          'id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          'name' TEXT NOT NULL,
          'description' TEXT,
          'category' TEXT,
          'price' REAL,
          'status' TEXT,
          'eventId' INTEGER NOT NULL,
          FOREIGN KEY (eventId) REFERENCES Events (id)
          )''');

          await db.execute('''CREATE TABLE IF NOT EXISTS Friends (
          'userId' INTEGER NOT NULL,
          'friendId' INTEGER NOT NULL,
          PRIMARY KEY (userId, friendId),
          FOREIGN KEY (userId) REFERENCES Users (id),
          FOREIGN KEY (friendId) REFERENCES Users (id)
          )
          ''');

          print("The databases have been created .......");
        });
    return mydb;
  }

  readData(String SQL) async {
    Database? mydata = await MyDataBase;
    var response = await mydata!.rawQuery(SQL);
    return response;
  }

  insertData(String SQL) async {
    Database? mydata = await MyDataBase;
    int response = await mydata!.rawInsert(SQL);
    return response;
  }

  deleteData(String SQL) async {
    Database? mydata = await MyDataBase;
    int response = await mydata!.rawDelete(SQL);
    return response;
  }

  updateData(String SQL) async {
    Database? mydata = await MyDataBase;
    int response = await mydata!.rawUpdate(SQL);
    return response;
  }

  // Fetch users who are not admins
  Future<List<Map<String, dynamic>>> getNonAdminUsers() async {
    Database? mydata = await MyDataBase;
    String sql = "SELECT * FROM Users WHERE role != 1"; // Get users who are not admins
    var result = await mydata!.rawQuery(sql);
    return result;
  }

  // Fetch friends of the current user (you can customize this based on your needs)
  Future<List<Map<String, dynamic>>> getFriends(int userId) async {
    Database? mydata = await MyDataBase;
    String sql = '''
      SELECT U.name, U.profilePic, U.number
      FROM Users U
      JOIN Friends F ON U.id = F.friendId
      WHERE F.userId = $userId
    ''';
    var result = await mydata!.rawQuery(sql);
    return result;
  }

}
