import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/gift.dart';
import '../services/sqlite_service.dart';

class GiftController {
  final LocalDatabase localdb;

  GiftController({required this.localdb});

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
