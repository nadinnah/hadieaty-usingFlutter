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
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          var event = events[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(event.name),
              subtitle: Text(
                "Category: ${event.category}\nStatus: ${event.status}\nCreated At: ${event.createdAt}",
                style: const TextStyle(fontSize: 14),
              ),
              onTap: () {
                // Navigate to FriendGiftListPage with friendId
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FriendGiftListPage(
                      eventName: event.name,
                      eventId: event.id!, // Use event ID to fetch related gifts
                      friendId: friendId, // Pass the friend's ID
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
