import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/gift.dart';
import '../services/sqlite_service.dart';

class FriendGiftListPage extends StatefulWidget {
  final String eventName;
  final String firebaseEventId; // Firestore Event ID
  final String friendId; // Friend's User ID

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

  // Get the logged-in user's ID
  String get currentUserId => FirebaseAuth.instance.currentUser!.uid;

  // Pledge a gift
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${gift.name} has been pledged!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error pledging gift: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Purchase a gift
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffefefef),
      appBar: AppBar(
        backgroundColor: const Color(0xffefefef),
        title: Text(
          "${widget.eventName} Gifts",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
            return const Center(child: Text("No gifts available"));
          }

          // Convert Firestore documents to Gift objects
          List<Gift> gifts = snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return Gift.fromMap({
              ...data,
              'firebaseId': doc.id, // Ensure firebaseId is set
            });
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
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Category: ${gift.category ?? 'N/A'}\n"
                        "Price: \$${gift.price ?? 0.0}\n"
                        "Status: ${gift.status}",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pledge Button (if gift is Available)
                      if (gift.status == "available")
                        ElevatedButton(
                          onPressed: () => _pledgeGift(gift),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                          child: const Text("Pledge"),
                        ),

                      // Purchase Button (only visible if the user pledged the gift)
                      if (gift.status == "Pledged" && gift.pledgedBy == currentUserId)
                        ElevatedButton(
                          onPressed: () => _purchaseGift(gift),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text("Purchase"),
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
