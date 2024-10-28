import 'package:flutter/material.dart';
import 'package:hadieaty/navigationMenu.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
