import 'package:hadieaty/models/event.dart';
import 'package:hadieaty/models/gift.dart';
import 'package:hadieaty/services/sqlite_service.dart'; // LocalDatabase service

class UserController {
  final LocalDatabase _localDatabase = LocalDatabase();

  Future<int> insertUser(Map<String, dynamic> userData) async {
    try {
      int userId = await _localDatabase.insertUser(userData);
      print("User added to local database with ID: $userId");
      return userId;
    } catch (e) {
      print("Error inserting user: $e");
      throw Exception("Failed to add user to local database");
    }
  }

  // Fetch user data by userId
  Future<Map<String, dynamic>> getUserData(int userId) async {
    var userData = await _localDatabase.getUserById(userId);
    return userData;
  }

  // Fetch created events by userId
  Future<List<Event>> getCreatedEvents(int userId) async {
    var eventsData = await _localDatabase.getEventsByUserId(userId);
    return eventsData.map((e) => Event.fromMap(e)).toList();
  }

  // Fetch pledged gifts by userId
  Future<List<Gift>> getPledgedGifts(int userId) async {
    var giftsData = await _localDatabase.getPledgedGiftsByUserId(userId);
    return giftsData.map((e) => Gift.fromMap(e)).toList();
  }

  // Update user field (name, email, or notifications)
  Future<void> updateUserField(int userId, String field, String value) async {
    await _localDatabase.updateUserField(userId, field, value);
  }

  // Update notification preference
  Future<void> updateUserNotifications(int userId, bool value) async {
    await _localDatabase.updateUserNotifications(userId, value);
  }

  Future<int> getUserIdByEmail(String email) async {
    var user = await _localDatabase.getUserByEmail(email);
    if (user != null) {
      return user['id']; // Return the userId
    } else {
      throw Exception("User not found with email: $email");
    }
  }
}
