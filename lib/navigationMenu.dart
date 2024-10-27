import 'package:flutter/material.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  int _currentIndex=0;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: Color(0xFFF6F6F6),
      unselectedItemColor: Color(0xFFF6F6F6) ,
      backgroundColor:Color(0xff273331) ,
      currentIndex: _currentIndex,
      onTap: (int newIndex) {
        setState(() {
          _currentIndex = newIndex;
        });
      },
      items: const [
        BottomNavigationBarItem(label: 'Home', icon: Icon(Icons.home, color: Color(
            0xFFD8D7D7),)),
        BottomNavigationBarItem(label: 'Profile', icon: Icon(Icons.person,color: Color(
            0xFFD8D7D7),)),
      ],
    );
  }
}
