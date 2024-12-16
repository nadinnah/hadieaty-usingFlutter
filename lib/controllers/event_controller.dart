import '../models/event.dart';
import '../services/sqlite_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventController {
  final LocalDatabase localdb = LocalDatabase();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add an event to the local database (no immediate sync to Firestore)
  Future<bool> addEvent(Event event) async {
    try {
      event.syncStatus = false; // Mark as unsynced
      await localdb.insertEvent(event);
      return true;
    } catch (e) {
      print("Error adding event locally: $e");
      return false;
    }
  }

  // Fetch all events from the local database
  Future<List<Event>> getLocalEvents() async {
    try {
      var eventData = await localdb.getEvents();
      return eventData.map((event) => Event.fromMap(event)).toList();
    } catch (e) {
      print("Error fetching local events: $e");
      return [];
    }
  }

  Future<bool> updateEvent(Event event, String userId) async {
    bool success = false;
    try {
      // Update Firebase
      var eventDocRef = _firestore
          .collection('Users')
          .doc(userId)
          .collection('events')
          .doc(event.id.toString());

      await eventDocRef.update(event.toMap());

      // Update locally in SQLite
      success = await localdb.updateEvent(event);
    } catch (e) {
      print('Error updating event: $e');
    }
    return success;
  }

  // Delete an event from the local database
  Future<void> deleteLocalEvent(int eventId, String userId) async {
    try {
      // Delete from SQLite
      await localdb.deleteEvent(eventId);

      // Delete from Firestore
      var eventDocRef = _firestore
          .collection('Users')
          .doc(userId)
          .collection('events')
          .doc(eventId.toString());
      await eventDocRef.delete();
    } catch (e) {
      print("Error deleting event: $e");
    }
  }


  Future<void> publishEventsToFirebase(String userId, List<Event> events) async {
    try {
      if (userId.isEmpty) {
        print("User ID is empty, unable to publish events.");
        return; // Prevent publishing if userId is invalid
      }

      for (var event in events) {
        if (event.id == null || event.id == 0) {
          // Add new event to Firebase and let Firestore generate the ID
          var userDocRef = _firestore.collection('Users').doc(userId);
          var docRef = await userDocRef.collection('events').add({
            'name': event.name,
            'date': event.date,
            'location': event.location,
            'description': event.description,
            'createdBy': userId,
            'createdAt': FieldValue.serverTimestamp(),
          });

          // Use the Firestore auto-generated ID
          event.id = docRef.id as int?; // Store the Firebase document ID as a string

          // Update SQLite with Firebase ID
          await localdb.updateEvent(event); // Ensure this updates SQLite correctly
        } else {
          // Check if the event document exists
          var eventDocRef = _firestore.collection('Users').doc(userId).collection('events').doc(event.id.toString());
          var docSnapshot = await eventDocRef.get();

          if (!docSnapshot.exists) {
            // If event doesn't exist, handle it accordingly (e.g., create it)
            print("Event does not exist, creating new event document.");
            await eventDocRef.set(event.toMap()); // Create new event document if it doesn't exist
          } else {
            // Update existing event
            await eventDocRef.update(event.toMap());
          }

          event.syncStatus = true;
          await localdb.updateEvent(event);
        }
      }
    } catch (e) {
      print('Error publishing events: $e');
    }
  }



}
