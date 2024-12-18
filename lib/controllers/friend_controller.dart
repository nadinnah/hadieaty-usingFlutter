import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  // Add a friend by their user ID
  Future<void> addFriend(String friendUserId) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Add friend to the current user's `friends` list
      await _firestore.collection('Users').doc(userId).update({
        'friends': FieldValue.arrayUnion([friendUserId]),
      });

      // Optionally add the current user to the friend's `friends` list
      await _firestore.collection('Users').doc(friendUserId).update({
        'friends': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      print('Error adding friend: $e');
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
