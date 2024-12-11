import 'dart:io';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/event.dart';
import '../models/gift.dart';

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

  int Version = 1;

  // Initialize the database
  initialize() async {
    String mypath = await getDatabasesPath();
    String path = join(mypath, 'myDataBasess2.db');
    Database mydb = await openDatabase(path, version: Version,
        onCreate: (db, Version) async {

          // Users Table
          await db.execute('''
        CREATE TABLE IF NOT EXISTS Users (
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          preferences TEXT,
          password TEXT NOT NULL,
          isOwner INTEGER NOT NULL DEFAULT 0,  -- 0 for false, 1 for true
          profilePic TEXT,
          number INTEGER NOT NULL
        )
      ''');

          // Events Table
          await db.execute('''
        CREATE TABLE IF NOT EXISTS Events (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          date TEXT NOT NULL,
          location TEXT NOT NULL,
          category TEXT,
          description TEXT,
          userId INTEGER NOT NULL,
          FOREIGN KEY (userId) REFERENCES Users (id)
        )
      ''');

          // Gifts Table
          await db.execute('''
        CREATE TABLE IF NOT EXISTS Gifts (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT,
          category TEXT,
          price REAL,
          status TEXT,
          eventId INTEGER NOT NULL,
          FOREIGN KEY (eventId) REFERENCES Events (id)
        )
      ''');

          print("The databases have been created .......");
        });

    return mydb;
  }

  // Read data from the database
  readData(String SQL) async {
    Database? mydata = await MyDataBase;
    var response = await mydata!.rawQuery(SQL);
    return response;
  }
  Future<void> updateUserIsOwner(String email, int isOwnerValue) async {
    final db = await MyDataBase;

    await db!.update(
      'Users',
      {'isOwner': isOwnerValue}, // Set isOwner to the specified value
      where: 'email = ?',
      whereArgs: [email],
    );
  }//WORKS

  Future<String?> getUserNameByEmail(String email) async {
    final db = await MyDataBase;
    var result = await db!.query(
      'Users',
      columns: ['name'], // Only fetch the 'name' column
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return result.first['name'] as String; // Return the name
    }
    return null; // Return null if no user is found
  }
  // Insert data into the database
  insertData(String SQL) async {
    Database? mydata = await MyDataBase;
    int response = await mydata!.rawInsert(SQL);
    return response;
  }//WORKS

  // Delete data from the database
  deleteData(String SQL) async {
    Database? mydata = await MyDataBase;
    int response = await mydata!.rawDelete(SQL);
    return response;
  }

  // Update data in the database
  updateData(String SQL) async {
    Database? mydata = await MyDataBase;
    int response = await mydata!.rawUpdate(SQL);
    return response;
  }



  // Fetch events by userId
  Future<List<Map<String, dynamic>>> getEventsByUserId(int userId) async {
    Database? mydata = await MyDataBase;
    String sql = '''
      SELECT * FROM Events WHERE userId = $userId
    ''';
    var result = await mydata!.rawQuery(sql);
    return result;
  }



  // Fetch events and their associated gifts for the user
  Future<List<Map<String, dynamic>>> getEventsAndGiftsByUserId(int userId) async {
    Database? mydata = await MyDataBase;
    String sql = '''
      SELECT E.*, G.* FROM Events E
      LEFT JOIN Gifts G ON E.id = G.eventId
      WHERE E.userId = $userId
    ''';
    var result = await mydata!.rawQuery(sql);
    return result;
  }

  Future<int> insertUser(Map<String, dynamic> userData) async {
    final db = await MyDataBase; // Access the database instance
    return await db!.insert('Users', userData); // Insert the user data into the Users table
  }

//EVENTS:
  Future<int> insertEvent(Event event) async {
    final db = await MyDataBase;
    var result = await db!.insert(
      'Events',
      event.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return result; // This returns the generated ID for the new event
  }
  Future<List<Map<String, dynamic>>> getEvents() async {
    final db = await MyDataBase;  // Get the database instance
    var result = await db!.query('Events');  // Query the 'Events' table to fetch all events
    return result;  // Return the list of events as a list of maps
  }

  Future<int> updateEvent(Event event) async {
    final db = await MyDataBase;  // Get the database instance
    var result = await db!.update(
      'Events',  // Table to update
      event.toMap(),  // The data to update, converting Event to Map
      where: 'id = ?',  // The condition to match the event by its ID
      whereArgs: [event.id],  // The argument to use for the condition
    );
    return result;  // Returns the number of rows affected (1 if updated)
  }

  Future<int> deleteEvent(int eventId) async {
    final db = await MyDataBase;  // Get the database instance
    var result = await db!.delete(
      'Events',  // Table from which to delete the event
      where: 'id = ?',  // Condition to match the event by its ID
      whereArgs: [eventId],  // The ID of the event to delete
    );
    return result;  // Returns the number of rows affected (1 if deleted)
  }

  // Fetch all gifts for a specific event
  Future<List<Map<String, dynamic>>> getGiftsByEventId(int eventId) async {
    final db = await MyDataBase;
    return await db!.query('Gifts', where: 'eventId = ?', whereArgs: [eventId]);
  }

// Search gifts by name for a specific event
  Future<List<Map<String, dynamic>>> searchGifts(int eventId, String query) async {
    final db = await MyDataBase;
    String sql = 'SELECT * FROM Gifts WHERE eventId = ? AND name LIKE ?';
    return await db!.rawQuery(sql, [eventId, '%$query%']);
  }

// Insert a new gift
  Future<int> insertGift(Gift gift) async {
    final db = await MyDataBase;
    return await db!.insert('Gifts', gift.toMap());
  }

// Update an existing gift by ID
  Future<int> updateGift(int giftId, Gift gift) async {
    final db = await MyDataBase;
    return await db!.update(
      'Gifts',
      gift.toMap(),
      where: 'id = ?',
      whereArgs: [giftId],
    );
  }

// Delete a gift by ID
  Future<int> deleteGift(int giftId) async {
    final db = await MyDataBase;
    return await db!.delete(
      'Gifts',
      where: 'id = ?',
      whereArgs: [giftId],
    );
  }

// Update the status of a gift (pledged or available)
  Future<int> updateGiftStatus(int giftId, String newStatus) async {
    final db = await MyDataBase;
    return await db!.update(
      'Gifts',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [giftId],
    );
  }

// Fetch a gift by ID
  Future<Map<String, dynamic>?> getGiftById(int giftId) async {
    final db = await MyDataBase;
    var result = await db!.query(
      'Gifts',
      where: 'id = ?',
      whereArgs: [giftId],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
//USER:


// Fetch pledged gifts for a specific user (based on userId)
  Future<List<Map<String, dynamic>>> getPledgedGiftsByUserId(int userId) async {
    final db = await MyDataBase;
    return await db!.query('Gifts', where: 'status = ? AND eventId IN (SELECT id FROM Events WHERE userId = ?)', whereArgs: ['pledged', userId]);
  }


//USER

  // Fetch user by id
  Future<Map<String, dynamic>> getUserById(int userId) async {
    final db = await MyDataBase;
    var result = await db!.query(
      'Users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty ? result.first : {};
  }

  // Update user field (name, email, notifications, etc.)
  Future<void> updateUserField(int userId, String field, String value) async {
    final db = await MyDataBase;
    await db!.update(
      'Users',
      {field: value},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Update notification preference
  Future<void> updateUserNotifications(int userId, bool value) async {
    final db = await MyDataBase;
    await db!.update(
      'Users',
      {'notifications': value ? 1 : 0},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }


// Fetch user by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await MyDataBase;
    var result = await db!.query(
      'Users',
      where: 'email = ?', // Filter by email
      whereArgs: [email],
    );
    if (result.isNotEmpty) {
      return result.first; // Return the first matching result
    }
    return null; // Return null if no user is found
  }

  Future<void> deleteOldDatabase() async {
    String mypath = await getDatabasesPath();
    String path = join(mypath, 'myDataBasess1.db');

    // Delete the database file
    if (await databaseExists(path)) {
      await deleteDatabase(path);
      print("Old database deleted successfully.");
    } else {
      print("Database does not exist, no need to delete.");
    }
  }

}
