import 'package:flutter/material.dart';
import 'package:hadieaty/pages/home.dart';
import 'package:hadieaty/pages/profile.dart';
import 'package:hadieaty/pages/sharedPrefs.dart';
import 'package:provider/provider.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  int _currentIndex=0;

  final List<String> _routes = ['/home', '/profile'];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    Navigator.pushNamedAndRemoveUntil(context, _routes[index],(route) => false);
  }
  @override
  Widget build(BuildContext context) {
    var preferences = Provider.of<PreferencesService>(context);
    return BottomNavigationBar(
      selectedItemColor: Color(0xFFF6F6F6) ,
      unselectedItemColor: Color(0xFFF6F6F6) ,
      backgroundColor: preferences.isDarkMode ?Colors.grey: Color(0xff273331) ,
      currentIndex: _currentIndex,
      onTap: _onTabTapped,
      items: const [
        BottomNavigationBarItem(label: 'Home', icon: Icon(Icons.home, color: Color(
            0xFFD8D7D7),)),
        BottomNavigationBarItem(label: 'Profile', icon: Icon(Icons.person,color: Color(
            0xFFD8D7D7),)),
      ],
    );
  }
}
