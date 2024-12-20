import 'package:hadieaty/models/event.dart';
import 'package:hadieaty/models/gift.dart';
import 'package:hadieaty/services/sqlite_service.dart'; // LocalDatabase service

class UserController {
  final LocalDatabase _localDatabase = LocalDatabase();

  // Fetch user data by userId
  Future<Map<String, dynamic>> getUserData(int userId) async {
    var userData = await _localDatabase.getUserById(userId);
    return userData;
  }

  Future<List<Event>> getCreatedEvents(int userId) async {
    var eventsData = await _localDatabase.getEventsByUserId(userId.toString()); // Ensure it's a string if SQLite expects it
    return eventsData.map((e) => Event.fromMap(e)).toList();
  }

  // Fetch pledged gifts by userId
  Future<List<Gift>> getPledgedGifts(int userId) async {
    var giftsData = await _localDatabase.getPledgedGiftsByUserId(userId);
    return giftsData.map((e) => Gift.fromMap(e)).toList();
  }

  Future<void> updateUserField(int userId, String field, String value) async {
    try {
      // Ensure the field is valid and not empty
      if (field.isEmpty || value.isEmpty) {
        throw Exception("Field and value cannot be empty.");
      }

      // Update the local database
      await _localDatabase.updateUserField(userId, field, value);

      print("User field '$field' updated successfully to '$value' for user ID $userId.");
    } catch (e) {
      print("Error updating user field: $e");
      rethrow; // Re-throw the error if needed for further handling
    }
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
