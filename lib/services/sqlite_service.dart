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
    String path = join(mypath, 'myDataBase3.db');

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

    //await deleteOldDatabase();
    String mypath = await getDatabasesPath();
    String path = join(mypath, 'myDataBase.db');
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
      );
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
          syncStatus TEXT NOT NULL DEFAULT 'Unsynced',
          createdAt TEXT,
          FOREIGN KEY (createdBy) REFERENCES Users (id)  -- Referencing the user via createdBy
      );
    ''');

      // Gifts Table
      await db.execute('''
      CREATE TABLE gifts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          firebaseId TEXT, -- Firestore gift ID
          name TEXT NOT NULL,
          description TEXT,
          category TEXT,
          price REAL,
          imageUrl TEXT,
          status TEXT NOT NULL, -- Status like "Available", "Pledged", "Purchased"
          eventId TEXT NOT NULL, -- Firestore Event ID
          syncStatus TEXT NOT NULL, -- "Synced" or "Unsynced"
          pledgedBy TEXT, -- Firestore user ID of the pledger
          createdBy TEXT -- New column for the creator's Firestore ID
        );
      ''');

      print("Database initialized.");
    });
    return mydb;
  }




  Future<List<Map<String, dynamic>>> getEventsByUserId(String userId) async {
    final db = await MyDataBase;
    return await db!.query(
      'Events',
      where: 'createdBy = ?', // Correct condition
      whereArgs: [userId],
    );
  }

  Future<String?> getLoggedInUserName() async {
    final db = await MyDataBase;
    final result = await db!.query(
      'Users',
      columns: ['name'], // Only fetch the 'name' column
      where: 'isOwner = ?', // Assuming 'isOwner' marks the current logged-in user
      whereArgs: [1], // isOwner = 1 indicates the logged-in user
    );

    if (result.isNotEmpty) {
      return result.first['name'] as String;
    }
    return null;
  }

  Future<int> insertUser(Map<String, dynamic> userData) async {
    final db = await MyDataBase;
    return await db!.insert(
      'Users',
      {
        ...userData,
      },
    );
  }

  Future<void> updateUserFieldById(int id, Map<String, dynamic> fieldsToUpdate) async {
    final db = await MyDataBase;

    try {
      await db!.update(
        'Users',
        fieldsToUpdate,
        where: 'id = ?', // Use the local database ID as the condition
        whereArgs: [id],
      );
      print("Field(s) ${fieldsToUpdate.keys.join(', ')} updated successfully for local ID: $id.");
    } catch (e) {
      print("Error updating user field(s) in SQLite: $e");
      throw Exception("Failed to update user field(s) in SQLite.");
    }
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
  }//USED




//EVENTS:
  Future<int> insertEvent(Event event) async {
    final db = await MyDataBase;
    var result = await db!.insert(
      'Events',
      event.toMap(),  // Insert the event, firebaseId will be null initially
      conflictAlgorithm: ConflictAlgorithm.replace,  // Replace if already exists
    );
    return result;  // Return the ID of the inserted event
  }//USED


  Future<int> updateEvent(Event event) async {
    final db = await MyDataBase;

    // Convert the event object into a map with required updates
    return await db!.update(
      'Events',
      {
        'firebaseId': event.firebaseId, // Store Firestore ID
        'syncStatus': event.syncStatus ? 'Synced' : 'Unsynced', // Store as Synced/Unsynced
        'name': event.name,
        'date': event.date,
        'location': event.location,
        'description': event.description,
        'createdBy': event.createdBy,
        'status': event.status,
        'category': event.category,
        'createdAt': event.createdAt,
      },
      where: 'id = ?', // Match by event ID
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
  }//USED


  Future<List<Map<String, dynamic>>> getGiftsByEventId(String firebaseEventId) async {
    final db = await MyDataBase;
    return await db!.query(
      'Gifts',
      where: 'eventId = ?',
      whereArgs: [firebaseEventId],
    );
  }



  Future<int> insertGift(Gift gift) async {
    final db = await MyDataBase;
    return await db!.insert('Gifts', {
      ...gift.toMap(),
      'createdBy': gift.createdBy, // Include creator ID
      'pledgedBy': gift.pledgedBy ?? '', // Include pledger ID
    });
  }


// Delete a gift by ID
  Future<int> deleteGift(int giftId) async {
    final db = await MyDataBase;
    return await db!.delete(
      'Gifts', // Table from which to delete the gift
      where: 'id = ?', // Condition to match the gift by its ID
      whereArgs: [giftId], // The ID of the gift to delete
    );
  }//USED

// Fetch pledged gifts for a specific user (based on userId)
  Future<List<Map<String, dynamic>>> getPledgedGiftsByUserId(int userId) async {
    final db = await MyDataBase;
    return await db!.rawQuery(
      'SELECT * FROM Gifts WHERE status = ? AND eventId IN (SELECT id FROM Events WHERE createdBy = ?)',
      ['pledged', userId],
    );
  }
//USED

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
