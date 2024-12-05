import 'package:flutter/material.dart';
import 'package:hadieaty/views/gift_list_page.dart';
import 'package:hadieaty/views/home_page.dart';
import '../controllers/event_controller.dart';  // Event Controller
import '../models/event.dart';
import 'add_event.dart';  // Event Model


class EventListPage extends StatefulWidget {
  final String friendName; // The name of the friend whose events we will show
  final bool isOwnEvents; // Flag to indicate whether the events belong to the user
  final List<Event> events;
  EventListPage({required this.friendName, required this.isOwnEvents, required this.events});
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  EventController _controller = EventController();

  List<Event> _eventsList = [];
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _eventsList = widget.events; // Use the events passed via the constructor
  }

  // Handle search functionality
  void _searchEvents(String query) {
    setState(() {
      _searchQuery = query;
      _eventsList = _controller.searchEvents(query);
    });
  }

  // Sort events by name
  void _sortEventsByName() {
    setState(() {
      _eventsList = _controller.sortByName();
    });
  }

  // Sort events by category
  void _sortEventsByCategory() {
    setState(() {
      _eventsList = _controller.sortByCategory();
    });
  }

  // Sort events by status
  void _sortEventsByStatus() {
    setState(() {
      _eventsList = _controller.sortByStatus();
    });
  }

  // Add a new event
  void _addEvent() async {
    // Wait for the new event to be added
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddEventPage()), // Navigate to Add Event Page
    );
  }
  // Delete an event
  void _deleteEvent(String eventName) {
    _controller.deleteEvent(eventName);
    setState(() {
      _eventsList = _controller.getEvents();
    });
  }

  // Edit an event
  void _editEvent(String oldName) {
    Event updatedEvent = Event(
      name: "Updated Event",
      description: "Updated event description.",
      date: "2025-02-01",
      location: "Updated Location",
      category: "Updated Category",
      status: "Current",
      createdAt: "2024-11-24", // New creation date
    );
    _controller.editEvent(oldName, updatedEvent);
    setState(() {
      _eventsList = _controller.getEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:widget.isOwnEvents?Text('${widget.friendName}'):Text('${widget.friendName}\'s Events'),

      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar
            TextField(
              decoration: InputDecoration(
                labelText: 'Search Events',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _searchEvents,
            ),
            SizedBox(height: 10),
            Row(children: [
              Text('Sort:')
            ],),

            // Sort buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _sortEventsByName,
                  child: Text('by Name'),
                ),
                ElevatedButton(
                  onPressed: _sortEventsByCategory,
                  child: Text('by Category'),
                ),
                ElevatedButton(
                  onPressed: _sortEventsByStatus,
                  child: Text('by Status'),
                ),
              ],
            ),

            SizedBox(height: 10),

            // Add event button
            if (widget.isOwnEvents)
              ElevatedButton(
                onPressed: _addEvent,
                child: Text('Add New Event'),
              ),

            SizedBox(height: 10),

            // Event list
            Expanded(
              child: ListView.builder(
                itemCount: widget.isOwnEvents?_eventsList.length: _eventsList.length,
                itemBuilder: (context, index) {
                  var event = _eventsList[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: widget.isOwnEvents
                          ? IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editEvent(event.name),
                          )
                          : null,
                      title: Text(event.name),
                      subtitle: Text(
                        "Category: ${event.category}\nStatus: ${event.status}\nCreated At: ${event.createdAt}",
                        style: TextStyle(fontSize: 14),
                      ),
                      trailing:widget.isOwnEvents
                          ? IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteEvent(event.name),
                          )
                          : null,
                      onTap:  () {
                        // Navigate to the Event List Page and pass data
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GiftListPage(eventName: event.name, isOwnEvent: widget.isOwnEvents)
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
    );
  }
}
