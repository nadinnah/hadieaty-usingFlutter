import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:flutter/material.dart';
import 'package:hadieaty/models/event.dart';
import 'package:hadieaty/controllers/event_controller.dart';
import 'package:hadieaty/views/user_gift_list_page.dart';
import 'add_event.dart';
import 'friend_gift_list_page.dart';
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
    _loadEvents();
  }

  Future<void> _addEvent() async {
    bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEventPage()),
    );

    if (result == true) { // Reload events after returning
      await _loadEvents();
    }
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);

    var events = await _controller.getEventsForCurrentUser();

    setState(() {
      _eventsList = events;
      _isLoading = false;
    });
  }



  Future<bool?> _confirmDeleteEvent(String eventName) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Event"),
        content: Text("Are you sure you want to delete the event \"$eventName\"?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancel
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Confirm
            child: Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }




  void _searchEvents(String query) {
    setState(() {
      _searchQuery = query;
      _eventsList = _eventsList
          .where((event) => event.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      _applySorting();
    });
  }


  Future<void> _publishSingleEvent(Event event) async {
    try {
      await _controller.syncEventToFirebase(event); // Sync changes to Firebase
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Event '${event.name}' published successfully!")),
      );
      await _loadEvents(); // Refresh events to reflect updated status
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to publish event '${event.name}'. Please try again.")),
      );
      print("Error publishing event: $e");
    }
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
        "No events found. Click 'Add New Event' to get started!",
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

            ],
          ),
          SizedBox(height: 20),
          _loadingIndicator(), // Show loading indicator if necessary
          SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _eventsList.isEmpty
                ? _emptyState()
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
                      onPressed: () async {
                        bool? result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddEventPage(event: event)),
                        );
                        if (result == true) await _loadEvents(); // Reload events
                      },
                    ),
                    title: Text(event.name),
                    subtitle: Text(
                      "Location: ${event.location}\n"
                          "Status: ${event.status}\n"
                          "Date: ${event.date}",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!event.syncStatus)
                          ElevatedButton(
                            onPressed: () async {
                              await _publishSingleEvent(event);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Publish"),
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            bool? confirm = await _confirmDeleteEvent(event.name);
                            if (confirm == true) {
                              await _controller.deleteEvent(event);
                              await _loadEvents();
                            }
                          },
                        ),
                      ],
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
