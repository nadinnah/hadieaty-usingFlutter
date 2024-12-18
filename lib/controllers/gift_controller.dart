import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gift.dart';
import '../services/sqlite_service.dart';

class GiftController {
  final LocalDatabase localdb;

  GiftController({required this.localdb});

  // Pledge a gift
  Future<void> pledgeGift(Gift gift, String userId) async {
    if (gift.status != "Available") {
      throw Exception("Gift is not available for pledging.");
    }

    try {
      gift.status = "Pledged";
      gift.pledgedBy = userId;

      // Update locally
      await localdb.updateGift(gift);

      // Sync with Firestore if already published
      if (gift.firebaseId.isNotEmpty) {
        var eventDocRef = FirebaseFirestore.instance.collection('Events').doc(gift.eventId);
        var giftDocRef = eventDocRef.collection('gifts').doc(gift.firebaseId);

        await giftDocRef.update({
          'status': "Pledged",
          'pledgedBy': userId,
        });
      }
    } catch (e) {
      print("Error pledging gift: $e");
      throw Exception("Failed to pledge the gift.");
    }
  }

  // Purchase a gift
  Future<void> purchaseGift(Gift gift, String userId) async {
    if (gift.status != "Pledged") {
      throw Exception("Gift must be pledged before it can be purchased.");
    }

    if (gift.pledgedBy != userId) {
      throw Exception("Only the user who pledged the gift can purchase it.");
    }

    try {
      gift.status = "Purchased";

      // Update locally
      await localdb.updateGift(gift);

      // Sync with Firestore if already published
      if (gift.firebaseId.isNotEmpty) {
        var eventDocRef = FirebaseFirestore.instance.collection('Events').doc(gift.eventId);
        var giftDocRef = eventDocRef.collection('gifts').doc(gift.firebaseId);

        await giftDocRef.update({
          'status': "Purchased",
        });
      }
    } catch (e) {
      print("Error purchasing gift: $e");
      throw Exception("Failed to purchase the gift.");
    }
  }

  Future<void> deleteGift(Gift gift) async {
    try {
      // Delete the gift from the local database
      await localdb.deleteGift(gift.id!);

      // If synced, delete the gift from Firestore
      if (gift.syncStatus == "Synced" && gift.firebaseId.isNotEmpty) {
        var eventDocRef = FirebaseFirestore.instance.collection('Events').doc(gift.eventId);
        await eventDocRef.collection('gifts').doc(gift.firebaseId).delete();
      }

      print("${gift.name} deleted successfully.");
    } catch (e) {
      print("Error deleting gift: $e");
      throw Exception("Failed to delete the gift.");
    }
  }
  // Sync a gift to Firestore and update locally
  Future<void> syncGiftToFirebase(Gift gift) async {
    try {
      DocumentReference giftRef;

      if (gift.firebaseId.isEmpty) {
        // Add new gift to Firestore
        var eventDocRef = FirebaseFirestore.instance.collection('Events').doc(gift.eventId);
        giftRef = await eventDocRef.collection('gifts').add(gift.toMap());
        gift.firebaseId = giftRef.id; // Save Firestore ID
      } else {
        // Update existing gift in Firestore
        var eventDocRef = FirebaseFirestore.instance.collection('Events').doc(gift.eventId);
        giftRef = eventDocRef.collection('gifts').doc(gift.firebaseId);
        await giftRef.update(gift.toMap());
      }

      // Mark as synced locally
      gift.syncStatus = "Synced";
      await localdb.updateGift(gift);

      print("Gift successfully synced to Firestore.");
    } catch (e) {
      print("Error syncing gift to Firestore: $e");
      throw Exception("Failed to sync gift.");
    }
  }
}
