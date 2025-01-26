import '../models/event.dart';
import '../services/firestore_service.dart';
import '../services/sqlite_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventController {
  final LocalDatabase localdb = LocalDatabase();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Adds an event to the local database.
  Future<bool> addEventLocally(Event event) async {
    try {
      int result = await localdb.insertEvent(event);
      return result > 0;
    } catch (e) {
      return false;
    }
  }

  //Updates an event in the local database and marks it as unsynced.
  Future<bool> updateEventLocally(Event event) async {
    try {
      event.syncStatus = false;
      int rowsUpdated = await localdb.updateEvent(event);

      return rowsUpdated > 0;
    } catch (e) {
      return false;
    }
  }

  //Deletes an event from the local database and Firestore if it exists there.
  Future<void> deleteEvent(Event event) async {
    try {
      await localdb.deleteEvent(event.id!);

      if (event.firebaseId != null) {
        await _firestore.collection('Events').doc(event.firebaseId).delete();
      }
    } catch (e) {
      throw Exception("Failed to delete the event.");
    }
  }

  //Retrieves events for the current user from the local database.
  Future<List<Event>> getEventsForCurrentUser() async {
    try {
      var localEvents = await localdb.getEventsByUserId(FirebaseAuth.instance.currentUser!.uid);
      return localEvents.map((e) => Event.fromMap(e)).toList();
    } catch (e) {
      return [];
    }
  }

  //Syncs an event to Firestore, adding it if it doesn't exist or updating it if it does.
  Future<void> syncEventToFirebase(Event event) async {
    try {
      DocumentReference eventRef;

      if (event.firebaseId == null || event.firebaseId!.isEmpty) {
        eventRef = await FirebaseFirestore.instance.collection('Events').add(event.toMap());
        event.firebaseId = eventRef.id;
        await FirebaseFirestore.instance
            .collection('Events')
            .doc(eventRef.id)
            .update({'firebaseId': eventRef.id});
      } else {
        eventRef = FirebaseFirestore.instance.collection('Events').doc(event.firebaseId);
        await eventRef.update(event.toMap());
      }

      event.syncStatus = true;
      await localdb.updateEvent(event);
    } catch (e) {
      throw Exception("Failed to sync event to Firestore.");
    }
  }
}
