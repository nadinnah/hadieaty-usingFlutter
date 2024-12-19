import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  }//NOT USED

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
  }//NOT USED

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
  Future<void> syncGiftToFirebase(Gift gift) async {
    try {
      DocumentReference giftRef;

      if (gift.firebaseId.isEmpty) {
        // Add new gift to Firestore
        var eventDocRef = FirebaseFirestore.instance.collection('Events').doc(gift.eventId);
        giftRef = await eventDocRef.collection('gifts').add({
          'name': gift.name,
          'description': gift.description,
          'category': gift.category,
          'price': gift.price,
          'imageUrl': gift.imageUrl,
          'status': gift.status,
          'eventId': gift.eventId,
          'pledgedBy': gift.pledgedBy,
          'createdBy': gift.createdBy,
          // 'syncStatus' is excluded here
        });

        gift.firebaseId = giftRef.id;

        // Update local database with Firestore ID
        await localdb.updateGift(gift);
      } else {
        // Update existing gift in Firestore
        var eventDocRef = FirebaseFirestore.instance.collection('Events').doc(gift.eventId);
        giftRef = eventDocRef.collection('gifts').doc(gift.firebaseId);

        await giftRef.update({
          'name': gift.name,
          'description': gift.description,
          'category': gift.category,
          'price': gift.price,
          'imageUrl': gift.imageUrl,
          'status': gift.status,
          'eventId': gift.eventId,
          'pledgedBy': gift.pledgedBy,
          'createdBy': gift.createdBy,
          // 'syncStatus' is excluded here
        });
      }
      // Mark as synced locally
      gift.syncStatus = "Synced";
      await localdb.updateGift(gift);

      print("Gift successfully synced to Firestore.");
    } catch (e) {
      print("Error syncing gift to Firestore: $e");
    }
  }

}
