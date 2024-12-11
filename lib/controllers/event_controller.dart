import '../models/event.dart';
import '../services/sqlite_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventController {
  LocalDatabase localdb = LocalDatabase();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  addEvent(Event event) async {
    int eventId = await localdb.insertEvent(event);
    //returns the event's id when stored in database (autoincremented)
    event.id = eventId;//can delete using that id stored
  }


  getEvents() async {
    var eventData = await localdb.getEvents();
    return eventData.map((event) => Event.fromMap(event)).toList();
  }

  // Update an event
  Future<void> updateEvent(Event event) async {
    await localdb.updateEvent(event);
  }

  // Delete an event
  Future<void> deleteEvent(int eventId) async {
    await localdb.deleteEvent(eventId);
  }

  //Firestore
  Future<void> addEventToUser(String userId, Event event) async {
    DocumentReference userDoc = _firestore.collection('Users').doc(userId);

    // Add event to the user's `events` subcollection
    await userDoc.collection('events').add(event.toMap());
  }

  Future<List<Event>> getUserEvents(String userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('Users')
        .doc(userId)
        .collection('events')
        .get();

    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Include document ID
      return Event.fromMap(data);
    }).toList();
  }

  Future<void> updateUserEvent(String userId, Event event) async {
    DocumentReference eventDoc = _firestore
        .collection('Users')
        .doc(userId)
        .collection('events')
        .doc(event.id as String?);

    await eventDoc.update(event.toMap());
  }

  Future<void> deleteUserEvent(String userId, String eventId) async {
    await _firestore
        .collection('Users')
        .doc(userId)
        .collection('events')
        .doc(eventId)
        .delete();
  }
}
