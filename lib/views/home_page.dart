import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/event_controller.dart';
import '../models/event.dart';
import 'add_event.dart';
import 'event_list_page.dart'; // Import Event List Page
import 'package:hadieaty/controllers/home_controller.dart'; // HomeController
import 'package:hadieaty/models/friend.dart'; // Friend Model
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController _controller = HomeController();
  List<Friend> _friendsList = [];
  final EventController _eventController = EventController();
  String _searchQuery = "";

  // Dummy data for the user's events
  List<Event> _userEvents = [];

  void _addEvent() async {
    // Wait for the new event to be added
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEventPage()
      ),
    );
    setState(() {
      _userEvents = _eventController.getEvents(); // Update user's events list
    });
  }

  @override
  void initState() {
    super.initState();
    _friendsList = _controller.getFriends(); // Get list of friends
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 50,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.black),
            onPressed: () {
              FirebaseAuth.instance.signOut(); // Perform sign-out
              Navigator.pushReplacementNamed(
                  context, '/login'); // Navigate to login page
            },
          ),
        ],
      ),
      body: Column(
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
                    color: Color(0xff1e1e1e),
                  ),
                ),
              ),
            ),
          ),

          // Logout and Profile Button Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () {
                    // Placeholder for profile action
                    print("Your profile pressed");
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Color(0xff1e1e1e),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                  child: const Text(
                    'Go to your profile',
                    style: TextStyle(fontSize: 16, color: Color(0xFFD8D7D7)),
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
                    color: Color(0xff1e1e1e),
                  ),
                ),
                SizedBox(
                  width: 250,
                  child: OutlinedButton(
                    onPressed: () {
                      _addEvent();
                      // Placeholder for creating event functionality

                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Color(0xff1e1e1e),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
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
                          style:
                              TextStyle(fontSize: 20, color: Color(0xFFD8D7D7)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(children: [
            // User's Event Card (added for user's own events)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 15,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: InkWell(
                  onTap: () {
                    // Navigate to the Event List Page for the user's events
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventListPage(
                          friendName: 'Your Events',
                          // Indicating this is for the user's own events
                          isOwnEvents:
                              true,
                          events: _userEvents,// Flag indicating this is the user's own events
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Upcoming Events',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        // Show the number of upcoming events
                        Text(
                          'Upcoming Events: ${_userEvents.length}',
                          style: TextStyle(fontSize: 16),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            )
          ]),

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
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            friend.phone,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    trailing:Text(
                      friend.upcomingEventsCount > 0
                          ? "Upcoming Events: ${friend.upcomingEventsCount}"
                          : "No Upcoming Events",
                      style: TextStyle(
                        color: friend.upcomingEventsCount > 0
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 15
                      ),
                    ),
                    onTap: () {
                      // Navigate to the Event List Page and pass data
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventListPage(
                            friendName: friend.name,
                            isOwnEvents: false,
                            events: _eventController.getEvents(),// Pass friend's name
                            // Dummy events data
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
