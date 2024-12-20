import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firebase_api.dart';
import '../models/gift.dart';
import '../services/sqlite_service.dart';
import 'package:provider/provider.dart';
import '../services/shared_preference.dart';

class FriendGiftListPage extends StatefulWidget {
  final String eventName;
  final String firebaseEventId;
  final String friendId;

  FriendGiftListPage({
    required this.eventName,
    required this.firebaseEventId,
    required this.friendId,
  });

  @override
  _FriendGiftListPageState createState() => _FriendGiftListPageState();
}

class _FriendGiftListPageState extends State<FriendGiftListPage> {
  final LocalDatabase _localDatabase = LocalDatabase();
  bool _isLoading = false;

  String get currentUserId => FirebaseAuth.instance.currentUser!.uid;

  Future<void> _pledgeGift(Gift gift) async {
    try {
      setState(() => _isLoading = true);

      var giftDocRef = FirebaseFirestore.instance
          .collection('Events')
          .doc(widget.firebaseEventId)
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error pledging gift: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _purchaseGift(Gift gift) async {
    try {
      setState(() => _isLoading = true);

      if (gift.pledgedBy != currentUserId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You can only purchase gifts you pledged.")),
        );
        return;
      }

      var giftDocRef = FirebaseFirestore.instance
          .collection('Events')
          .doc(widget.firebaseEventId)
          .collection('gifts')
          .doc(gift.firebaseId);

      await giftDocRef.update({'status': 'Purchased'});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${gift.name} has been purchased!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error purchasing gift: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _unpledgeGift(Gift gift) async {
    try {
      setState(() => _isLoading = true);

      if (gift.pledgedBy != currentUserId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You can only unpledge gifts you pledged.")),
        );
        return;
      }

      var giftDocRef = FirebaseFirestore.instance
          .collection('Events')
          .doc(widget.firebaseEventId)
          .collection('gifts')
          .doc(gift.firebaseId);

      await giftDocRef.update({
        'status': 'Available',
        'pledgedBy': null,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${gift.name} has been unpledged!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error unpledging gift: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var preferences = Provider.of<PreferencesService>(context);
    var isDarkMode = preferences.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xff1e1e1e) : const Color(0xffefefef),
      appBar: AppBar(
        iconTheme: IconThemeData(color: preferences.isDarkMode ? Colors.white : Colors.black),
        backgroundColor: isDarkMode ? const Color(0xff1e1e1e) : const Color(0xffefefef),
        title: Text(
          "${widget.eventName} Gifts",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Events')
            .doc(widget.firebaseEventId)
            .collection('gifts')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No gifts available",
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              ),
            );
          }

          List<Gift> gifts = snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;

            return Gift(
              id: null,
              firebaseId: doc.id,
              name: data['name'] ?? 'Unknown',
              description: data['description'],
              category: data['category'],
              price: (data['price'] as num?)?.toDouble(),
              imageUrl: data['imageUrl'],
              status: data['status'] ?? 'available',
              eventId: widget.firebaseEventId,
              syncStatus: 'Synced',
              pledgedBy: data['pledgedBy'],
              createdBy: data['createdBy'] ?? '',
            );
          }).toList();

          return ListView.builder(
            itemCount: gifts.length,
            itemBuilder: (context, index) {
              Gift gift = gifts[index];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                color: gift.status == "Pledged"
                    ? Colors.orange[100]
                    : gift.status == "Purchased"
                    ? Colors.green[100]
                    : Colors.blue[100],
                child: ListTile(
                  title: Text(
                    gift.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.black : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    "Category: ${gift.category ?? 'N/A'}\n"
                        "Price: \$${gift.price ?? 0.0}\n"
                        "Status: ${gift.status}",
                    style: TextStyle(color: isDarkMode ? Colors.grey : Colors.black),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (gift.status == "available")
                        ElevatedButton(
                          onPressed: () => _pledgeGift(gift),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDarkMode ? Colors.blueGrey : Colors.blue,
                          ),
                          child: const Text("Pledge"),
                        ),
                      if (gift.status == "Pledged" && gift.pledgedBy == currentUserId)
                        ElevatedButton(
                          onPressed: () => _purchaseGift(gift),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDarkMode ? Colors.greenAccent : Colors.green,
                          ),
                          child: const Text("Purchase"),
                        ),
                      if (gift.status == "Pledged" && gift.pledgedBy == currentUserId)
                        ElevatedButton(
                          onPressed: () => _unpledgeGift(gift),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDarkMode ? Colors.redAccent : Colors.red,
                          ),
                          child: const Text("Unpledge"),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
