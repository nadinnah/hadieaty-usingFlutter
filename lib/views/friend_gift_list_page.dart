import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/gift.dart';

class FriendGiftListPage extends StatefulWidget {
  final String eventName;
  final int eventId; // Event ID for fetching related gifts
  final String friendId; // Friend's User ID

  FriendGiftListPage({
    required this.eventName,
    required this.eventId,
    required this.friendId,
  });

  @override
  _FriendGiftListPageState createState() => _FriendGiftListPageState();
}

class _FriendGiftListPageState extends State<FriendGiftListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xffefefef),
      appBar: AppBar(
        backgroundColor: Color(0xffefefef),
        title: Text(
          "${widget.eventName} Gifts",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(widget.friendId) // Use friend's User ID
                    .collection('events')
                    .doc(widget.eventId.toString()) // Use Event ID
                    .collection('gifts')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No gifts available"));
                  }

                  // Convert Firestore documents to Gift objects
                  List<Gift> gifts = snapshot.data!.docs.map((doc) {
                    return Gift.fromMap(doc.data() as Map<String, dynamic>);
                  }).toList();

                  return ListView.builder(
                    itemCount: gifts.length,
                    itemBuilder: (context, index) {
                      Gift gift = gifts[index];
                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        color: gift.status == "pledged"
                            ? Colors.red[100]
                            : Colors.green[100],
                        child: ListTile(
                          title: Text(gift.name),
                          subtitle: Text(
                            "Category: ${gift.category ?? 'N/A'}\nPrice: \$${gift.price ?? 0.0}\nStatus: ${gift.status}",
                            style: TextStyle(
                              color: gift.status == "pledged"
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                          trailing: gift.status == "pledged"
                              ? Icon(Icons.check_circle, color: Colors.green)
                              : Icon(Icons.circle, color: Colors.grey),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
