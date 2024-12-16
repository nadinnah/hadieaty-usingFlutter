import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/friend.dart';

class FriendController with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Friend> _friends = [];
  List<Friend> _filteredFriends = [];

  List<Friend> get friends => _filteredFriends.isEmpty ? _friends : _filteredFriends;

  Future<List<Friend>> getFriendsDetails(List<dynamic> friendsUids) async {
    try {
      List<Friend> friends = [];
      for (var uid in friendsUids) {
        // Fetch each friend's details by UID from Firestore
        var friendDoc = await FirebaseFirestore.instance.collection('Users').doc(uid).get();
        if (friendDoc.exists) {
          var friendData = friendDoc.data() as Map<String, dynamic>;
          friends.add(Friend.fromFirestore(uid, friendData));
        }
      }
      return friends;
    } catch (e) {
      print("Error fetching friends details: $e");
      return [];
    }
  }

  // Fetch friends for the logged-in user by checking users with isOwner=false
  Future<void> fetchFriends() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Fetch all users with isOwner=false from the 'Users' collection
      var snapshot = await _firestore.collection('Users').where('isOwner', isEqualTo: false).get();

      // Filter out the logged-in user from the friends list
      var usersList = snapshot.docs.where((doc) => doc.id != userId).toList();

      // Map each user document to a Friend object
      _friends = usersList.map((doc) {
        var data = doc.data();
        return Friend(
          id: doc.id,  // Use the document ID as a unique identifier for each friend
          name: data['name'],
          profilePicture: data['profilePicture'] ?? '',
          phone: data['phone'] ?? '',
          upcomingEventsCount: data['upcomingEventsCount'] ?? 0,
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching friends: $e');
    }
  }

  // Add a friend by their user ID
  Future<void> addFriend(String friendUserId) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Add friend to the current user's 'friends' list in Firestore
      await _firestore.collection('Users').doc(userId).update({
        'friends': FieldValue.arrayUnion([friendUserId]),
      });

      // Optionally, you can add the current user to the friend's 'friends' list as well
      await _firestore.collection('Users').doc(friendUserId).update({
        'friends': FieldValue.arrayUnion([userId]),
      });

      // Fetch the updated friend's data
      var friendSnapshot = await _firestore.collection('Users').doc(friendUserId).get();
      var friendData = friendSnapshot.data();
      if (friendData != null) {
        _friends.add(Friend.fromFirestore(friendUserId, friendData));
        notifyListeners();
      }
    } catch (e) {
      print('Error adding friend: $e');
    }
  }

  // Delete a friend by their user ID
  Future<void> deleteFriend(String friendUserId) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Remove friend from the current user's 'friends' list
      await _firestore.collection('Users').doc(userId).update({
        'friends': FieldValue.arrayRemove([friendUserId]),
      });

      // Optionally, remove the current user from the friend's 'friends' list as well
      await _firestore.collection('Users').doc(friendUserId).update({
        'friends': FieldValue.arrayRemove([userId]),
      });

      // Remove friend from the local list
      _friends.removeWhere((friend) => friend.id == friendUserId);
      notifyListeners();
    } catch (e) {
      print('Error deleting friend: $e');
    }
  }

  // Search for friends by name or phone number
  void searchFriends(String query) {
    if (query.isEmpty) {
      _filteredFriends = [];
    } else {
      _filteredFriends = _friends
          .where((friend) =>
      friend.name.toLowerCase().contains(query.toLowerCase()) ||
          friend.phone.contains(query))
          .toList();
    }
    notifyListeners();
  }
}
