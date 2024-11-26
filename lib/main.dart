import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hadieaty/pages/addFriend.dart';
import 'package:hadieaty/pages/eventList.dart';
import 'package:hadieaty/pages/giftDetail.dart';
import 'package:hadieaty/pages/giftList.dart';
import 'package:hadieaty/pages/home.dart';
import 'package:hadieaty/pages/login.dart';
import 'package:hadieaty/pages/profile.dart';
import 'package:hadieaty/pages/register.dart';
import 'package:hadieaty/pages/sharedPrefs.dart'; // Import PreferencesService

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => PreferencesService(), // Provide PreferencesService
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final preferencesService = Provider.of<PreferencesService>(context);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        brightness: preferencesService.isDarkMode ? Brightness.dark : Brightness.light,
      ),
      initialRoute: '/login', // Set initial route
      routes: {
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
        '/giftDetails': (context) => const GiftDetailPage(),
        '/giftList': (context) => const GiftList(),
        '/login': (context) => const LoginPage(),
        '/eventList': (context) => const EventListPage(),
        '/addFriend': (context) => AddFriendPage(),
        '/register': (context) => RegisterPage(),
      },
    );
  }
}
