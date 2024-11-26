import 'package:flutter/material.dart';
import 'package:hadieaty/navigationMenu.dart';
import 'sharedPrefs.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    var preferences = Provider.of<PreferencesService>(context);
    return Scaffold(
        backgroundColor:
        preferences.isDarkMode ?  Color(0xff1e1e1e) : const Color(0xffefefef),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: preferences.isDarkMode ?  Color(0xff1e1e1e) : const Color(0xffefefef),
        title: const Text('Your Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Center(child: CircleAvatar(backgroundImage: AssetImage('lib/assets/black-and-white-gift-box.jpg',),radius: 100,))
          ],
        ),
      ),
      bottomNavigationBar: NavigationMenu(),
    );
  }
}
