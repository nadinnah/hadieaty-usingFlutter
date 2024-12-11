import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hadieaty/controllers/event_controller.dart';
import 'package:hadieaty/models/event.dart';
import '../services/shared_preference.dart';
import 'add_event.dart';
import 'event_list_page.dart'; // Import Event List Page
import 'package:hadieaty/controllers/home_controller.dart'; // HomeController
import 'package:hadieaty/models/friend.dart'; // Friend Model
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // For theme and preferences

class HomePage extends StatefulWidget {
  final String name;
  HomePage({required this.name});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController _controller = HomeController();
  final EventController _eventController =
      EventController(); // Updated controller
  List<Friend> _friendsList = [];
  List<Event> _userEvents = [];
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadUserEvents(); // Load events from SQLite on initialization
    _friendsList = _controller.getFriends(); // Get list of friends
  }

  // Load events for the user
  void _loadUserEvents() async {
    List<Event> events =
        await _eventController.getEvents(); // Fetch events from SQLite
    setState(() {
      _userEvents = events;
    });
  }

  // Add a new event
  void _addEvent() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEventPage()),
    );
    _loadUserEvents(); // Re-fetch events after adding a new one
  }

  // Delete an event
  void _deleteEvent(int eventId) async {
    await _eventController.deleteEvent(eventId); // Delete the event from SQLite
    _loadUserEvents(); // Re-fetch events after deletion
  }

  // Search functionality
  void _searchFriends(String query) {
    setState(() {
      _searchQuery = query;
      _friendsList = _controller.searchFriends(query); // Search friends by name
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get preferences for dark mode
    var preferences = Provider.of<PreferencesService>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor:
          preferences.isDarkMode ? Color(0xff1e1e1e) : Color(0xffefefef),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 50,
        backgroundColor:
            preferences.isDarkMode ? Color(0xff1e1e1e) : Color(0xffefefef),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app,
                color: preferences.isDarkMode ? Colors.white : Colors.black),
            onPressed: () async {
              // Get the current user
              User? user = FirebaseAuth.instance.currentUser;

              if (user != null) {
                String userId = user.uid;
                try {
                  // Update Firestore to set isOwner to false
                  await FirebaseFirestore.instance.collection('Users').doc(userId).update({
                    'isOwner': false, // Set isOwner to false
                  });

                  // Sign out the user
                  await FirebaseAuth.instance.signOut();
                  print('User signed out and isOwner set to false in Firestore.');

                  // Navigate to login page
                  Navigator.pushReplacementNamed(context, '/login');
                } catch (e) {
                  print('Error updating Firestore: $e');
                }
              } else {
                print('No user is currently signed in.');
              }
            },
          )
        ],
      ),
      body:
        Column(
          children: [
            // Header Section with HADIEATY logo/text
            Container(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(45, 0, 45, 10),
                  child: Text(
                    'HADIEATY',
                    style: GoogleFonts.anticDidone(
                      fontSize: 45,
                      fontWeight: FontWeight.w400,
                      color:
                          preferences.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [Text('Welcome ${widget.name}')],
              ),
            ),
            // Logout and Profile Button Section
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      // Navigate to profile page
                      Navigator.pushNamed(context, '/userProfile');
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: preferences.isDarkMode
                          ? Colors.grey
                          : Color(0xff273331),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    child: const Text(
                      'Go to your profile',
                      style: TextStyle(fontSize: 16, color: Color(0xFFD8D7D7)),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: SwitchListTile(
                      title: Text(
                        'Dark Mode',
                        style: TextStyle(
                          color: preferences.isDarkMode
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      value: preferences.isDarkMode,
                      onChanged: (value) {
                        setState(() {
                          preferences.setDarkMode(value);
                        });
                      },
                      activeColor: Colors.white,
                      activeTrackColor: Colors.grey,
                      inactiveThumbColor: Color(0xFFF6F6F6),
                      inactiveTrackColor: Color(0xff273331),
                    ),
                  ),
                ],
              ),
            ),

            // Search Functionality
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Search Friends',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: _searchFriends,
              ),
            ),

            // Add Friend and Create Event Buttons
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {
                      // Placeholder for add friend functionality
                      print("Add Friend button pressed");
                    },
                    icon: Icon(
                      Icons.person_add,
                      size: 30,
                      color:
                          preferences.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(
                    width: 250,
                    child: OutlinedButton(
                      onPressed: _addEvent,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: preferences.isDarkMode
                            ? Colors.grey
                            : Color(0xff273331),
                        padding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.add,
                            size: 30,
                            color: Color(0xFFD8D7D7),
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Create new event/list',
                            style: TextStyle(
                                fontSize: 20, color: Color(0xFFD8D7D7)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // User's Event Card (for user's own events)
            Card(
              elevation: 15,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: InkWell(
                onTap: () {
                  // Navigate to the Event List Page for user's events
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventListPage(
                        friendName: 'Your Events',
                        isOwnEvents: true,
                        events: _userEvents,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Upcoming Events',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Upcoming Events: ${_userEvents.length}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Friends List with Search Functionality
            Expanded(
              child: ListView.builder(
                itemCount: _friendsList.length,
                itemBuilder: (context, index) {
                  var friend = _friendsList[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(friend.profilePicture),
                      ),
                      title: Text(friend.name),
                      subtitle: Text(friend.phone),
                      trailing: Text(
                        friend.upcomingEventsCount > 0
                            ? "Upcoming Events: ${friend.upcomingEventsCount}"
                            : "No Upcoming Events",
                        style: TextStyle(
                          color: friend.upcomingEventsCount > 0
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      onTap: () {
                        // Navigate to the Event List Page for friend's events
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventListPage(
                              friendName: friend.name,
                              isOwnEvents: false,
                              events:
                                  _userEvents, // Use the controller for friend's events
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
