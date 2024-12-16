import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hadieaty/controllers/event_controller.dart';
import 'package:hadieaty/controllers/friend_controller.dart';
import 'package:hadieaty/models/event.dart';
import '../services/shared_preference.dart';
import '../services/sqlite_service.dart';
import 'add_event.dart';
import 'package:hadieaty/controllers/home_controller.dart';
import 'package:hadieaty/models/friend.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'user_event_list_page.dart';
import 'friend_event_list_page.dart'; // New Page for Friend's Events

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FriendController friendController= FriendController();
  final HomeController _controller = HomeController();
  final EventController _eventController = EventController();
  final LocalDatabase _localDatabase = LocalDatabase();
  List<Friend> _friendsList = [];
  List<Event> _userEvents = [];
  String _userName = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserEvents();
    //_friendsList = _controller.getFriends();
    _getUserName();
  }

  // Fetch user name from local database
  void _getUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? name = await _localDatabase.getUserNameByEmail(user.email ?? '');
      setState(() {
        _userName = name ?? 'Guest';
        _userEmail = user.email ?? '';
      });
    }
  }

  // Load events from local database
  void _loadUserEvents() async {
    List<Event> events = await _eventController.getLocalEvents();
    setState(() {
      _userEvents = events;
    });
  }

  void _addFriend() async {
    TextEditingController emailController = TextEditingController();
    String friendEmail = '';

    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text("Add Friend by Email"),
            content: TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Friend\'s Email'),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                friendEmail = value;
              },
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (friendEmail.isNotEmpty) {
                    // Try to find the user by email in Firestore
                    var friendDoc = await FirebaseFirestore.instance
                        .collection('Users')
                        .where('email', isEqualTo: friendEmail)
                        .get();

                    if (friendDoc.docs.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("No user found with that email")));
                    } else {
                      var friendData = friendDoc.docs.first.data();
                      Friend friend = Friend(
                        name: friendData['name'],
                        profilePicture: friendData['profilePicture'] ?? '',
                        phone: friendData['phone'] ?? '',
                        upcomingEventsCount: friendData['upcomingEventsCount'] ??
                            0,
                        id: friendData['uid'],
                      );

                      // Add the friend to your user's friends list in Firestore or SQLite
                      String userId = FirebaseAuth.instance.currentUser?.uid ??
                          '';
                      await FirebaseFirestore.instance
                          .collection('Users')
                          .doc(userId)
                          .collection('friends')
                          .doc(
                          friendEmail) // Using email as a unique identifier for simplicity
                          .set({
                        'name': friend.name,
                        'profilePicture': friend.profilePicture,
                        'phone': friend.phone,
                        'upcomingEventsCount': friend.upcomingEventsCount,
                      });

                      // Add friend to local list and refresh UI
                      setState(() {
                        _friendsList.add(friend);
                      });
                      Navigator.pop(context); // Close the dialog
                    }
                  }
                },
                child: Text("Add Friend"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog without action
                },
                child: Text("Cancel"),
              ),
            ],
          ),
    );
  }

  // Search functionality for friends
  // void _searchFriends(String query) {
  //   setState(() {
  //     _friendsList = _controller.searchFriends(query);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
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
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                String userId = user.uid;
                String email = user.email ?? '';
                try {
                  // Update Firestore and SQLite before signing out
                  await FirebaseFirestore.instance
                      .collection('Users')
                      .doc(userId)
                      .update({'isOwner': false});
                  await _localDatabase.updateUserIsOwner(email, 0);
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                } catch (e) {
                  print('Error updating Firestore: $e');
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(45, 0, 45, 10),
              child: Text(
                'HADIEATY',
                style: GoogleFonts.anticDidone(
                  fontSize: 45,
                  fontWeight: FontWeight.w400,
                  color: preferences.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [Text('Welcome $_userName')],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () {
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
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search Friends',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              // onChanged: //_searchFriends,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: _addFriend,
                  icon: Icon(
                    Icons.person_add,
                    size: 30,
                    color: preferences.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(
                  width: 250,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/addEvent');
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: preferences.isDarkMode
                          ? Colors.grey
                          : Color(0xff273331),
                      padding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add, size: 30, color: Color(0xFFD8D7D7)),
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
          Card(
            elevation: 15,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: InkWell(
              onTap: () async {
                final updatedEvents = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UserEventListPage(
                          events: _userEvents,
                          onEventsUpdated: (updatedEvents) {
                            setState(() {
                              _userEvents = updatedEvents;
                            });
                          },
                        ),
                  ),
                );
                if (updatedEvents != null) {
                  setState(() {
                    _userEvents = updatedEvents;
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(80, 10, 80, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Upcoming Events',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Text("No friends available");
                }
                var data = snapshot.data!.data() as Map<String, dynamic>;
                List<dynamic> friends = data['friends'] ?? [];

                // Fetch friend details here using the friend UIDs
                return FutureBuilder<List<Friend>>(
                  future: friendController.getFriendsDetails(friends), // Fetch friend details
                  builder: (context, friendSnapshot) {
                    if (friendSnapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (!friendSnapshot.hasData || friendSnapshot.data!.isEmpty) {
                      return Column(children: [
                        SizedBox(height: 150,),Text("No friends found")
                      ],);
                    }
                    List<Friend> friendsList = friendSnapshot.data!;
                    return ListView.builder(
                      itemCount: friendsList.length,
                      itemBuilder: (context, index) {
                        var friend = friendsList[index];
                        return ListTile(
                          title: Text(friend.name),
                          subtitle: Text("Phone: ${friend.phone}"),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(friend.profilePicture),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          )

        ],
      ),
    );
  }
}
