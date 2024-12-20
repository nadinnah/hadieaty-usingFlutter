import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hadieaty/models/event.dart';
import 'package:hadieaty/controllers/event_controller.dart';
import 'package:hadieaty/views/user_gift_list_page.dart';
import 'event_details_page.dart';
import 'package:intl/intl.dart';

class UserEventListPage extends StatefulWidget {

  final List<Event>? events;
  final Function(List<Event>)? onEventsUpdated;

  UserEventListPage({
    this.events,
    this.onEventsUpdated,
  });

  @override
  _UserEventListPageState createState() => _UserEventListPageState();
}

class _UserEventListPageState extends State<UserEventListPage> {
  final _formKey = GlobalKey<FormState>();
  final EventController eventController = EventController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<Event> eventsList = [];
  bool _isLoading = false;
  String _searchQuery = "";
  String sortOption = 'Name';

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  Future<void> loadEvents() async {
    setState(() => _isLoading = true);

    // Clear AnimatedList
    for (int i = eventsList.length - 1; i >= 0; i--) {
      _listKey.currentState?.removeItem(
        i,
            (context, animation) => _buildEventTile(eventsList[i], animation, i),
      );
    }

    // Load events
    var events = await eventController.getEventsForCurrentUser();
    setState(() {
      eventsList = events;
      _isLoading = false;
    });

    // Add events with animation
    for (int i = 0; i < eventsList.length; i++) {
      _listKey.currentState?.insertItem(i);
    }
  }

  void sortEvents(String option) {
    setState(() {
      sortOption = option;
      switch (sortOption) {
        case 'Name':
          eventsList.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'Category':
          eventsList.sort((a, b) => a.category.compareTo(b.category));
          break;
        case 'Status':
          eventsList.sort((a, b) {
            const statusOrder = {'Current': 0, 'Upcoming': 1, 'Past': 2};
            return statusOrder[a.status]!.compareTo(statusOrder[b.status]!);
          });
          break;
      }
    });
  }



  Future<void> publishEvent(Event event) async {
    try {
      await eventController.syncEventToFirebase(event);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Event '${event.name}' published successfully!")),
      );
      await loadEvents();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to publish event '${event.name}'.")),
      );
    }
  }

  confirmDeleteEvent(String eventName) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Event"),
        content:
        Text("Are you sure you want to delete the event \"$eventName\"?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> addEvent() async {
    bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEventPage()),
    );

    if (result == true) {
      await loadEvents();
    }
  }



  void removeEventAnimated(int index) {
    if (index < 0 || index >= eventsList.length) return; // Check for valid index
    final removedEvent = eventsList.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
          (context, animation) => _buildEventTile(removedEvent, animation, index),
    );
  }

  Widget _buildEventTile(Event event, Animation<double> animation, int index) {
    if (index < 0 || index >= eventsList.length) return SizedBox.shrink(); // Prevent invalid access
    return SlideTransition(
      position: animation.drive(
        Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeInOut)),
      ),
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserGiftListPage(
                  eventName: event.name,
                  firebaseEventId: event.firebaseId!,
                ),
              ),
            );
          },
          leading: IconButton(
            icon: const Icon(Icons.edit, color: Colors.green),
            onPressed: () async {
              bool? result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEventPage(event: event),
                ),
              );
              if (result == true) await loadEvents();
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
                  onPressed: () => publishEvent(event),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0x4C4CC1FF),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Publish"),
                ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  bool? confirm = await confirmDeleteEvent(event.name);
                  if (confirm == true) {
                    removeEventAnimated(index);
                    await eventController.deleteEvent(event);
                  }
                },
              ),
            ],
          ),
        ),
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
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                  eventsList = eventsList
                      .where((event) => event.name
                      .toLowerCase()
                      .contains(query.toLowerCase()))
                      .toList();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: addEvent,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xff273331),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Add New Event',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                DropdownButton<String>(
                  value: sortOption,
                  onChanged: (value) => sortEvents(value!),
                  items: [
                    DropdownMenuItem(value: 'Name', child: Text('Sort by Name')),
                    DropdownMenuItem(
                        value: 'Category', child: Text('Sort by Category')),
                    DropdownMenuItem(
                        value: 'Status', child: Text('Sort by Status')),
                  ],
                  underline: Container(),
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (eventsList.isEmpty)
            const Center(
              child: Text("No events found."),
            )
          else
            Expanded(
              child: AnimatedList(
                key: _listKey,
                initialItemCount: eventsList.length,
                itemBuilder: (context, index, animation) {
                  return _buildEventTile(eventsList[index], animation, index);
                },
              ),
            ),
        ],
      ),
    );
  }

}
