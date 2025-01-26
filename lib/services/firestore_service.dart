import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event.dart';
import '../models/gift.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  Future<List<Event>> getUpcomingEventsForFriend(String friendId) async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('Events')
          .where('createdBy', isEqualTo: friendId)
          .where('status', isEqualTo: 'Upcoming')
          .get();

      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return Event.fromMap(data..['id'] = doc.id);
      }).toList();
    } catch (e) {
      throw Exception("Failed to fetch upcoming events for friend");
    }
  }

  Future<List<Gift>> getPledgedGiftsByUser(String userId) async {
    try {
      var snapshot = await _db
          .collectionGroup('gifts')
          .where('pledgedBy', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return Gift.fromMap({...data, 'firebaseId': doc.id});
      }).toList();
    } catch (e) {
      throw Exception("Failed to fetch pledged gifts");
    }
  }

}
