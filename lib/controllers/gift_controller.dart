import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/gift.dart';
import '../services/sqlite_service.dart';

class GiftController {
  final LocalDatabase localdb;

  GiftController({required this.localdb});

  // Add a new gift (local database + Firebase sync)
  Future<void> addGift(Gift gift) async {
    try {
      // First, insert the gift locally with syncStatus = false
      gift.syncStatus = false;
      await localdb.insertGift(gift);

      // Then, sync with Firebase if not already synced
      if (gift.syncStatus == false) {
        await _publishGiftToFirebase(gift);
      }
    } catch (e) {
      print("Error adding gift: $e");
    }
  }

  // Publish a gift to Firebase and update the syncStatus
  Future<void> _publishGiftToFirebase(Gift gift) async {
    try {
      var userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        print("User not authenticated");
        return;
      }

      var userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
      var eventDocRef = userDocRef.collection('events').doc(gift.eventId.toString());

      // Add the gift to Firebase
      var docRef = await eventDocRef.collection('gifts').add(gift.toMap());

      // Once published, update the gift's id and syncStatus
      gift.id = docRef.id as int?;
      gift.syncStatus = true;

      // Update the local database with the new sync status
      await localdb.updateGift(gift);
    } catch (e) {
      print("Error publishing gift to Firebase: $e");
    }
  }

  // Fetch all gifts for a specific event from the local database
  Future<List<Object>> fetchGiftsForEvent(int eventId) async {
    try {
      return await localdb.getGiftsForEvent(eventId);
    } catch (e) {
      print("Error fetching gifts from local database: $e");
      return [];
    }
  }

  // Unified method to delete the gift from both local database and Firebase
  Future<void> deleteGift(Gift gift) async {
    try {
      // Delete the gift from the local database
      await localdb.deleteGift(gift.id!);

      // If the gift is synced, delete it from Firebase as well
      if (gift.syncStatus == true) {
        var userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId == null) {
          print("User not authenticated");
          return;
        }

        var userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
        var eventDocRef = userDocRef.collection('events').doc(gift.eventId.toString());

        // Delete the gift from Firebase
        await eventDocRef.collection('gifts').doc(gift.id as String?).delete();
      }
    } catch (e) {
      print("Error deleting gift: $e");
    }
  }

  // Unified method to update the gift in both local database and Firebase
  Future<void> updateGift(Gift gift) async {
    try {
      // Update the gift in local database
      await localdb.updateGift(gift);

      // If gift is synced, update it in Firebase as well
      if (gift.syncStatus == true) {
        var userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId == null) {
          print("User not authenticated");
          return;
        }

        var userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
        var eventDocRef = userDocRef.collection('events').doc(gift.eventId.toString());

        // Reference the gift in Firebase and update it
        await eventDocRef.collection('gifts').doc(gift.id as String?).update(gift.toMap());
      }
    } catch (e) {
      print("Error updating gift: $e");
    }
  }
}
