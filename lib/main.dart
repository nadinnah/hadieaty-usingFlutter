import 'package:flutter/material.dart';
import 'package:hadieaty/views/add_event.dart';
import 'package:hadieaty/views/auth/login_page.dart';
import 'package:hadieaty/views/auth/signup_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hadieaty/views/event_list_page.dart';
import 'package:hadieaty/views/home_page.dart';
import 'package:hadieaty/views/user_profile_page.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/shared_preference.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ChangeNotifierProvider(
      create: (context) => PreferencesService(), child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hedieaty',
      theme: ThemeData(
        primarySwatch: Colors.grey

      ),
      home: AuthenticationWrapper(),
      routes: {
        '/login':(context)=> LoginPage(),
        '/signup':(context)=> SignupPage(),
        '/home':(context)=> HomePage(),
        '/eventList': (context)=> EventListPage(friendName: '', isOwnEvents: true, events: [],),
        '/addEvent': (context) => AddEventPage(),
        '/userProfile': (context)=> UserProfilePage(),
      },
      );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return HomePage(); // User is logged in
        }
        return LoginPage(); // User is not logged in
      },
    );
  }
}