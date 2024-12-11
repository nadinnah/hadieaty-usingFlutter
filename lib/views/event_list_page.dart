import 'package:flutter/material.dart';
import 'package:hadieaty/models/event.dart';
import 'package:hadieaty/controllers/event_controller.dart'; // Import Event Controller
import 'add_event.dart';
import 'gift_list_page.dart'; // Add Event Page

class EventListPage extends StatefulWidget {
  final String friendName; // The name of the friend whose events we will show
  final bool isOwnEvents; // Flag to indicate whether the events belong to the user
  final List<Event> events; // List of events to be displayed

  EventListPage(
      {required this.friendName,
        required this.isOwnEvents,
        required this.events});

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final EventController _controller = EventController();
  List<Event> _eventsList = [];
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _eventsList = widget.events;
  }

  // Fetch events from SQLite database
  void _fetchEvents() async {
    List<Event> events = await _controller.getEvents();
    setState(() {
      _eventsList = events;
    });
  }

  // Add a new event
  void _addEvent() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEventPage()), // Navigate to Add Event Page
    );
    _fetchEvents(); // Re-fetch events after adding a new one
  }

  // Delete an event
  void _deleteEvent(int eventId) async {
    await _controller.deleteEvent(eventId);
    _fetchEvents(); // Re-fetch events after deletion
  }

  // Edit an event
  void _editEvent(Event event) async {
    await Navigator.pushNamed(
        context, '/addEvent'); // Navigate to Add Event Page

    _fetchEvents(); // Re-fetch events after editing
  }

  // Search events by name
  void _searchEvents(String query) {
    setState(() {
      _searchQuery = query;
      _eventsList = _eventsList
          .where((event) =>
          event.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xffefefef),
      appBar: AppBar(
        backgroundColor: Color(0xffefefef),
        title: Text(
          widget.isOwnEvents ? '${widget.friendName}' : '${widget.friendName}\'s Events',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Search Events',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _searchEvents,
                  ),
                ),
                SizedBox(height: 10),

                // Sort buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => _sortEventsByName(),
                      child: Text('by Name'),
                    ),
                    ElevatedButton(
                      onPressed: () => _sortEventsByCategory(),
                      child: Text('by Category'),
                    ),
                    ElevatedButton(
                      onPressed: () => _sortEventsByStatus(),
                      child: Text('by Status'),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                // Add event button
                if (widget.isOwnEvents)
                  ElevatedButton(
                    onPressed: _addEvent,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xff273331),
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Add New Event', style: TextStyle(fontSize: 18)),
                  ),
                SizedBox(height: 10),

                // Event list
                Expanded(
                  child: ListView.builder(
                    itemCount: _eventsList.length,
                    itemBuilder: (context, index) {
                      var event = _eventsList[index];
                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: widget.isOwnEvents
                              ? IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editEvent(event),
                          )
                              : null,
                          title: Text(event.name),
                          subtitle: Text(
                            "Category: ${event.category}\nStatus: ${event.status}\nCreated At: ${event.createdAt}",
                            style: TextStyle(fontSize: 14),
                          ),
                          trailing: widget.isOwnEvents
                              ? IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteEvent(event.id!),
                          )
                              : null,
                          onTap: () {
                            // Navigate to the Gift List Page and pass data
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GiftListPage(
                                  eventName: event.name,
                                  isOwnEvent: widget.isOwnEvents,
                                  eventId: event.id!, // Safe to pass because it's no longer null
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
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              child: Image.asset(
                'lib/assets/images/giftBoxes.png',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Sort by name
  void _sortEventsByName() {
    setState(() {
      _eventsList.sort((a, b) => a.name.compareTo(b.name));
    });
  }

  // Sort by category
  void _sortEventsByCategory() {
    setState(() {
      _eventsList.sort((a, b) => a.category.compareTo(b.category));
    });
  }

  // Sort by status
  void _sortEventsByStatus() {
    setState(() {
      _eventsList.sort((a, b) => a.status.compareTo(b.status));
    });
  }
}
