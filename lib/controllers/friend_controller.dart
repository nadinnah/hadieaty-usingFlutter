import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_api.dart';
import '../models/friend.dart';

class FriendController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Returns a stream of the count of upcoming events for a specific friend.
  Stream<int> getUpcomingEventsCount(String friendId) {
    return FirebaseFirestore.instance
        .collection('Events')
        .where('createdBy', isEqualTo: friendId)
        .where('status', isEqualTo: 'Upcoming')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  //Adds a friend by their phone number to the current user's friends list.
  Future<void> addFriendByPhone(String phoneNumber) async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      var friendDoc = await _firestore
          .collection('Users')
          .where('phone', isEqualTo: phoneNumber)
          .get();

      if (friendDoc.docs.isEmpty) {
        throw Exception("No user found with that phone number");
      }

      var friendData = friendDoc.docs.first.data();
      String friendId = friendDoc.docs.first.id;

      var currentUserDoc = await _firestore.collection('Users').doc(currentUserId).get();
      String currentUserName = currentUserDoc.data()?['name'] ?? 'Someone';

      await _firestore.collection('Users').doc(currentUserId).update({
        'friends': FieldValue.arrayUnion([friendId]),
      });

      await _firestore.collection('Users').doc(friendId).update({
        'friends': FieldValue.arrayUnion([currentUserId]),
      });

      FirebaseApi().sendNotificationToUser(
        friendId,
        "New Friend Added!",
        "$currentUserName added you as a friend.",
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  //Deletes a friend from the current user's friends list by their user ID.
  Future<void> deleteFriend(String friendUserId) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      await _firestore.collection('Users').doc(userId).update({
        'friends': FieldValue.arrayRemove([friendUserId]),
      });

      await _firestore.collection('Users').doc(friendUserId).update({
        'friends': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      throw Exception('Error deleting friend');
    }
  }

  //Retrieves the list of friends for the current user, including their details.
  Future<List<Friend>> getFriends() async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isEmpty) return [];

      var userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (!userDoc.exists) return [];

      List<dynamic> friendIds = userDoc.data()?['friends'] ?? [];

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
            upcomingEventsCount: 0,
          ));
        }
      }
      return friends;
    } catch (e) {
      throw Exception("Error fetching friends");
    }
  }
}
