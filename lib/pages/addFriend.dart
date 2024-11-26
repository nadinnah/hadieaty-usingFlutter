import 'package:flutter/material.dart';
import 'package:hadieaty/Localdb/localDb.dart';
import 'sharedPrefs.dart';
import 'package:provider/provider.dart';

class AddFriendPage extends StatefulWidget {
  @override
  _AddFriendPageState createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  TextEditingController phoneController = TextEditingController();
  LocalDatabase localDatabase = LocalDatabase();

  // Function to add a friend by phone number
  void addFriend() async {
    String phone = phoneController.text.trim();

    if (phone.isNotEmpty) {
      // Fetch user ID from the phone number or search by name from Users table
      var userResult = await localDatabase.readData('''SELECT * FROM Users WHERE phone = "$phone"''');

      if (userResult.isNotEmpty) {
        int userId = userResult[0]['id']; // Assume the first result is the correct one
        int currentUserId = 1; // Get the logged-in user's ID (hardcoded or fetched from auth)

        // Insert the friend relationship into the 'Friends' table
        String insertFriendSQL = '''INSERT INTO Friends (userId, friendId) VALUES ($currentUserId, $userId)''';
        await localDatabase.insertData(insertFriendSQL);
        print('Friend added successfully');

        // Optional: Provide user feedback and refresh UI if needed
        setState(() {});
      } else {
        print('Friend not found');
        // Provide feedback that the friend does not exist
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var preferences = Provider.of<PreferencesService>(context);
    return Scaffold(
      backgroundColor:
      preferences.isDarkMode ?  Color(0xff1e1e1e) : const Color(0xffefefef),
      appBar: AppBar(title: Text('Add Friend')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Enter Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: addFriend,
              child: Text('Add Friend'),
            ),
          ],
        ),
      ),
    );
  }
}
