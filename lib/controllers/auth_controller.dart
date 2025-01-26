import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hadieaty/services/sqlite_service.dart';

class AuthenticationController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  LocalDatabase localDb = LocalDatabase();

  //Signs in a user with email and password, updates FCM token, and sets user as owner.
  Future<bool> Sign_in(String emailAddress, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );

      if (credential.user != null) {
        String userId = credential.user!.uid;

        await firestore.collection('Users').doc(userId).update({
          'isOwner': true,
        });

        await localDb.updateUserIsOwner(emailAddress, 1);

        String? fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await firestore.collection('Users').doc(userId).update({
            'fcmToken': fcmToken,
          });
        }

        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided for that user.');
      }
      throw Exception('Failed to sign in.');
    }
  }

  //Signs up a new user with email, password, name, and phone, and stores their data in Firestore and SQLite.
  Future<bool> Sign_up(String emailAddress, String password, String name, String phone) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );

      String? fcmToken = await FirebaseMessaging.instance.getToken();

      await firestore.collection('Users').doc(credential.user!.uid).set({
        'name': name,
        'email': emailAddress,
        'phone': phone,
        'isOwner': false,
        'uid': credential.user!.uid,
        'fcmToken': fcmToken ?? '',
      });

      await localDb.insertUser({
        'name': name,
        'email': emailAddress,
        'preferences': '',
        'password': password,
        'isOwner': 0,
        'profilePic': '',
        'number': int.parse(phone),
      });

      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('The account already exists for that email.');
      }
      throw Exception('Failed to sign up.');
    } catch (e) {
      throw Exception('An error occurred during sign-up.');
    }
  }

  //Signs out the currently logged-in user.
  Future<void> Sign_out() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      throw Exception('Failed to sign out.');
    }
  }
}
