import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Import FirebaseAuth
import 'package:flutter/material.dart';
import 'package:hadieaty/models/event.dart';
import 'package:hadieaty/controllers/event_controller.dart';
import 'add_event.dart';
import 'gift_list_page.dart';

class UserEventListPage extends StatefulWidget {
  final List<Event> events;
  final Function(List<Event>) onEventsUpdated;

  UserEventListPage({
    required this.events,
    required this.onEventsUpdated,
  });

  @override
  _UserEventListPageState createState() => _UserEventListPageState();
}

class _UserEventListPageState extends State<UserEventListPage> {
  final EventController _controller = EventController();
  late List<Event> _eventsList;
  String _searchQuery = "";
  String _sortOption = 'Name';

  @override
  void initState() {
    super.initState();
    _eventsList = widget.events;
  }

  Future<void> _addEvent() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEventPage()),
    );
    await _loadEvents();
    widget.onEventsUpdated(_eventsList); // Notify parent widget of updates
  }

  Future<void> _loadEvents() async {
    var events = await _controller.getLocalEvents();
    setState(() {
      _eventsList = events;
    });
  }

  Future<void> _deleteEvent(String eventId) async {
    try {
      await _controller.deleteLocalEvent(int.parse(eventId));
      await _loadEvents(); // Reload events after deletion
      widget.onEventsUpdated(_eventsList); // Notify parent widget
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Event deleted successfully"),
      ));
    } catch (e) {
      print("Error deleting event: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to delete event"),
      ));
    }
  }

  void _editEvent(Event event) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEventPage(event: event)),
    );
    await _loadEvents();
  }

  void _searchEvents(String query) {
    setState(() {
      _searchQuery = query;
      _eventsList = widget.events
          .where((event) =>
          event.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      _applySorting();
    });
  }

  void _sortEvents(String option) {
    setState(() {
      _sortOption = option;
      _applySorting();
    });
  }

  void _applySorting() {
    switch (_sortOption) {
      case 'Name':
        _eventsList.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Category':
        _eventsList.sort((a, b) => a.category.compareTo(b.category));
        break;
      case 'Status':
        _eventsList.sort((a, b) => a.status.compareTo(b.status));
        break;
    }
  }

  Future<void> _publishEventsToFirebase() async {
    try {
      // Get the current authenticated user's uid
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("User is not authenticated."),
        ));
        return; // Prevent publishing if user is not authenticated
      }

      String userId = user.uid;  // Get the authenticated user's uid

      // Check if the user document exists
      DocumentReference userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
      var docSnapshot = await userDocRef.get();

      // If the user document doesn't exist, create it
      if (!docSnapshot.exists) {
        await userDocRef.set({
          'uid': userId,  // Add basic user data (optional)
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Now publish the events
      await _controller.publishEventsToFirebase(userId, _eventsList);

      // Optionally update the user's events in Firebase or perform any post-publish actions
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Events published to Firebase!"),
      ));

      // Notify parent widget to refresh the event list (if needed)
      widget.onEventsUpdated(_eventsList);

    } catch (e) {
      print('Error publishing events: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error publishing events."),
      ));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffefefef),
      appBar: AppBar(
        backgroundColor: const Color(0xffefefef),
        title: const Text(
          'My Events',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: _sortEvents,
            itemBuilder: (context) => [
              PopupMenuItem(value: 'Name', child: Text('Sort by Name')),
              PopupMenuItem(value: 'Category', child: Text('Sort by Category')),
              PopupMenuItem(value: 'Status', child: Text('Sort by Status')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search Events',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _searchEvents,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _addEvent,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xff273331),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add New Event',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: _publishEventsToFirebase,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xff273331),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Publish Events to Firebase',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _eventsList.length,
              itemBuilder: (context, index) {
                var event = _eventsList[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: ListTile(
                    leading: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editEvent(event),
                    ),
                    title: Text(event.name),
                    subtitle: Text(
                      "Category: ${event.category}\nStatus: ${event.status}\nCreated At: ${event.createdAt}",
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteEvent(event.id.toString()),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
