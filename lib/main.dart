import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hadieaty/services/firebase_api.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'models/event.dart';
import 'services/shared_preference.dart';
import 'views/event_details_page.dart';
import 'views/auth/login_page.dart';
import 'views/auth/signup_page.dart';
import 'views/user_event_list_page.dart';
import 'views/home_page.dart';
import 'views/user_profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseApi().initNotification();
  runApp(
    ChangeNotifierProvider(
      create: (context) => PreferencesService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hedieaty',
      theme: ThemeData(primarySwatch: Colors.grey),
      home: const AuthenticationWrapper(),
      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/home': (context) => HomePage(),
        '/userEventList': (context) => UserEventListPage(),
        '/addEvent': (context) => AddEventPage(),
        '/userProfile': (context) => UserProfilePage(),
      },
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          User? user = snapshot.data;
          if (user != null) {
            return FirestoreUserChecker(userId: user.uid);
          }
        }

        return LoginPage(); // User is not logged in
      },
    );
  }
}

class FirestoreUserChecker extends StatelessWidget {
  final String userId;

  const FirestoreUserChecker({required this.userId, super.key});

  Future<bool> _isFirestoreUserExists(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      return userDoc.exists;
    } catch (e) {
      debugPrint("Error checking Firestore document: $e");
      return false; // Return false if there's an error
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isFirestoreUserExists(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'An error occurred.',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
                SizedBox(height: 10),
                Text('Please try again later.'),
              ],
            ),
          );
        }

        if (snapshot.data == true) {
          return HomePage(); // Navigate to HomePage if user exists in Firestore
        }

        return LoginPage(); // Navigate back to LoginPage if user doesn't exist
      },
    );
  }
}
