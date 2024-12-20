import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import '../controllers/user_controller.dart';
import '../models/event.dart';
import 'user_event_list_page.dart';
import 'my_pledged_gifts_page.dart';
import 'package:image_picker/image_picker.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final UserController _userController = UserController();
  int? _loggedInUserId;
  Map<String, dynamic> _userData = {};
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _fetchLoggedInUser();
    _loadUserData();
  }

  Future<void> _fetchLoggedInUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      int userId = await _userController.getUserIdByEmail(user.email!);
      setState(() {
        _loggedInUserId = userId;
      });
    }
  }

  void _loadUserData() async {
    if (_loggedInUserId != null) {
      var userData = await _userController.getUserData(_loggedInUserId!);
      setState(() {
        _userData = userData;
      });
    }
  }

  void _toggleNotifications(bool value) async {
    setState(() {
      _userData['notifications'] = value;
    });

    if (_loggedInUserId != null) {
      _userController.updateUserNotifications(_loggedInUserId!, value);
    }

    if (value) {
      // Request notification permissions
      await Permission.notification.request();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notifications have been enabled.')),
      );
    } else {
      // Direct user to app settings to disable notifications
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Notifications have been disabled. Please update permissions in app settings if required.'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () {
              openAppSettings(); // Opens the app settings for notification permissions
            },
          ),
        ),
      );
    }
  }


  Future<void> _pickProfilePicture() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      if (_loggedInUserId != null) {
        await _userController.updateUserField(
            _loggedInUserId!, 'profilePic', pickedFile.path);
        _loadUserData();
      }
    }
  }

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
              onPressed: () async {
                String newValue = _controller.text.trim();

                if (newValue.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please enter a valid $field.")),
                  );
                  return;
                }

                try {
                  // Update UI state
                  setState(() {
                    _userData[field] = newValue;
                  });

                  // Ensure _loggedInUserId is set
                  if (_loggedInUserId == null) {
                    throw Exception("User ID not available. Unable to update $field.");
                  }

                  // Update Firestore
                  await FirebaseFirestore.instance
                      .collection('Users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .update({field: newValue});

                  // Update locally
                  await _userController.updateUserField(
                    _loggedInUserId!,
                    field,
                    newValue,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$field updated successfully!')),
                  );

                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to update $field: $e")),
                  );
                }
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
      backgroundColor: Color(0xffefefef),
      appBar: AppBar(
        title: Text("My Profile"),
        backgroundColor: const Color(0xffefefef),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Personal Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Name"),
              subtitle: Text(_userData['name'] ?? 'Loading...'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _editUserField('name', _userData['name'] ?? '');
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text("Email"),
              subtitle: Text(_userData['email'] ?? 'Loading...'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _editUserField('email', _userData['email'] ?? '');
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text("Phone Number"),
              subtitle: Text(_userData['number']?.toString() ?? 'Not Provided'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _editUserField('number', _userData['number'] ?? '');
                },
              ),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text("Enable Notifications"),
              value: _userData['notifications'] ?? true,
              onChanged: _toggleNotifications,
            ),
            const Divider(),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserEventListPage()),
                );
              },
              child: const Text(
                "Your Events",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
