import '../models/event.dart';
import '../services/sqlite_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class EventController {
  final LocalDatabase localdb = LocalDatabase();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if the device is online
  Future<bool> isOnline() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile;
  }

  // Add an event to the local database and mark it as unsynced
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

  // Update an event in the local database
  Future<void> updateLocalEvent(Event event) async {
    try {
      await localdb.updateEvent(event);
    } catch (e) {
      print("Error updating event locally: $e");
    }
  }

  // Delete an event from the local database
  Future<void> deleteLocalEvent(int eventId) async {
    try {
      await localdb.deleteEvent(eventId);
    } catch (e) {
      print("Error deleting event locally: $e");
    }
  }

  // Add an event to Firestore and update its sync status locally
  Future<void> addEventToFirestore(String userId, Event event) async {
    try {
      DocumentReference userDoc = _firestore.collection('Users').doc(userId);
      DocumentReference eventDoc =
      await userDoc.collection('events').add(event.toMap());

      event.id = int.tryParse(eventDoc.id) ?? 0; // Use Firestore document ID
      event.syncStatus = true; // Mark as synced
      await updateLocalEvent(event); // Update sync status in local DB
    } catch (e) {
      print("Error adding event to Firestore: $e");
    }
  }

  // Fetch events for a specific user from Firestore
  Future<List<Event>> getFirestoreEvents(String userId) async {
    try {
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
    } catch (e) {
      print("Error fetching Firestore events: $e");
      return [];
    }
  }

  // Update an existing event in Firestore and mark it as synced locally
  Future<void> updateEventInFirestore(String userId, Event event) async {
    try {
      DocumentReference eventDoc = _firestore
          .collection('Users')
          .doc(userId)
          .collection('events')
          .doc(event.id.toString());

      await eventDoc.update(event.toMap());

      event.syncStatus = true; // Mark as synced
      await updateLocalEvent(event);
    } catch (e) {
      print("Error updating event in Firestore: $e");
    }
  }

  // Delete an event from Firestore and local database
  Future<void> deleteEventFromFirestore(String userId, String eventId) async {
    try {
      await _firestore
          .collection('Users')
          .doc(userId)
          .collection('events')
          .doc(eventId)
          .delete();

      await deleteLocalEvent(int.parse(eventId));
    } catch (e) {
      print("Error deleting event from Firestore: $e");
    }
  }

  // Sync unsynced local events to Firestore
  Future<void> syncLocalToFirestore(String userId) async {
    if (!await isOnline()) {
      print("No internet connection. Sync postponed.");
      return;
    }

    List<Event> unsyncedEvents = (await getLocalEvents())
        .where((event) => !event.syncStatus)
        .toList();

    for (var event in unsyncedEvents) {
      try {
        await addEventToFirestore(userId, event);
        print("Event synced to Firestore: ${event.name}");
      } catch (e) {
        print("Error syncing event to Firestore: $e");
      }
    }
  }

  Future<bool> updateEvent(Event event) async {
    try {
      // Update Firebase
      if (event.id != null) {
        await _firestore.collection('events').doc(event.id.toString()).update(event.toMap());
      }

      // Update SQLite
      await localdb.updateEvent(event);
      return true;
    } catch (e) {
      print("Error updating event: $e");
      return false;
    }
  }
  // Sync events from Firestore to the local database
  Future<void> syncFirestoreToLocal(String userId) async {
    try {
      List<Event> firestoreEvents = await getFirestoreEvents(userId);
      List<Event> localEvents = await getLocalEvents();

      for (var firestoreEvent in firestoreEvents) {
        var existingEvent = localEvents.firstWhere(
              (event) => event.id == firestoreEvent.id,
          orElse: () => Event.empty,
        );

        if (existingEvent.id == 0 || !existingEvent.syncStatus) {
          await addEvent(firestoreEvent);
        }
      }
    } catch (e) {
      print("Error syncing Firestore events to local: $e");
    }
  }
}
