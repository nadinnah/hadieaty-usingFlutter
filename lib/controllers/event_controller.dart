import '../models/event.dart';
import '../services/firestore_service.dart';
import '../services/sqlite_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventController {
  final LocalDatabase localdb = LocalDatabase();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<bool> addEventLocally(Event event) async {
    try {
      int result = await localdb.insertEvent(event);
      return result > 0; // Success if a row is inserted
    } catch (e) {
      print("Error adding event locally: $e");
      return false;
    }
  }


  Future<bool> updateEvent(Event event) async {
    try {
      // Update the event locally in SQLite
      int rowsUpdated = await localdb.updateEvent(event);

      if (rowsUpdated == 0) {
        print("Failed to update event locally.");
        return false;
      }

      print("Event updated locally.");
      return true;
    } catch (e) {
      print("Error updating event locally: $e");
      return false;
    }
  }





  Future<void> publishEvent(Event event) async {
    try {
      // Call FirestoreService to publish the event
      await FirestoreService().addEvent(event);

      // After publishing, mark as synced locally
      event.syncStatus = true;
      await localdb.updateEvent(event);
      print("Event published to Firestore and marked as synced locally.");
    } catch (e) {
      print("Error publishing event: $e");
    }
  }







  Future<void> deleteEvent(Event event) async {
    try {
      // Delete locally
      await localdb.deleteEvent(event.id! as int);

      // Delete from Firestore
      if (event.firebaseId != null) {
        await _firestore
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .collection('events')
            .doc(event.firebaseId)
            .delete();
      }
    } catch (e) {
      print("Error deleting event: $e");
    }
  }

  // Fetch all events for the logged-in user
  Future<List<Event>> getEventsForCurrentUser() async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isEmpty) return [];

      // Fetch events from local database
      var localEvents = await localdb.getEventsByUserId(userId);
      return localEvents.map((e) => Event.fromMap(e)).toList();
    } catch (e) {
      print("Error fetching events: $e");
      return [];
    }
  }
  Future<List<Event>> fetchUserEvents() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    return await FirestoreService().getUserEvents(userId);
  }

  Future<void> syncEventToFirebase(Event event) async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isEmpty) return;

      var userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
      var eventsCollection = userDocRef.collection('events');

      if (event.firebaseId == null) {
        // New event, add it to Firebase
        var docRef = await eventsCollection.add(event.toMap());
        event.firebaseId = docRef.id;
      } else {
        // Existing event, update it in Firebase
        await eventsCollection.doc(event.firebaseId).update(event.toMap());
      }

      // Update local SQLite with firebaseId and sync status
      event.syncStatus = true;
      int rowsUpdated = await localdb.updateEvent(event);

      if (rowsUpdated == 0) {
        print("Failed to update firebaseId in local database.");
      } else {
        print("FirebaseId updated in local database.");
      }

      print("Event successfully synced to Firebase.");
    } catch (e) {
      print("Error syncing event to Firebase: $e");
    }
  }


}
