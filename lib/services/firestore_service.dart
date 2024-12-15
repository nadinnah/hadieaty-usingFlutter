import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event.dart'; // Ensure this imports your Event model

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  // Fetch the user's upcoming events
  Future<List<Event>> getUserUpcomingEvents() async {
    CollectionReference eventsRef = _db.collection('Users').doc(userId).collection('events');
    DateTime currentDate = DateTime.now();
    Timestamp currentTimestamp = Timestamp.fromDate(currentDate);

    // Fetch events where the date is after the current date
    QuerySnapshot snapshot = await eventsRef.where('date', isGreaterThan: currentTimestamp).get();

    // Convert Firestore documents to Event objects
    return snapshot.docs
        .map((doc) => Event.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
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

  // Fetch the number of upcoming events for a friend
  Future<int> getUpcomingEventsCount(String friendId) async {
    CollectionReference eventsRef = _db.collection('Users').doc(friendId).collection('events');
    DateTime currentDate = DateTime.now();
    Timestamp currentTimestamp = Timestamp.fromDate(currentDate);

    QuerySnapshot snapshot = await eventsRef.where('date', isGreaterThan: currentTimestamp).get();
    return snapshot.docs.length;
  }

  // Add a new event for the user
  Future<void> addEvent(Event event) async {
    CollectionReference eventsRef = _db.collection('Users').doc(userId).collection('events');

    // Convert the Event object to a map and add it to Firestore
    await eventsRef.add(event.toMap());
  }

  // Add a new gift to an event
  Future<void> addGiftToEvent(String eventId, String giftName, double giftPrice) async {
    CollectionReference giftsRef = _db.collection('Users').doc(userId).collection('events').doc(eventId).collection('gifts');
    await giftsRef.add({
      'name': giftName,
      'price': giftPrice,
      'status': 'available', // Initially available
      'pledgedBy': '', // No one pledged it yet
    });
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
