import 'package:flutter/material.dart';
import 'package:hadieaty/navigationMenu.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sharedPrefs.dart';
import 'package:provider/provider.dart';
import 'package:hadieaty/Localdb/localDb.dart';

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
    // Assuming you have the current user's ID, replace it with actual user ID
    int currentUserId = 1; // Example: current user ID is 1
    var nonAdminUsers = await _localDatabase.getNonAdminUsers();
    var userFriends = await _localDatabase.getFriends(currentUserId);

    // Filter out the non-admin friends
    setState(() {
      friends = userFriends;
    });
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
          // Dark Mode Toggle using SwitchListTile
          SwitchListTile(
            title: Text(
              'Dark Mode',
              style: TextStyle(
                color: preferences.isDarkMode ? Colors.white : Colors.black,
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

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/addFriend');
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
                  color: Color(0xfffbfafa),
                  margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(15.0),
                    onTap: () {},
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.black,
                      backgroundImage: friends[index]['profilePic'] != null
                          ? NetworkImage(friends[index]['profilePic'])
                          : null,
                    ),
                    title: Text(
                      friends[index]['name'],
                      style: TextStyle(
                          color: preferences.isDarkMode
                              ? Colors.black
                              : Colors.black),
                    ),
                    subtitle: Text(
                      'Phone number: ${friends[index]['number']}',
                      style: TextStyle(
                          color: preferences.isDarkMode
                              ? Colors.black
                              : Colors.black),
                    ),
                    trailing: Text(
                      'Upcoming events:',
                      style: TextStyle(
                          color: preferences.isDarkMode
                              ? Colors.black
                              : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationMenu(),
    );
  }
}
