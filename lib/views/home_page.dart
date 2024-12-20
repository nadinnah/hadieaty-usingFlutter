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
import 'event_details_page.dart';
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
  String _searchQuery = '';
  List<Event> _userEvents = [];
  String _userName = '';
  String _userEmail = '';
  bool _friendsLoaded = false;
  final PhotoController _photoController = PhotoController();
  String _profileURL = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFriends();
    loadPhotoURLs();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getUserName();
  }

  Future<void> loadPhotoURLs() async {
    var urls = await _photoController.fetchPhotoURLs();
    setState(() {
      _profileURL = urls['profileURL']!;
      _isLoading = false;
    });
  }

  getUserName() async {
    String? name = await _localDatabase.getLoggedInUserName();
    setState(() {
      _userName = name ?? 'Guest';
    });
  }

  Future<void> loadFriends() async {
    setState(() => _friendsLoaded = false);
    try {
      List<Friend> friends = await friendController.getFriends();
      setState(() {
        _friendsList = friends;
        _friendsLoaded = true;
      });
    } catch (e) {
      print("Error loading friends: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load friends")),
      );
    }
  }

  void _filterFriends() {
    setState(() {
      _friendsList = _friendsList.where((friend) {
        return friend.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            friend.phone.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    });
  }


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
              children: [
                Text(
                  'Welcome $_userName',
                  style: TextStyle(
                      fontSize: 17,
                      color:
                          preferences.isDarkMode ? Colors.white : Colors.black),
                )
              ],
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
                    style: TextStyle(fontSize: 16, color: Colors.white),
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
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search Friends',
                labelStyle: TextStyle(color: preferences.isDarkMode ? Colors.white : Colors.black),
                prefixIcon: Icon(Icons.search, color: preferences.isDarkMode ? Colors.white : Colors.black),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: preferences.isDarkMode ? Colors.white : Colors.black),
                ),
              ),
              style: TextStyle(color: preferences.isDarkMode ? Colors.white : Colors.black),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                  _filterFriends(); // Filter friends based on the query
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () async {
                    TextEditingController phoneController = TextEditingController();
                    String friendPhone = '';

                    showDialog(
                      context: context,
                      builder: (context) {
                        var isDarkMode = Provider.of<PreferencesService>(context).isDarkMode;
                        return AlertDialog(
                          backgroundColor: isDarkMode ? const Color(0xff1e1e1e) : const Color(0xffefefef),
                          title: Text(
                            "Add Friend by Phone",
                            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                          ),
                          content: TextField(
                            controller: phoneController,
                            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                            decoration: InputDecoration(
                              labelText: 'Friend\'s Phone Number',
                              labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                              border: const OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black),
                              ),
                            ),
                            keyboardType: TextInputType.phone,
                            onChanged: (value) => friendPhone = value,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                if (friendPhone.isNotEmpty) {
                                  try {
                                    // Use FriendController to add friend by phone
                                    await friendController.addFriendByPhone(friendPhone);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Friend added successfully.")),
                                    );

                                    Navigator.pop(context); // Close the dialog

                                    // Reload friends to update the list dynamically
                                    await loadFriends();
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Please enter a valid phone number")),
                                  );
                                }
                              },
                              child: Text(
                                "Add Friend",
                                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                "Cancel",
                                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },

                  icon: Icon(
                    Icons.person_add,
                    size: 30,
                    color: preferences.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(
                  width: 250,
                  child: OutlinedButton(
                    onPressed: () async {
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
                    style: OutlinedButton.styleFrom(
                      backgroundColor: preferences.isDarkMode
                          ? Colors.grey
                          : Color(0xff273331),
                      padding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add, size: 30, color: Colors.white),
                        SizedBox(width: 5),
                        Text(
                          'Create new event/list',
                          style:
                              TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _friendsList.isEmpty
                ? Center(child: Text("No friends found.",style: TextStyle(color: preferences.isDarkMode ? Colors.white : Colors.black ),))
                : ListView.builder(
                    itemCount: _friendsList.length,
                    itemBuilder: (context, index) {
                      var friend = _friendsList[index];
                      return Card(
                        color: preferences.isDarkMode ? const Color(0xffcfcfcf) : Color(0xecfffffc),
                        elevation: 5,
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(10),
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(friend
                                    .profilePicture.isNotEmpty
                                ? friend.profilePicture
                                : _profileURL), // Use default profile picture if none
                          ),
                          title: Text(
                            friend.name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          subtitle: Text(
                            friend.phone.isNotEmpty ? friend.phone : "N/A",
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
                            var events = await FirestoreService()
                                .getUpcomingEventsForFriend(friend.id);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FriendEventListPage(
                                  events: events,
                                  friendName: friend.name,
                                  friendId: friend.id,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
