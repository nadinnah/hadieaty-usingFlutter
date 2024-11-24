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
    String path = join(mypath, 'myDataBasess.db');
    Database mydb = await openDatabase(path, version: Version,
        onCreate: (db, Version) async {

          await db.execute(''' CREATE TABLE IF NOT EXIST 'Users'(
          'id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          'name' TEXT NOT NULL,
          'email' TEXT NOT NULL,
          'preferences' TEXT  
          )
          ''');

          await db.execute(''' CREATE TABLE IF NOT EXIST 'Events'(
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

//CRUD OPERATIONS
// CREATE/INSERT

//Users: Add user profile information locally during the app setup or when the user updates their profile.
// Events: Save new events created by the user.
// Gifts: Save new gifts that are added to a gift list.
// Friends: Add friends manually or from the contact list.

// READ
//Users: Fetch user profile details for the profile page.
// Events: Fetch all events for the event list and filter them by upcoming/current/past status.
// Gifts: Retrieve gifts associated with an event, especially when viewing a friend’s or the user’s gift list.
// Friends: Fetch the list of friends to display on the home page.

//UPDATE
//Users: Update user profile settings or preferences.
// Events: Modify event details, such as location, date, or description.
// Gifts: Update gift details like status (from available to pledged), description, or price.
// Friends: Update friendship-related data if needed, though generally, friends’ information remains stable.

//DELETE
//Users: If the user logs out, optionally clear their profile data locally.
// Events: Delete past or irrelevant events if the user chooses to remove them.
// Gifts: Delete gifts that are no longer part of a list or are unwanted.
// Friends: Remove friends from the friend list if the user chooses to do so.

}