import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hadieaty/services/sqlite_service.dart';

class AuthenticationController {

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  LocalDatabase localDb = LocalDatabase();

  Sign_in(emailAddress, password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );

      if (credential.user != null) {
        String userId = credential.user!.uid;

        // Update `isOwner` in Firestore
        await firestore.collection('Users').doc(userId).update({
          'isOwner': true,
        });

        // Update `isOwner` in local SQLite database
        await localDb.updateUserIsOwner(emailAddress, 1);

        // Fetch and update FCM token
        String? fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await firestore.collection('Users').doc(userId).update({
            'fcmToken': fcmToken,
          });
          print('FCM token updated for user: $userId');
        } else {
          print('Failed to retrieve FCM token.');
        }



        return true;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
      return false;
    }
  }

  Sign_up(emailAddress, password, String name, String phone) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );

      String? fcmToken = await FirebaseMessaging.instance.getToken();

      // Create a new user document in Firestore
      await firestore.collection('Users').doc(credential.user!.uid).set({
        'name': name,
        'email': emailAddress,
        'phone': phone,
        'isOwner': false,
        'uid': credential.user!.uid,
        'fcmToken': fcmToken ?? '', // Initialize with FCM token if available
      });

      // Add user to local SQLite database
      await localDb.insertUser({
        'name': name,
        'email': emailAddress,
        'preferences': '', // Optional field
        'password': password, // Store securely if needed
        'isOwner': 0, // Default to regular user
        'profilePic': '', // Optional field
        'number': int.parse(phone),
      });

      print('User signed up successfully with FCM token: $fcmToken');
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }


  Sign_out() async {
        await FirebaseAuth.instance.signOut();
  }
}
