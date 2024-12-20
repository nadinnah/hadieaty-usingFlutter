import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_api.dart';
import '../models/friend.dart';

class FriendController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<int> getUpcomingEventsCount(String friendId) {
    return FirebaseFirestore.instance
        .collection('Events')
        .where('createdBy', isEqualTo: friendId)
        .where('status', isEqualTo: 'Upcoming') // Filter for upcoming events
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }



  Future<void> addFriendByPhone(String phoneNumber) async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      // Query Firestore to find the friend by phone number
      var friendDoc = await _firestore
          .collection('Users')
          .where('phone', isEqualTo: phoneNumber)
          .get();

      if (friendDoc.docs.isEmpty) {
        throw Exception("No user found with that phone number");
      }

      var friendData = friendDoc.docs.first.data();
      String friendId = friendDoc.docs.first.id;

      // Fetch current user's name from Firestore
      var currentUserDoc = await _firestore.collection('Users').doc(currentUserId).get();
      String currentUserName = currentUserDoc.data()?['name'] ?? 'Someone';

      // Add the friend to the current user's friends list
      await _firestore.collection('Users').doc(currentUserId).update({
        'friends': FieldValue.arrayUnion([friendId]),
      });

      // Add the current user to the friend's friends list
      await _firestore.collection('Users').doc(friendId).update({
        'friends': FieldValue.arrayUnion([currentUserId]),
      });

      // Notify the new friend
      FirebaseApi().sendNotificationToUser(
        friendId,
        "New Friend Added!",
        "$currentUserName added you as a friend.",
      );

      print("Friend added successfully: ${friendData['name']}");
    } catch (e) {
      print("Error adding friend: $e");
      throw Exception(e.toString());
    }
  }

  // Delete a friend by their user ID
  Future<void> deleteFriend(String friendUserId) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Remove friend from the current user's `friends` list
      await _firestore.collection('Users').doc(userId).update({
        'friends': FieldValue.arrayRemove([friendUserId]),
      });

      // Optionally remove the current user from the friend's `friends` list
      await _firestore.collection('Users').doc(friendUserId).update({
        'friends': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      print('Error deleting friend: $e');
    }
  }

  Future<List<Friend>> getFriends() async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isEmpty) return [];

      // Fetch user's document
      var userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (!userDoc.exists) return [];

      // Extract friend IDs
      List<dynamic> friendIds = userDoc.data()?['friends'] ?? [];

      // Fetch friend details
      List<Friend> friends = [];
      for (String friendId in friendIds) {
        var friendDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(friendId)
            .get();

        if (friendDoc.exists) {
          var friendData = friendDoc.data();
          friends.add(Friend(
            id: friendId,
            name: friendData?['name'] ?? 'Unknown',
            profilePicture: friendData?['profilePicture'] ?? '',
            phone: friendData?['phone'] ?? '',
            upcomingEventsCount: 0, // This can be updated dynamically later
          ));
        }
      }
      return friends;
    } catch (e) {
      print("Error fetching friends: $e");
      return [];
    }
  }
}
