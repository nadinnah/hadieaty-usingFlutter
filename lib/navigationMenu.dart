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
      selectedItemColor: Color(0xFF99B5AA),
      backgroundColor:Color(0xff4e615a) ,
      currentIndex: _currentIndex,
      onTap: (int newIndex) {
        setState(() {
          _currentIndex = newIndex;
        });
      },
      items: const [
        BottomNavigationBarItem(label: 'Home', icon: Icon(Icons.home, color: Color(
            0xFF000000),)),
        BottomNavigationBarItem(label: 'Profile', icon: Icon(Icons.person,color: Color(
            0xFF000000),)),
      ],
    );
  }
}
