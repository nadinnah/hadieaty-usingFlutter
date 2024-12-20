import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hadieaty/models/event.dart';
import 'package:hadieaty/models/gift.dart';
import 'package:hadieaty/services/sqlite_service.dart'; // LocalDatabase service

class UserController {
  final LocalDatabase _localDatabase = LocalDatabase();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // // Fetch user data by userId
  // Future<Map<String, dynamic>> getUserData(int userId) async {
  //   var userData = await _localDatabase.getUserById(userId);
  //   return userData;
  // }
  Future<Map<String, dynamic>> getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("No user is logged in.");
    }

    // Fetch user data from Firestore
    DocumentSnapshot userDoc = await _firestore.collection('Users').doc(user.uid).get();
    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>; // Return Firestore user data
    } else {
      throw Exception("User data not found in Firestore.");
    }
  }

  Future<int?> getLocalId() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("No user is logged in.");
    }

    // Fetch the user data from SQLite using email
    Map<String, dynamic>? localUser = await _localDatabase.getUserByEmail(user.email!);
    if (localUser != null && localUser['id'] != null) {
      return localUser['id']; // Return the local SQLite ID
    }

    return null; // Return null if not found
  }
  Future<void> updateUserField(String field, String value, int localId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("No user is logged in.");
    }

    // Update Firestore
    await _firestore.collection('Users').doc(user.uid).update({
      field: value,
    });

    // Update SQLite for 'name', 'number', or 'email'
    if (field == 'name' || field == 'number' || field == 'email') {
      await _localDatabase.updateUserFieldById(localId, {field: value});
    }
  }


  Future<void> updateProfilePicture(String filePath) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("No user is logged in.");
    }

    await _firestore.collection('Users').doc(user.uid).update({
      'profilePic': filePath,
    });
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

  // Future<void> updateUserField(int userId, String field, String value) async {
  //   try {
  //     // Ensure the field is valid and not empty
  //     if (field.isEmpty || value.isEmpty) {
  //       throw Exception("Field and value cannot be empty.");
  //     }
  //
  //     // Update the local database
  //     await _localDatabase.updateUserField(userId, field, value);
  //
  //     print("User field '$field' updated successfully to '$value' for user ID $userId.");
  //   } catch (e) {
  //     print("Error updating user field: $e");
  //     rethrow; // Re-throw the error if needed for further handling
  //   }
  // }


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
