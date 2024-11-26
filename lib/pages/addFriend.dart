import 'package:flutter/material.dart';
import 'package:hadieaty/Localdb/localDb.dart';
import 'sharedPrefs.dart';
import 'package:provider/provider.dart';

class AddFriendPage extends StatefulWidget {
  final VoidCallback onFriendAdded; // Callback to notify when a friend is added

  const AddFriendPage({Key? key, required this.onFriendAdded}) : super(key: key);

  @override
  _AddFriendPageState createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  TextEditingController phoneController = TextEditingController();
  LocalDatabase localDatabase = LocalDatabase();

  String feedbackMessage = ""; // To show feedback to the user

  // Function to add a friend by phone number
  void addFriend() async {
    String phone = phoneController.text.trim();

    if (phone.isEmpty) {
      setState(() {
        feedbackMessage = "Please enter a valid phone number.";
      });
      return;
    }

    // Check if the phone number exists in the Users table with role 0
    var userResult = await localDatabase.readData(
        '''SELECT * FROM Users WHERE number = "$phone" AND role = 0''');

    if (userResult.isNotEmpty) {
      int userId = userResult[0]['id']; // Found user's ID
      int currentUserId = 1; // Replace with the actual logged-in user's ID

      // Check if the friend relationship already exists
      var friendCheck = await localDatabase.readData(
          '''SELECT * FROM Friends WHERE userId = $currentUserId AND friendId = $userId''');

      if (friendCheck.isEmpty) {
        // Insert the friend relationship into the 'Friends' table
        String insertFriendSQL =
        '''INSERT INTO Friends (userId, friendId) VALUES ($currentUserId, $userId)''';
        await localDatabase.insertData(insertFriendSQL);

        // Invoke the callback to notify HomePage
        widget.onFriendAdded();

        setState(() {
          feedbackMessage = "Friend added successfully!";
        });

        // Optionally navigate back to HomePage
        Navigator.pop(context);
      } else {
        setState(() {
          feedbackMessage = "This friend is already in your list.";
        });
      }
    } else {
      setState(() {
        feedbackMessage =
        "No user found with this phone number or the user is not eligible.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var preferences = Provider.of<PreferencesService>(context);
    return Scaffold(
      backgroundColor:
      preferences.isDarkMode ? Color(0xff1e1e1e) : const Color(0xffefefef),
      appBar: AppBar(
        title: Text('Add Friend'),
        backgroundColor: preferences.isDarkMode ? Colors.grey[900] : Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Enter Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: addFriend,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                preferences.isDarkMode ? Colors.grey : Color(0xff273331),
              ),
              child: Text(
                'Add Friend',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              feedbackMessage,
              style: TextStyle(
                color: feedbackMessage.contains("successfully")
                    ? Colors.green
                    : Colors.red,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
