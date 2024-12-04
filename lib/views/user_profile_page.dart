import 'package:flutter/material.dart';
import '../controllers/user_controller.dart';
import '../models/event.dart';
import '../models/gift.dart';
import 'gift_list_page.dart';
import 'my_pledged_gifts_page.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final UserController _userController = UserController();

  // Dummy data for user profile
  Map<String, dynamic> _userData = {
    'name': 'John Doe',
    'email': 'johndoe@example.com',
    'notifications': true,
  };

  List<Event> _createdEvents = [];
  List<Gift> _pledgedGifts = [];

  @override
  void initState() {
    super.initState();
    _createdEvents = _userController.getCreatedEvents();
    _pledgedGifts = _userController.getPledgedGifts();
  }

  // Toggle notifications
  void _toggleNotifications(bool value) {
    setState(() {
      _userData['notifications'] = value;
    });
  }

  // Navigate to pledged gifts


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
            Text(
              "Personal Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Name"),
              subtitle: Text(_userData['name']),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _editUserField('name', _userData['name']);
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.email),
              title: Text("Email"),
              subtitle: Text(_userData['email']),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _editUserField('email', _userData['email']);
                },
              ),
            ),
            Divider(),

            // Notification Settings
            SwitchListTile(
              title: Text("Enable Notifications"),
              value: _userData['notifications'],
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
                    // Navigate to event's gift list
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GiftListPage(
                          eventName: event.name,
                          isOwnEvent: true,
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
              onPressed:
              (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PledgedGiftsPage(
                      pledgedGifts: _pledgedGifts,
                    ),
                  ),
                );
              },

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

  // Edit user field
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
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
