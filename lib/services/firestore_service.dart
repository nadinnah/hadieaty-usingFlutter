import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event.dart';
import '../models/gift.dart'; // Ensure this imports your Event model

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  // Fetch the user's upcoming events
  Future<List<Event>> getUserEvents(String userId) async {
    try {
      var snapshot = await _db
          .collection('Events')
          .where('createdBy', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return Event.fromMap(data..['id'] = doc.id);
      }).toList();
    } catch (e) {
      print("Error fetching events: $e");
      return [];
    }
  }


  // Fetch friends list
  Future<List<Map<String, dynamic>>> getFriendsList() async {
    DocumentSnapshot userDoc = await _db.collection('Users').doc(userId).get();
    List<String> friendsList = List<String>.from(userDoc['friends']);

    List<Map<String, dynamic>> friendsData = [];
    for (String friendId in friendsList) {
      DocumentSnapshot friendDoc = await _db.collection('Users').doc(friendId).get();
      friendsData.add({
        'uid': friendId,
        'name': friendDoc['name'],
        'profilePicture': friendDoc['profilePicture'],
      });
    }
    return friendsData;
  }

  Future<void> addFriend(String friendId) async {
    try {
      // Fetch the upcoming events count for the friend
      int eventCount = await getUpcomingEventsCount(friendId);

      // Update the current user's friends array
      await _db.collection('Users').doc(userId).update({
        'friends': FieldValue.arrayUnion([friendId]),
      });

      // Optionally, store the event count as part of the friend's data
      await _db.collection('Users').doc(userId).collection('friends').doc(friendId).set({
        'eventCount': eventCount,
      });
    } catch (e) {
      print("Error adding friend: $e");
    }
  }


  Future<int> getUpcomingEventsCount(String friendId) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Events') // Global Events collection
          .where('createdBy', isEqualTo: friendId) // Events created by this friend
          .where('date', isGreaterThan: Timestamp.now()) // Upcoming events only
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print("Error fetching upcoming events count: $e");
      return 0;
    }
  }


  Future<void> addEvent(Event event) async {
    try {
      await _db.collection('Events').add({
        'name': event.name,
        'category': event.category,
        'date': Timestamp.fromDate(DateTime.parse(event.date)),
        'description': event.description,
        'location': event.location,
        'createdBy': FirebaseAuth.instance.currentUser!.uid, // Reference User ID
      });
      print("Event added successfully to Firestore.");
    } catch (e) {
      print("Error adding event to Firestore: $e");
    }
  }


  Future<void> addGiftToEvent(String eventId, Gift gift) async {
    try {
      await _db
          .collection('Events')
          .doc(eventId)
          .collection('Gifts')
          .add({
        'name': gift.name,
        'description': gift.description ?? '',
        'price': gift.price ?? 0.0,
        'category': gift.category ?? '',
        'imageUrl': gift.imageUrl ?? '',
      });
      print("Gift added successfully to Firestore.");
    } catch (e) {
      print("Error adding gift to Firestore: $e");
    }
  }


  // Get gifts for a specific event
  Future<List<Map<String, dynamic>>> getGiftsForEvent(String eventId) async {
    CollectionReference giftsRef = _db.collection('Users').doc(userId).collection('events').doc(eventId).collection('gifts');
    QuerySnapshot snapshot = await giftsRef.get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  // Pledge a gift for an event
  Future<void> pledgeGift(String eventId, String giftId) async {
    CollectionReference giftsRef = _db.collection('Users').doc(userId).collection('events').doc(eventId).collection('gifts');
    await giftsRef.doc(giftId).update({
      'status': 'pledged', // Update the gift status to pledged
      'pledgedBy': userId, // Store the user ID of the person pledging
    });
  }
}
