import 'dart:io';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add Firebase Auth dependency

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

  Future<void> deleteOldDatabase() async {
    String mypath = await getDatabasesPath();
    String path = join(mypath, 'myDataBase11.db');

    // Delete the database file
    if (await databaseExists(path)) {
      await deleteDatabase(path);
      print("Old database deleted successfully.");
    } else {
      print("Database does not exist, no need to delete.");
    }
  }

  // Initialize the database
  initialize() async {
    String mypath = await getDatabasesPath();
    String path = join(mypath, 'myDataBase12.db');
    Database mydb = await openDatabase(path, version: Version, onCreate: (db, Version) async {
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
          firebaseId TEXT,
          name TEXT NOT NULL,
          date TEXT NOT NULL,
          location TEXT NOT NULL,
          description TEXT,
          createdBy TEXT,  -- Keep 'createdBy' column for the Firebase UID
          status TEXT,
          category TEXT,
          syncStatus TEXT NOT NULL DEFAULT '0',
          createdAt TEXT,
          FOREIGN KEY (createdBy) REFERENCES Users (id)  -- Referencing the user via createdBy
      );
    ''');

      // Gifts Table
      await db.execute('''
      CREATE TABLE IF NOT EXISTS Gifts (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        category TEXT,
        price REAL,
        imageUrl TEXT,
        status TEXT,
        eventId INTEGER NOT NULL,
        syncStatus TEXT NOT NULL DEFAULT 'unsynced',
        FOREIGN KEY (eventId) REFERENCES Events (id)
      )
    ''');

      print("Database initialized.");
    });

    return mydb;
  }


  // Read data from the database
  readData(String SQL) async {
    Database? mydata = await MyDataBase;
    var response = await mydata!.rawQuery(SQL);
    return response;
  }

  Future<List<Map<String, dynamic>>> getEventsByUserId(String userId) async {
    final db = await MyDataBase;
    return await db!.query(
      'Events',
      where: 'createdBy = ?', // Correct condition
      whereArgs: [userId],
    );
  }



  // Insert user
  Future<int> insertUser(Map<String, dynamic> userData) async {
    final db = await MyDataBase;
    return await db!.insert('Users', userData);
  }

  Future<bool> addEventForLoggedInUser(Event event) async {
    try {
      // Fetch the logged-in user's Firestore UID
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null || userId.isEmpty) {
        throw Exception("User is not logged in or UID is unavailable.");
      }

      // Convert the Event object to a map for insertion, adding `userId` to the data
      Map<String, dynamic> eventData = event.toMap();
      eventData['userId'] = userId; // Add userId to the event data for database storage

      // Insert the event into the local SQLite database
      await insertEventWithUserId(eventData); // This method handles the actual insertion
      print("Event '${event.name}' added locally for user: $userId");

      return true; // Successfully added event
    } catch (e) {
      print("Error adding event for logged-in user: $e");
      return false; // Indicate failure to add event
    }
  }


  Future<int> insertEventWithUserId(Map<String, dynamic> eventData) async {
    final db = await MyDataBase;
    return await db!.insert(
      'Events', // Table name
      eventData, // Data including userId
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  Future<void> updateUserIsOwner(String email, int isOwnerValue) async {
    final db = await MyDataBase;

    await db!.update(
      'Users',
      {'isOwner': isOwnerValue}, // Set isOwner to the specified value
      where: 'email = ?',
      whereArgs: [email],
    );
  } //WORKS

  String getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  Future<List<Map<String, dynamic>>> getUnsyncedEvents(String userId) async {
    final db = await MyDataBase;
    return await db!.query(
      'Events',
      where: 'syncStatus = ? AND userId = ?',
      whereArgs: ['unsynced', userId],
    );
  }

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
  } //WORKS

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

  // Fetch events and their associated gifts for the user
  Future<List<Map<String, dynamic>>> getEventsAndGiftsByUserId(
      int userId) async {
    Database? mydata = await MyDataBase;
    String sql = '''
      SELECT E.*, G.* FROM Events E
      LEFT JOIN Gifts G ON E.id = G.eventId
      WHERE E.userId = $userId
    ''';
    var result = await mydata!.rawQuery(sql);
    return result;
  }

//EVENTS:
  Future<int> insertEvent(Event event) async {
    final db = await MyDataBase;
    var result = await db!.insert(
      'Events',
      event.toMap(),  // Insert the event, firebaseId will be null initially
      conflictAlgorithm: ConflictAlgorithm.replace,  // Replace if already exists
    );
    return result;  // Return the ID of the inserted event
  }

  Future<int> updateEvent(Event event) async {
    final db = await MyDataBase;
    return await db!.update(
      'Events',
      {
        'syncStatus': event.syncStatus ? 1 : 0,
        'firebaseId': event.firebaseId, // Store Firestore ID
      },
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }



  Future<int> deleteEvent(int eventId) async {
    final db = await MyDataBase;
    return await db!.delete(
      'Events',
      where: 'id = ?',
      whereArgs: [eventId],
    );
  }


  // Fetch all gifts for a specific event
  Future<List<Map<String, dynamic>>> getGiftsByEventId(int eventId) async {
    final db = await MyDataBase;
    return await db!.query('Gifts', where: 'eventId = ?', whereArgs: [eventId]);
  }

// Search gifts by name for a specific event
  Future<List<Map<String, dynamic>>> searchGifts(
      int eventId, String query) async {
    final db = await MyDataBase;
    String sql = 'SELECT * FROM Gifts WHERE eventId = ? AND name LIKE ?';
    return await db!.rawQuery(sql, [eventId, '%$query%']);
  }

// Insert a new gift
  Future<int> insertGift(Gift gift) async {
    final db = await MyDataBase;
    return await db!.insert('Gifts', gift.toMap());
  }

  Future<int> updateTheGift(int giftId, Gift gift) async {
    final db =
        await MyDataBase; // Make sure this is correctly referring to your database
    return await db!.update(
      'Gifts', // Table name
      gift.toMap(), // The map of the gift to update
      where: 'id = ?', // Condition to find the correct gift by id
      whereArgs: [giftId], // Arguments to substitute for the '?' placeholder
    );
  }

// Delete a gift by ID
  Future<int> deleteGift(int giftId) async {
    final db = await MyDataBase;
    return await db!.delete(
      'Gifts', // Table from which to delete the gift
      where: 'id = ?', // Condition to match the gift by its ID
      whereArgs: [giftId], // The ID of the gift to delete
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

// Fetch pledged gifts for a specific user (based on userId)
  Future<List<Map<String, dynamic>>> getPledgedGiftsByUserId(int userId) async {
    final db = await MyDataBase;
    return await db!.query('Gifts',
        where:
            'status = ? AND eventId IN (SELECT id FROM Events WHERE userId = ?)',
        whereArgs: ['pledged', userId]);
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

  Future<int> deleteEventWithGifts(int eventId) async {
    final db = await MyDataBase;
    await db!.delete(
      'Gifts', // Delete gifts associated with the event first
      where: 'eventId = ?',
      whereArgs: [eventId],
    );
    return await db!.delete(
      'Events', // Now delete the event itself
      where: 'id = ?',
      whereArgs: [eventId],
    );
  }

  Future<void> updateUserNotifications(int userId, bool value) async {
    try {
      final db = await MyDataBase;
      await db!.update(
        'Users',
        {'notifications': value ? 1 : 0},
        where: 'id = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      print('Error updating user notifications: $e');
      // Handle or log the error as needed
    }
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

// Fetch all gifts for a specific event
  Future<List<Map<String, dynamic>>> getGiftsForEvent(int eventId) async {
    final db = await MyDataBase; // Ensure the database instance is available
    return await db!.query(
      'Gifts', // Table name
      where: 'eventId = ?', // Filter by eventId
      whereArgs: [eventId], // Event ID to filter gifts
    );
  }

  Future<int> updateGift(Gift gift) async {
    final db = await MyDataBase; // Ensure the database instance is available
    return await db!.update(
      'Gifts', // Table name
      gift.toMap(), // The map representation of the gift, including syncStatus
      where: 'id = ?', // Match the gift by ID
      whereArgs: [gift.id], // Gift ID to update
    );
  }
}
