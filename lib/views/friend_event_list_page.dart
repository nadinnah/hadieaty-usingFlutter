import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hadieaty/models/event.dart';
import 'friend_gift_list_page.dart';  // Import FriendGiftListPage

class FriendEventListPage extends StatelessWidget {
  final List<Event> events;
  final String friendName;
  final String friendId; // Add friendId

  FriendEventListPage({
    required this.events,
    required this.friendName,
    required this.friendId, // Include friendId as a required parameter
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffefefef),
      appBar: AppBar(
        backgroundColor: const Color(0xffefefef),
        title: Text(
          "$friendName's Events",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Events')
            .where('createdBy', isEqualTo: friendId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No events available for $friendName."));
          }

          var events = snapshot.data!.docs.map((doc) {
            return Event.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              var event = events[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(event.name),
                  subtitle: Text(
                    "Location: ${event.location}\n"
                        "Status: ${event.status}\n"
                        "Date: ${event.date}",
                    style: TextStyle(fontSize: 14),
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

