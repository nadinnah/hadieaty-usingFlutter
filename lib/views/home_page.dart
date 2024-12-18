import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hadieaty/controllers/event_controller.dart';
import 'package:hadieaty/controllers/friend_controller.dart';
import 'package:hadieaty/models/event.dart';
import '../controllers/photo_controller.dart';
import '../services/firestore_service.dart';
import '../services/shared_preference.dart';
import '../services/sqlite_service.dart';
import 'add_event.dart';

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
  FriendController friendController = FriendController();
  final EventController _eventController = EventController();
  final LocalDatabase _localDatabase = LocalDatabase();
  List<Friend> _friendsList = [];
  List<Event> _userEvents = [];
  String _userName = '';
  String _userEmail = '';
  bool _friendsLoaded = false;
  final PhotoController _photoController = PhotoController();
  String _giftURL = '';
  String _profileURL = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    //_loadUserEvents();
    //_friendsList = _controller.getFriends();
    _getUserName();
    _loadFriends();
    _loadPhotoURLs();
  }

  Future<void> _loadPhotoURLs() async {
    var urls = await _photoController.fetchPhotoURLs();
    setState(() {
      _giftURL = urls['giftURL']!;
      _profileURL = urls['profileURL']!;
      _isLoading = false;
    });
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

  Stream<List<Event>> getUserEventsStream() {
    return FirebaseFirestore.instance
        .collection('Events')
        .where('createdBy', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var data = doc.data();
              return Event.fromMap(data..['id'] = doc.id);
            }).toList());
  }

  Future<void> _loadFriends() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isNotEmpty) {
      var userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        List<dynamic> friendIds = userDoc.data()?['friends'] ?? [];
        setState(() {
          _friendsList = friendIds
              .map((id) => Friend(
                    id: id,
                    name: 'Loading...',
                    // Placeholder for name
                    profilePicture: '',
                    phone: '',
                    upcomingEventsCount:
                        0, // Event count handled by StreamBuilder
                  ))
              .toList();
        });
      }
    }
  }

  void _addFriend() async {
    TextEditingController emailController = TextEditingController();
    String friendEmail = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Friend by Email"),
        content: TextField(
          controller: emailController,
          decoration: InputDecoration(labelText: 'Friend\'s Email'),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) => friendEmail = value,
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (friendEmail.isNotEmpty) {
                try {
                  // Query Firestore to find the friend by email
                  var friendDoc = await FirebaseFirestore.instance
                      .collection('Users')
                      .where('email', isEqualTo: friendEmail)
                      .get();

                  if (friendDoc.docs.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("No user found with that email")),
                    );
                  } else {
                    var friendData = friendDoc.docs.first.data();
                    String friendId = friendData['uid'];

                    // Add friend's UID to the current user's `friends` array
                    String userId = FirebaseAuth.instance.currentUser!.uid;
                    await FirebaseFirestore.instance
                        .collection('Users')
                        .doc(userId)
                        .update({
                      'friends': FieldValue.arrayUnion([friendId]),
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text("${friendData['name']} added as a friend.")),
                    );

                    // Reload the friends list
                    _loadFriends();
                    Navigator.pop(context); // Close the dialog
                  }
                } catch (e) {
                  print("Error adding friend: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to add friend.")),
                  );
                }
              }
            },
            child: Text("Add Friend"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
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
                    builder: (context) => UserEventListPage(
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
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(child: Text("No friends available"));
                }

                var data = snapshot.data!.data() as Map<String, dynamic>;
                List<dynamic> friendIds = data['friends'] ?? [];

                // Fetch friends only once
                if (!_friendsLoaded && friendIds.isNotEmpty) {
                  _friendsLoaded = true; // Set flag
                  _loadFriends();
                }

                return _friendsList.isEmpty
                    ? Center(child: Text("No friends found."))
                    : ListView.builder(
                        itemCount: _friendsList.length,
                        itemBuilder: (context, index) {
                          var friend = _friendsList[index];
                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('Users')
                                .doc(friend.id)
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Card(
                                  elevation: 5,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.all(10),
                                    title: Text(
                                      "Loading...",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text("Loading..."),
                                    trailing: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              if (!snapshot.hasData || !snapshot.data!.exists) {
                                return ListTile(
                                  title: Text("No friend data available."),
                                );
                              }

                              var friendData =
                                  snapshot.data!.data() as Map<String, dynamic>;

                              return Card(
                                elevation: 5,
                                margin: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(10),
                                  leading: CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage(_profileURL),
                                  ),
                                  title: Text(
                                    friendData['name'] ?? "Unknown",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                  subtitle: Text(
                                    friendData['phone'] ?? 'N/A',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  trailing: StreamBuilder<int>(
                                    stream: friendController
                                        .getUpcomingEventsCount(friend.id),
                                    builder: (context, eventSnapshot) {
                                      if (eventSnapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Text("Loading...");
                                      }
                                      int eventCount = eventSnapshot.data ?? 0;
                                      return Text(
                                        "Upcoming events: $eventCount",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  ),
                                  onTap: () async {
                                    print(
                                        "Fetching upcoming events for friend ID: ${friend.id}");

                                    var events = await FirestoreService()
                                        .getUpcomingEventsForFriend(friend.id);

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            FriendEventListPage(
                                          events: events,
                                          friendName: friendData['name'],
                                          friendId: friend.id,
                                        ),
                                      ),
                                    );
                                  },
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
