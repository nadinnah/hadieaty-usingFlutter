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

  Future<void> deleteOldDatabase() async {
    String mypath = await getDatabasesPath();
    String path = join(mypath, 'myDataBase3.db');

    if (await databaseExists(path)) {
      await deleteDatabase(path);
    }
  }

  initialize() async {
    String mypath = await getDatabasesPath();
    String path = join(mypath, 'myDataBase.db');
    Database mydb = await openDatabase(path, version: Version, onCreate: (db, Version) async {
      await db.execute('''
          CREATE TABLE IF NOT EXISTS Users (
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          preferences TEXT,
          password TEXT NOT NULL,
          isOwner INTEGER NOT NULL DEFAULT 0,
          profilePic TEXT,
          number INTEGER NOT NULL
      );
      ''');

      await db.execute(''' 
      CREATE TABLE IF NOT EXISTS Events (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          firebaseId TEXT,
          name TEXT NOT NULL,
          date TEXT NOT NULL,
          location TEXT NOT NULL,
          description TEXT,
          createdBy TEXT,
          status TEXT,
          category TEXT,
          syncStatus TEXT NOT NULL DEFAULT 'Unsynced',
          createdAt TEXT,
          FOREIGN KEY (createdBy) REFERENCES Users (id)
      );
    ''');

      await db.execute('''
      CREATE TABLE gifts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          firebaseId TEXT,
          name TEXT NOT NULL,
          description TEXT,
          category TEXT,
          price REAL,
          imageUrl TEXT,
          status TEXT NOT NULL,
          eventId TEXT NOT NULL,
          syncStatus TEXT NOT NULL,
          pledgedBy TEXT,
          createdBy TEXT
        );
      ''');
    });
    return mydb;
  }

  Future<String?> getLoggedInUserName() async {
    final db = await MyDataBase;
    final result = await db!.query(
      'Users',
      columns: ['name'],
      where: 'isOwner = ?',
      whereArgs: [1],
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
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception("Failed to update user field(s) in SQLite.");
    }
  }

  Future<void> updateUserIsOwner(String email, int isOwnerValue) async {
    final db = await MyDataBase;

    await db!.update(
      'Users',
      {'isOwner': isOwnerValue},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  Future<String?> getUserNameByEmail(String email) async {
    final db = await MyDataBase;
    var result = await db!.query(
      'Users',
      columns: ['name'],
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return result.first['name'] as String;
    }
    return null;
  }

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
      throw Exception('Error updating user notifications');
    }
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await MyDataBase;
    var result = await db!.query(
      'Users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<int> insertEvent(Event event) async {
    final db = await MyDataBase;
    var result = await db!.insert(
      'Events',
      event.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return result;
  }

  Future<int> updateEvent(Event event) async {
    final db = await MyDataBase;

    return await db!.update(
      'Events',
      {
        'firebaseId': event.firebaseId,
        'syncStatus': event.syncStatus ? 'Synced' : 'Unsynced',
        'name': event.name,
        'date': event.date,
        'location': event.location,
        'description': event.description,
        'createdBy': event.createdBy,
        'status': event.status,
        'category': event.category,
        'createdAt': event.createdAt,
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

  Future<List<Map<String, dynamic>>> getEventsByUserId(String userId) async {
    final db = await MyDataBase;
    return await db!.query(
      'Events',
      where: 'createdBy = ?',
      whereArgs: [userId],
    );
  }

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
      'createdBy': gift.createdBy,
      'pledgedBy': gift.pledgedBy ?? '',
    });
  }

  Future<int> deleteGift(int giftId) async {
    final db = await MyDataBase;
    return await db!.delete(
      'Gifts',
      where: 'id = ?',
      whereArgs: [giftId],
    );
  }

  Future<List<Map<String, dynamic>>> getPledgedGiftsByUserId(int userId) async {
    final db = await MyDataBase;
    return await db!.rawQuery(
      'SELECT * FROM Gifts WHERE status = ? AND eventId IN (SELECT id FROM Events WHERE createdBy = ?)',
      ['pledged', userId],
    );
  }

  Future<int> updateGift(Gift gift) async {
    final db = await MyDataBase;
    return await db!.update(
      'Gifts',
      gift.toMap(),
      where: 'id = ?',
      whereArgs: [gift.id],
    );
  }
}
