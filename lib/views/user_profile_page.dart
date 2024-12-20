import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hadieaty/views/pledged_gifts_page.dart';
import 'package:hadieaty/views/user_event_list_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../controllers/user_controller.dart';
import '../services/shared_preference.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final UserController _userController = UserController();
  Map<String, dynamic> _userData = {};
  File? _profileImage;
  bool _isLoading = true;
  late int localid;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      Map<String, dynamic> data = await _userController.getUserData();
      int? sqliteId = await _userController.getLocalId();
      setState(() {
        _userData = data;
        localid=sqliteId!;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load user data: $e")),
      );
    }
  }


  Future<void> _pickProfilePicture() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      try {
        await _userController.updateProfilePicture(pickedFile.path);
        _loadUserData(); // Refresh user data
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update profile picture: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var preferences = Provider.of<PreferencesService>(context);
    var isDarkMode = preferences.isDarkMode;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDarkMode ? const Color(0xff1e1e1e) : const Color(0xffefefef),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xff1e1e1e) : const Color(0xffefefef),
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xff1e1e1e) : const Color(0xffefefef),
        title: Text(
          "Your Profile",
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
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
                      ? NetworkImage(_userData['profilePic'])
                      : AssetImage('lib/assets/images/default_profile.png')) as ImageProvider,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Personal Information",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            _buildEditableField(
              icon: Icons.person,
              label: "Name",
              value: _userData['name'] ?? 'Loading...',
              isDarkMode: isDarkMode,
              onSave: (newValue) => _userController.updateUserField('name', newValue,localid),
            ),
            _buildEditableField(
              icon: Icons.email,
              label: "Email",
              value: _userData['email'] ?? 'Loading...',
              isDarkMode: isDarkMode,
              onSave: (newValue) => _userController.updateUserField('email', newValue,localid),
            ),
            _buildEditableField(
              icon: Icons.phone,
              label: "Phone Number",
              value: _userData['phone']?.toString() ?? 'Not Provided',
              isDarkMode: isDarkMode,
              onSave: (newValue) => _userController.updateUserField('phone', newValue,localid),
            ),
            const Divider(),
            SwitchListTile(
              title: Text(
                "Enable Notifications",
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              ),
              value: preferences.notificationsEnabled,
              onChanged: (value) {
                preferences.setNotificationsEnabled(value);
              },
              activeColor: Colors.white,
              activeTrackColor: Colors.grey,
              inactiveThumbColor: const Color(0xFFF6F6F6),
              inactiveTrackColor: const Color(0xff273331),
            ),
            const Divider(),
            SizedBox(height: 10,),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserEventListPage()),
                );
              },
              child: Text(
                "Go To Your Upcoming, Current and Past Events",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            SizedBox(height: 10,),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PledgedGiftsPage()),
                );
              },
              child: Text(
                "Go To Gifts You Pledged",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required IconData icon,
    required String label,
    required String value,
    required bool isDarkMode,
    required Future<void> Function(String newValue) onSave,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDarkMode ? Colors.white : Colors.black),
      title: Text(
        label,
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      ),
      subtitle: Text(
        value,
        style: TextStyle(color: isDarkMode ? Colors.grey : Colors.black54),
      ),
      trailing: IconButton(
        icon: Icon(Icons.edit, color: isDarkMode ? Colors.white : Colors.black),
        onPressed: () async {
          TextEditingController _controller = TextEditingController(text: value);
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Edit $label"),
                content: TextField(
                  controller: _controller,
                  decoration: InputDecoration(labelText: label),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      String newValue = _controller.text.trim();
                      if (newValue.isNotEmpty) {
                        await onSave(newValue);
                        Navigator.pop(context);
                        _loadUserData(); // Refresh user data
                      }
                    },
                    child: Text("Save"),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
