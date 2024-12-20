import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event.dart';
import '../models/gift.dart'; // Ensure this imports your Event model

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  Future<List<Event>> getUpcomingEventsForFriend(String friendId) async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('Events')
          .where('createdBy', isEqualTo: friendId)
          .where('status', isEqualTo: 'Upcoming') // Filter by status
          .get();

      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return Event.fromMap(data..['id'] = doc.id);
      }).toList();
    } catch (e) {
      print("Error fetching upcoming events for friend: $e");
      return [];
    }
  }


  Future<List<Gift>> getPledgedGiftsByUser(String userId) async {
    try {
      var snapshot = await _db
          .collectionGroup('gifts') // Search across all "gifts" subcollections
          .where('pledgedBy', isEqualTo: userId) // Filter by pledgedBy
          .get();

      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return Gift.fromMap({...data, 'firebaseId': doc.id});
      }).toList();
    } catch (e) {
      print("Error fetching pledged gifts from Firestore: $e");
      throw Exception("Failed to fetch pledged gifts");
    }
  }




}
