import 'package:flutter/material.dart';
import 'package:hadieaty/navigationMenu.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sharedPrefs.dart';
import 'package:provider/provider.dart';
import 'package:hadieaty/Localdb/localDb.dart';
import 'addFriend.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late LocalDatabase _localDatabase;
  List<Map<String, dynamic>> friends = [];

  @override
  void initState() {
    super.initState();
    _localDatabase = LocalDatabase();
    _loadFriends();
  }

  void _loadFriends() async {
    int currentUserId = 1; // Example: replace with actual current user ID
    var userFriends = await _localDatabase.getFriends(currentUserId);

    // Update state to refresh UI
    setState(() {
      friends = userFriends;
    });
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('userEmail');

    if (userEmail != null) {
      await _localDatabase.updateData(
          '''UPDATE Users SET role = 0 WHERE email = "$userEmail"''');
      print('User role reset to 0');
    }

    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    var preferences = Provider.of<PreferencesService>(context);
    return Scaffold(
      backgroundColor:
      preferences.isDarkMode ? Color(0xff1e1e1e) : const Color(0xffefefef),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
        backgroundColor: preferences.isDarkMode
            ? Color(0xff1e1e1e)
            : const Color(0xffefefef),
      ),
      body: Column(
        children: [
          Container(
            child: Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(45, 22, 45, 22),
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
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: _logout,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: preferences.isDarkMode
                        ? Colors.grey
                        : Color(0xff273331),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(fontSize: 16, color: Color(0xFFD8D7D7)),
                  ),
                ),
                SizedBox(width: 84),
                Expanded(
                  child: SwitchListTile(
                    title: Text(
                      'Dark Mode',
                      style: TextStyle(
                        color:
                        preferences.isDarkMode ? Colors.white : Colors.black,
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
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddFriendPage(
                          onFriendAdded: _loadFriends,
                        ),
                      ),
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
                        Icon(
                          Icons.add,
                          size: 30,
                          color: Color(0xFFD8D7D7),
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Create new event/list',
                          style:
                          TextStyle(fontSize: 20, color: Color(0xFFD8D7D7)),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Color(0xffffffff),
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListTile(
                    title: Text(
                      friends[index]['name'] ?? "Unknown",
                      style: TextStyle(color: Colors.black),
                    ),
                    subtitle: Text(
                      friends[index]['number'].toString() ,  // Empty string if 'number' is null
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar:NavigationMenu(),
    );
  }
}
