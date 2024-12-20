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

  Future<bool> updateEventLocally(Event event) async {
    try {
      event.syncStatus=false;
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

  Future<void> deleteEvent(Event event) async {
    try {
      await localdb.deleteEvent(event.id!);

      if (event.firebaseId != null) {
        await _firestore.collection('Events').doc(event.firebaseId).delete();
      }

      print("Event deleted successfully.");
    } catch (e) {
      print("Error deleting event: $e");
    }
  }

  Future<List<Event>> getEventsForCurrentUser() async {
    try {
      // Replace with local SQLite query
      var localEvents = await localdb.getEventsByUserId(FirebaseAuth.instance.currentUser!.uid);
      return localEvents.map((e) => Event.fromMap(e)).toList();
    } catch (e) {
      print("Error fetching events from local database: $e");
      return [];
    }
  }



  Future<void> syncEventToFirebase(Event event) async {
    try {
      DocumentReference eventRef;

      if (event.firebaseId == null || event.firebaseId!.isEmpty) {
        // Add new event to Firestore
        eventRef = await FirebaseFirestore.instance.collection('Events').add(event.toMap());
        event.firebaseId = eventRef.id; // Set the Firestore document ID as firebaseId
        await FirebaseFirestore.instance
            .collection('Events')
            .doc(eventRef.id)
            .update({'firebaseId': eventRef.id}); // Update the document with its ID
      } else {
        // Update existing event
        eventRef = FirebaseFirestore.instance.collection('Events').doc(event.firebaseId);
        await eventRef.update(event.toMap());
      }

      // Mark as synced locally
      event.syncStatus = true;
      await localdb.updateEvent(event);

      print("Event successfully synced to Firestore with ID ${event.firebaseId}.");
    } catch (e) {
      print("Error syncing event to Firestore: $e");
    }
  }

}
