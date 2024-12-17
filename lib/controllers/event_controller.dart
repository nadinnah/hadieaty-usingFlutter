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
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      event.createdBy = user.uid; // Assign user ID
      event.syncStatus = false;

      int result = await localdb.insertEvent(event); // Insert locally
      print("Event added with ID: $result");

      return result > 0; // Ensure success
    } catch (e) {
      print("Error adding event locally: $e");
      return false;
    }
  }


  Future<bool> updateEvent(Event event) async {
    try {
      // Update locally in SQLite
      int rowsUpdated = await localdb.updateEvent(event); // Returns rows affected
      bool updatedLocally = rowsUpdated > 0; // Check if the update succeeded
      if (!updatedLocally) {
        print("Failed to update event locally.");
        return false;
      }

      // Sync with Firestore only if local update succeeded
      await publishEvent(event);
      print("Event updated locally and synced to Firestore.");

      return true;
    } catch (e) {
      print("Error updating event: $e");
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
      if (userId.isEmpty) return; // Exit if user is not authenticated

      // Step 2: Sync to Firebase
      var userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
      var eventsCollection = userDocRef.collection('events');

      if (event.firebaseId == null) {
        // New event, add it to Firebase
        var docRef = await eventsCollection.add(event.toMap());
        event.firebaseId = docRef.id; // Assign the Firestore ID (firebaseId)
      } else {
        // Existing event, update it in Firebase
        await eventsCollection.doc(event.firebaseId).update(event.toMap());
      }

      // Step 3: After syncing to Firebase, update local SQLite with firebaseId
      await localdb.updateEvent(event); // Update the SQLite event with firebaseId

      print("Event successfully synced to Firebase.");
    } catch (e) {
      print("Error syncing event to Firebase: $e");
    }
  }


}
