import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hadieaty/models/event.dart';
import 'friend_gift_list_page.dart';
import 'package:provider/provider.dart';
import '../services/shared_preference.dart';

class FriendEventListPage extends StatelessWidget {
  final List<Event> events;
  final String friendName;
  final String friendId;

  FriendEventListPage({
    required this.events,
    required this.friendName,
    required this.friendId,
  });

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
          "$friendName's Events",
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
            .where('createdBy', isEqualTo: friendId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No events available for $friendName.",
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              ),
            );
          }

          var events = snapshot.data!.docs.map((doc) {
            return Event.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                var event = events[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: isDarkMode ? const Color(0xffcfcfcf) : Color(0xecfffffc),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FriendGiftListPage(
                            firebaseEventId: event.firebaseId!,
                            eventName: event.name,
                            friendId: friendId,
                          ),
                        ),
                      );
                    },
                    title: Text(
                      event.name,
                      style: TextStyle(color:  Colors.black),
                    ),
                    subtitle: Text(
                      "Location: ${event.location}\n"
                          "Status: ${event.status}\n"
                          "Date: ${event.date}",
                      style: TextStyle(color: Colors.black),
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
