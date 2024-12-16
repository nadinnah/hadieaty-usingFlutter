import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:flutter/material.dart';
import 'package:hadieaty/models/event.dart';
import 'package:hadieaty/controllers/event_controller.dart';
import 'add_event.dart';
import 'gift_list_page.dart';
import 'package:intl/intl.dart'; // Import for date formatting

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
  bool _isLoading = false; // Loading state

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
    setState(() {
      _isLoading = true; // Show loading indicator
    });
    var events = await _controller.getLocalEvents();
    setState(() {
      _eventsList = events;
      _isLoading = false; // Hide loading indicator
    });
  }

  Future<void> _deleteEvent(String eventId) async {
    bool? confirm = await _confirmDeleteEvent(eventId);
    if (confirm == true) {
      try {
        // Get the current authenticated user's ID
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception("User not authenticated");
        }

        await _controller.deleteLocalEvent(int.parse(eventId), user.uid);
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
  }

  Future<bool?> _confirmDeleteEvent(String eventId) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Event"),
        content: Text("Are you sure you want to delete this event?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Delete"),
          ),
        ],
      ),
    );
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
    setState(() {
      _isLoading = true; // Show loading indicator
    });
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



    } catch (e) {
      print('Error publishing events: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error publishing events."),
      ));
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  String formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('MMMM dd, yyyy').format(parsedDate);
  }

  Widget _loadingIndicator() {
    return _isLoading ? CircularProgressIndicator() : Container();
  }

  Widget _emptyState() {
    return Center(
      child: Text(
        "No events found. Add a new event to get started!",
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
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
          SizedBox(height: 20,),
          _loadingIndicator(), // Show loading indicator if necessary
          SizedBox(height: 20,),
          Expanded(
            child: _eventsList.isEmpty
                ? _emptyState() // Show empty state if no events
                : ListView.builder(
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
                      "Category: ${event.category}\nStatus: ${event.status}\nCreated At: ${formatDate(event.createdAt)}",
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
