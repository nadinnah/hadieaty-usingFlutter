import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hadieaty/controllers/user_controller.dart';
import 'package:hadieaty/models/event.dart';
import 'package:hadieaty/models/gift.dart';
import 'package:hadieaty/views/user_gift_list_page.dart';
import 'friend_gift_list_page.dart';
import 'my_pledged_gifts_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';


import 'package:permission_handler/permission_handler.dart';



class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final UserController _userController = UserController();
  int? _loggedInUserId;
  Map<String, dynamic> _userData = {};
  List<Event> _createdEvents = [];
  List<Gift> _pledgedGifts = [];
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _initializeData(); // Call an async helper function
  }

  Future<void> _initializeData() async {
    await _fetchLoggedInUser(); // Example: Fetch logged-in user details
    _loadUserData(); // Fetch user data
    _loadCreatedEvents(); // Load created events
    _loadPledgedGifts(); // Load pledged gifts
  }

  // Load user data from the controller
  void _loadUserData() async {
    if (_loggedInUserId != null) {
      var userData = await _userController.getUserData(_loggedInUserId!);
      setState(() {
        _userData = userData;
      });
    }
  }

  Future<void> _fetchLoggedInUser() async {
    // Example: Using FirebaseAuth to get the current user's UID
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      int userId = await _userController.getUserIdByEmail(user.email!); // Fetch userId using email
      setState(() {
        _loggedInUserId = userId;
      });
    }
  }

  // Load created events for the user
  void _loadCreatedEvents() async {
    if (_loggedInUserId != null) {
      var events = await _userController.getCreatedEvents(_loggedInUserId!);
      setState(() {
        _createdEvents = events;
      });
    }
  }

  // Load pledged gifts for the user
  void _loadPledgedGifts() async {
    if (_loggedInUserId != null) {
      var gifts = await _userController.getPledgedGifts(_loggedInUserId!);
      setState(() {
        _pledgedGifts = gifts;
      });
    }
  }

  // Toggle notifications
  void _toggleNotifications(bool value) {
    setState(() {
      _userData['notifications'] = value;
    });
    if (_loggedInUserId != null) {
      _userController.updateUserNotifications(_loggedInUserId!, value);
    }
  }

  // Pick a profile picture using Image Picker
  Future<void> _pickProfilePicture() async {
    // Request camera and photo permissions
    await requestPermissions();

    // After permissions are granted, pick the image
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      // Update profile picture in local database
      if (_loggedInUserId != null) {
        await _userController.updateUserField(
            _loggedInUserId!, 'profilePic', pickedFile.path);
        _loadUserData();
      }
    }
  }


  requestPermissions() async {
    PermissionStatus cameraStatus = await Permission.camera.request();
    PermissionStatus photosStatus = await Permission.photos.request();
    if(await Permission.camera.isPermanentlyDenied ){
      openAppSettings();
    }
    if (!cameraStatus.isGranted || !photosStatus.isGranted) {
      // Request permissions if not granted
      var status = await [
        Permission.camera,
        Permission.photos,
      ].request();

      if (status[Permission.camera]?.isGranted == false || status[Permission.photos]?.isGranted == false) {
        // If any permission is not granted, show a message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please grant permissions to access camera and photos.')),
        );
      }
    }
  }


  // Edit user field (e.g., name, email, or phone number)
  void _editUserField(String field, String initialValue) {
    TextEditingController _controller = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit $field"),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: field),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _userData[field] = _controller.text;
                });
                if (_loggedInUserId != null) {
                  _userController.updateUserField(
                      _loggedInUserId!, field, _controller.text);
                }
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Center(
              child: GestureDetector(
                onTap: _pickProfilePicture,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : (_userData['profilePic'] != null
                      ? FileImage(File(_userData['profilePic']))
                      : AssetImage('lib/assets/images/default_profile.png')
                  as ImageProvider),
                  child: _profileImage == null &&
                      (_userData['profilePic'] == null)
                      ? Icon(Icons.camera_alt, size: 50)
                      : null,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Personal Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Name"),
              subtitle: Text(_userData['name'] ?? 'Loading...'),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _editUserField('name', _userData['name'] ?? '');
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.email),
              title: Text("Email"),
              subtitle: Text(_userData['email'] ?? 'Loading...'),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _editUserField('email', _userData['email'] ?? '');
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text("Phone Number"),
              subtitle: Text(_userData['number']?.toString() ?? 'Not Provided'),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _editUserField('number', _userData['number'] ?? '');
                },
              ),
            ),
            Divider(),

            // Notification Settings
            SwitchListTile(
              title: Text("Enable Notifications"),
              value: _userData['notifications'] ?? true,
              onChanged: _toggleNotifications,
            ),
            Divider(),

            // Created Events Section
            Text(
              "My Created Events",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _createdEvents.isEmpty
                ? Text("You have not created any events yet.")
                : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _createdEvents.length,
              itemBuilder: (context, index) {
                var event = _createdEvents[index];
                return ListTile(
                  title: Text(event.name),
                  subtitle: Text("Date: ${event.date}"),
                  onTap: () {
                    // Navigate to UserGiftListPage instead of GiftListPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserGiftListPage(
                          eventName: event.name,
                          eventId: event.id!, // Pass eventId to the UserGiftListPage
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            Divider(),

            // Pledged Gifts Section
            TextButton(
              onPressed: _viewPledgedGifts,
              child: Text(
                "View My Pledged Gifts",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Navigate to pledged gifts page
  void _viewPledgedGifts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PledgedGiftsPage(pledgedGifts: _pledgedGifts),
      ),
    );
  }
}
