import 'package:flutter/material.dart';
import 'package:hadieaty/models/event.dart';
import 'package:hadieaty/controllers/event_controller.dart';
import 'add_event.dart';
import 'gift_list_page.dart';

class UserEventListPage extends StatefulWidget {
  final List<Event> events;
  final String userId;
  final Function(List<Event>) onEventsUpdated;

  UserEventListPage({
    required this.events,
    required this.userId,
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
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      if (await _controller.isOnline()) {
        await _controller.syncFirestoreToLocal(widget.userId);
      }
      var events = await _controller.getLocalEvents();
      setState(() {
        _eventsList = events;
      });
    } catch (e) {
      print("Error loading events: $e");
    }
  }

  Future<void> _addEvent() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEventPage()),
    );
    _loadEvents();
    widget.onEventsUpdated(_eventsList);
  }

  Future<void> _deleteEvent(String eventId) async {
    try {
      if (await _controller.isOnline()) {
        await _controller.deleteEventFromFirestore(widget.userId, eventId);
      } else {
        await _controller.deleteLocalEvent(int.parse(eventId));
      }
      _loadEvents();
      widget.onEventsUpdated(_eventsList);
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
    _loadEvents();
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
          ElevatedButton(
            onPressed: _addEvent,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xff273331),
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Add New Event',
              style: TextStyle(fontSize: 18),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _eventsList.length,
              itemBuilder: (context, index) {
                var event = _eventsList[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GiftListPage(
                            eventName: event.name,
                            isOwnEvent: true,
                            eventId: event.id!,
                          ),
                        ),
                      );
                    },
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
