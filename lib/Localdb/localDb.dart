import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'package:hadieaty/models/events.dart';
import 'package:hadieaty/models/gifts.dart';
import 'package:hadieaty/models/users.dart';
import 'package:hadieaty/models/friends.dart';

Database? _database;
class LocalDatabase {

  static final LocalDatabase _databaseHelper = LocalDatabase._createInstance();
  LocalDatabase._createInstance();
  factory LocalDatabase() => _databaseHelper;

  final String _dbName = 'Local.db';

  // Table names
  final String userTable = 'Users';
  final String eventTable = 'Events';
  final String giftTable = 'Gifts';
  final String friendTable = 'Friends';

  // Users Table Columns
  final String userId = 'id';
  final String userName = 'name';
  final String userEmail = 'email';
  final String userPreferences = 'preferences';

  // Events Table Columns
  final String eventId = 'id';
  final String eventName = 'name';
  final String eventDate = 'date';
  final String eventLocation = 'location';
  final String eventDescription = 'description';
  final String eventUserId = 'userId';

  // Gifts Table Columns
  final String giftId = 'id';
  final String giftName = 'name';
  final String giftDescription = 'description';
  final String giftCategory = 'category';
  final String giftPrice = 'price';
  final String giftStatus = 'status';
  final String giftEventId = 'eventId';

  // Friends Table Columns
  final String friendUserId = 'userId';
  final String friendFriendId = 'friendId';


  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initializeDB(_dbName);
    return _database!;
  }


  Future<Database> _initializeDB(String dbName) async {
    final dbPath = await getDatabasesPath();
    String path = dbPath + dbName;

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  void _createDb(Database db, int version) async {

    await db.execute('''   //Create Users table
      CREATE TABLE $userTable (
        $userId INTEGER PRIMARY KEY AUTOINCREMENT,
        $userName TEXT NOT NULL,
        $userEmail TEXT NOT NULL,
        $userPreferences TEXT
      )
    ''');

    await db.execute('''    //Create Events table
      CREATE TABLE $eventTable (
        $eventId INTEGER PRIMARY KEY AUTOINCREMENT,
        $eventName TEXT NOT NULL,
        $eventDate TEXT NOT NULL,
        $eventLocation TEXT,
        $eventDescription TEXT,
        $eventUserId INTEGER,
        FOREIGN KEY ($eventUserId) REFERENCES $userTable($userId)
      )
    ''');


    await db.execute('''    //Create Gifts table
      CREATE TABLE $giftTable (
        $giftId INTEGER PRIMARY KEY AUTOINCREMENT,
        $giftName TEXT NOT NULL,
        $giftDescription TEXT,
        $giftCategory TEXT,
        $giftPrice REAL,
        $giftStatus TEXT,
        $giftEventId INTEGER,
        FOREIGN KEY ($giftEventId) REFERENCES $eventTable($eventId)
      )
    ''');


    await db.execute('''    //Create Friends table
      CREATE TABLE $friendTable (
        $friendUserId INTEGER,
        $friendFriendId INTEGER,
        PRIMARY KEY ($friendUserId, $friendFriendId),
        FOREIGN KEY ($friendUserId) REFERENCES $userTable($userId),
        FOREIGN KEY ($friendFriendId) REFERENCES $userTable($userId)
      )
    ''');
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