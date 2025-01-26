import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../controllers/gift_controller.dart';
import '../models/event.dart';
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
  final GiftController _giftController = GiftController();
  bool _isLoading = false;

  String get currentUserId => FirebaseAuth.instance.currentUser!.uid;

  Future<void> _handleGiftAction(Gift gift, String action) async {
    try {
      setState(() => _isLoading = true);

      if (action == 'pledge') {
        await _giftController.pledgeGift(gift, currentUserId);
      } else if (action == 'purchase') {
        await _giftController.purchaseGift(gift, currentUserId);
      } else if (action == 'unpledge') {
        await _giftController.unpledgeGift(gift, currentUserId);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
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
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
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
                          onPressed: () => _handleGiftAction(gift, 'pledge'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDarkMode ? Colors.blueGrey : Colors.blue,
                          ),
                          child: const Text("Pledge"),
                        ),
                      if (gift.status == "Pledged" && gift.pledgedBy == currentUserId)
                        ElevatedButton(
                          onPressed: () => _handleGiftAction(gift, 'purchase'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDarkMode ? Colors.greenAccent : Colors.green,
                          ),
                          child: const Text("Purchase"),
                        ),
                      if (gift.status == "Pledged" && gift.pledgedBy == currentUserId)
                        ElevatedButton(
                          onPressed: () => _handleGiftAction(gift, 'unpledge'),
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
