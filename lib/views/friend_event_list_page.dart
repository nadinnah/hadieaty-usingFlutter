import 'package:flutter/material.dart';
import 'package:hadieaty/models/event.dart';
import 'gift_list_page.dart';

class FriendEventListPage extends StatelessWidget {
  final List<Event> events;
  final String friendName;

  FriendEventListPage({
    required this.events,
    required this.friendName,
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GiftListPage(
                      eventName: event.name,
                      isOwnEvent: false,
                      eventId: event.id!,
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
