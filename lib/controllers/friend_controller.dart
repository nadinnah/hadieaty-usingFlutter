import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase_api.dart';
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


  Future<List<Friend>> fetchFriends() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Fetch the current user's friends list
      var userDoc = await _firestore.collection('Users').doc(userId).get();
      var friendsIds = userDoc.data()?['friends'] ?? [];

      // Fetch details for each friend
      List<Friend> friends = await Future.wait(friendsIds.map((friendId) async {
        var friendDoc = await _firestore.collection('Users').doc(friendId).get();
        var friendData = friendDoc.data();

        if (friendData != null) {
          // Fetch upcoming events count for the friend
          int eventCount = await _fetchUpcomingEventsCount(friendId);
          return Friend(
            id: friendId,
            name: friendData['name'],
            profilePicture: friendData['profilePicture'] ?? '',
            phone: friendData['phone'] ?? '',
            upcomingEventsCount: eventCount,
          );
        }
        return null;
      }).whereType<Friend>().toList());

      return friends;
    } catch (e) {
      print('Error fetching friends: $e');
      return [];
    }
  }

  // Fetch upcoming events count for a friend
  Future<int> _fetchUpcomingEventsCount(String friendId) async {
    try {
      var snapshot = await _firestore
          .collection('Events')
          .where('createdBy', isEqualTo: friendId)
          .where('status', isEqualTo: 'Upcoming')
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('Error fetching upcoming events count: $e');
      return 0;
    }
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
}
