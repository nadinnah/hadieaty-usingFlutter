import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hadieaty/models/event.dart';
import 'package:hadieaty/models/gift.dart';
import 'package:hadieaty/services/sqlite_service.dart';

class UserController {
  final LocalDatabase _localDatabase = LocalDatabase();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Fetches user data from Firestore for the currently logged-in user.
  Future<Map<String, dynamic>> getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("No user is logged in.");
    }

    DocumentSnapshot userDoc = await _firestore.collection('Users').doc(user.uid).get();
    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>;
    } else {
      throw Exception("User data not found in Firestore.");
    }
  }

  //Gets the local SQLite ID for the currently logged-in user.
  Future<int?> getLocalId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("No user is logged in.");
    }

    Map<String, dynamic>? localUser = await _localDatabase.getUserByEmail(user.email!);
    if (localUser != null && localUser['id'] != null) {
      return localUser['id'];
    }

    return null;
  }

  //Updates a specific user field in Firestore and SQLite.
  Future<void> updateUserField(String field, String value, int localId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("No user is logged in.");
    }

    await _firestore.collection('Users').doc(user.uid).update({field: value});

    if (field == 'name' || field == 'number' || field == 'email') {
      await _localDatabase.updateUserFieldById(localId, {field: value});
    }
  }

  //Updates the user's profile picture in Firestore.
  Future<void> updateProfilePicture(String filePath) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("No user is logged in.");
    }

    await _firestore.collection('Users').doc(user.uid).update({'profilePic': filePath});
  }

  //Retrieves events created by the user from the local database.
  Future<List<Event>> getCreatedEvents(int userId) async {
    var eventsData = await _localDatabase.getEventsByUserId(userId.toString());
    return eventsData.map((e) => Event.fromMap(e)).toList();
  }

  //Retrieves pledged gifts by the user from the local database.
  Future<List<Gift>> getPledgedGifts(int userId) async {
    var giftsData = await _localDatabase.getPledgedGiftsByUserId(userId);
    return giftsData.map((e) => Gift.fromMap(e)).toList();
  }

  //Updates the notification preference for a user in the local database.
  Future<void> updateUserNotifications(int userId, bool value) async {
    await _localDatabase.updateUserNotifications(userId, value);
  }

  //Gets the user ID from the local database by email.
  Future<int> getUserIdByEmail(String email) async {
    var user = await _localDatabase.getUserByEmail(email);
    if (user != null) {
      return user['id'];
    } else {
      throw Exception("User not found with email: $email");
    }
  }
}
