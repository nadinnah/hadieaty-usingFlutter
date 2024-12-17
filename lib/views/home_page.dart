import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hadieaty/controllers/event_controller.dart';
import 'package:hadieaty/controllers/friend_controller.dart';
import 'package:hadieaty/models/event.dart';
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
  FriendController friendController= FriendController();
  final EventController _eventController = EventController();
  final LocalDatabase _localDatabase = LocalDatabase();
  List<Friend> _friendsList = [];
  List<Event> _userEvents = [];
  String _userName = '';
  String _userEmail = '';
  bool _friendsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadUserEvents();
    //_friendsList = _controller.getFriends();
    _getUserName();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isNotEmpty) {
      var userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
      if (userDoc.exists) {
        List<dynamic> friends = userDoc.data()?['friends'] ?? [];
        await _loadFriendsWithEventCounts(friends);
      }
    }
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
    List<Event> events = await _eventController.fetchUserEvents();
    setState(() {
      _userEvents = events;
    });
  }

  Future<void> _loadFriendsWithEventCounts(List<dynamic> friendIds) async {
    List<Friend> friendsWithCounts = [];

    for (String friendId in friendIds) {
      try {
        // Fetch friend's document
        var friendDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(friendId)
            .get();

        if (friendDoc.exists) {
          var friendData = friendDoc.data();
          if (friendData != null) {
            // Fetch upcoming events count
            int eventCount = await FirestoreService().getUpcomingEventsCount(friendId);

            friendsWithCounts.add(Friend(
              id: friendId,
              name: friendData['name'] ?? 'Unknown',
              profilePicture: friendData['profilePicture'] ?? '',
              phone: friendData['phone'] ?? 'N/A',
              upcomingEventsCount: eventCount,
            ));
          }
        }
      } catch (e) {
        print("Error fetching friend details for $friendId: $e");
      }
    }

    // Update the UI with loaded friends
    setState(() {
      _friendsList = friendsWithCounts;
      print("Friends loaded: ${_friendsList.length}");
    });
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
                      SnackBar(content: Text("${friendData['name']} added as a friend.")),
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
                  _loadFriendsWithEventCounts(friendIds);
                }

                return _friendsList.isEmpty
                    ? Center(child: Text("No friends found."))
                    : ListView.builder(
                  itemCount: _friendsList.length,
                  itemBuilder: (context, index) {
                    var friend = _friendsList[index];
                    return ListTile(
                      title: Text(friend.name),
                      subtitle:
                      Text("Upcoming Events: ${friend.upcomingEventsCount}"),
                      leading: CircleAvatar(
                        backgroundImage: friend.profilePicture.isNotEmpty
                            ? NetworkImage(friend.profilePicture)
                            : AssetImage('assets/default_avatar.png')
                        as ImageProvider,
                      ),
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
