import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import '../models/event.dart';
import '../models/gift.dart';
import '../services/firebase_api.dart';
import '../services/sqlite_service.dart';

class GiftController {
  LocalDatabase localdb=LocalDatabase();


  //Deletes a gift from the local database and Firestore if synced.
  Future<void> deleteGift(Gift gift) async {
    try {
      await localdb.deleteGift(gift.id!);

      if (gift.syncStatus == "Synced" && gift.firebaseId.isNotEmpty) {
        var eventDocRef = FirebaseFirestore.instance.collection('Events').doc(gift.eventId);
        await eventDocRef.collection('gifts').doc(gift.firebaseId).delete();
      }
    } catch (e) {
      throw Exception("Failed to delete the gift.");
    }
  }

  //Syncs a gift to Firestore, either adding it as new or updating an existing one.
  Future<void> syncGiftToFirebase(Gift gift) async {
    try {
      DocumentReference giftRef;

      if (gift.firebaseId.isEmpty) {
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
        });

        gift.firebaseId = giftRef.id;

        await localdb.updateGift(gift);
      } else {
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
        });
      }

      gift.syncStatus = "Synced";
      await localdb.updateGift(gift);
    } catch (e) {
      throw Exception("Error syncing gift to Firestore.");
    }
  }

  /// Pledge a gift
  Future<void> pledgeGift(Gift gift, String currentUserId) async {

  try{
    var giftDocRef = FirebaseFirestore.instance
        .collection('Events')
        .doc(gift.eventId)
        .collection('gifts')
        .doc(gift.firebaseId);

    await giftDocRef.update({
      'status': 'Pledged',
      'pledgedBy': currentUserId,
    });

    // Notify gift owner
    final ownerDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(gift.createdBy)
        .get();
    if (ownerDoc.exists) {
      final ownerData = ownerDoc.data();
      String ownerName = ownerData?['name'] ?? "Gift Owner";
      String giftName = gift.name.isNotEmpty ? gift.name : "a gift";

      final currentUserDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUserId)
          .get();
      String currentUserName = currentUserDoc.data()?['name'] ?? "Someone";

      FirebaseApi().sendNotificationToUser(
        gift.createdBy,
        "Gift Pledged!",
        "$currentUserName pledged your gift: $giftName!",
      );
    }
  } catch (e) {
  throw Exception("Error pledging gift: $e");
  }
  }

  //Purchase a gift
  Future<void> purchaseGift(Gift gift, String currentUserId) async {
    try {
      if (gift.pledgedBy != currentUserId) {
        throw Exception("You can only purchase gifts you pledged.");
      }

      var giftDocRef = FirebaseFirestore.instance
          .collection('Events')
          .doc(gift.eventId)
          .collection('gifts')
          .doc(gift.firebaseId);

      await giftDocRef.update({'status': 'Purchased'});

      // Update local SQLite database
      gift.status = 'Purchased';
      await localdb.updateGift(gift);
      // Notify gift owner
      final ownerDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(gift.createdBy)
          .get();
      if (ownerDoc.exists) {
        final ownerData = ownerDoc.data();
        String ownerName = ownerData?['name'] ?? "Gift Owner";
        String giftName = gift.name.isNotEmpty ? gift.name : "a gift";

        final currentUserDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUserId)
            .get();
        String currentUserName = currentUserDoc.data()?['name'] ?? "Someone";

        FirebaseApi().sendNotificationToUser(
          gift.createdBy,
          "Gift Purchased!",
          "$currentUserName purchased your gift: $giftName!",
        );
      }
    } catch (e) {
      throw Exception("Error purchasing gift: $e");
    }
  }

  //Unpledge a gift
  Future<void> unpledgeGift(Gift gift, String currentUserId) async {
    try {
      if (gift.pledgedBy != currentUserId) {
        throw Exception("You can only unpledge gifts you pledged.");
      }

      var giftDocRef = FirebaseFirestore.instance
          .collection('Events')
          .doc(gift.eventId)
          .collection('gifts')
          .doc(gift.firebaseId);

      await giftDocRef.update({
        'status': 'available',
        'pledgedBy': null,
      });

      gift.status = 'available';
      gift.pledgedBy = null;
      await localdb.updateGift(gift);
      // Notify gift owner
      final ownerDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(gift.createdBy)
          .get();
      if (ownerDoc.exists) {
        final ownerData = ownerDoc.data();
        String ownerName = ownerData?['name'] ?? "Gift Owner";
        String giftName = gift.name.isNotEmpty ? gift.name : "a gift";

        final currentUserDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUserId)
            .get();
        String currentUserName = currentUserDoc.data()?['name'] ?? "Someone";

        FirebaseApi().sendNotificationToUser(
          gift.createdBy,
          "Gift unpledged :(",
          "$currentUserName unpledged your gift: $giftName",
        );
      }
    } catch (e) {
      throw Exception("Error unpledging gift: $e");
    }
  }
}
