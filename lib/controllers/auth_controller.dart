import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hadieaty/services/sqlite_service.dart';

class AuthenticationController {

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  LocalDatabase _localDatabase = LocalDatabase();

  Sign_in(emailAddress, password) async{
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailAddress,
          password: password
      );
      if (credential.user != null) {
        String userId = credential.user!.uid;
        await _firestore.collection('Users').doc(userId).update({
          'isOwner': true,  // Set the `isOwner` field to true
        });
        await _localDatabase.updateUserIsOwner(emailAddress,1);

          // Fetch user data from Firestore
          DocumentSnapshot userDoc = await _firestore.collection('Users').doc(
              userId).get();

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

  Sign_up(emailAddress,password, String name, String phone) async{
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      // Add user details to Firestore
      await _firestore.collection('Users').doc(credential.user!.uid).set({
        'name': name,
        'email': emailAddress,
        'phone': phone,
        'isOwner': false,
        'uid': credential.user!.uid,
      });
      await _firestore.collection('Users').doc(credential.user!.uid).set({
        'name': name,
        'email': emailAddress,
        'phone': phone,
        'isOwner': false,
        'uid': credential.user!.uid,
      });

      // Add user to local SQLite database
      await _localDatabase.insertUser({
        'name': name,
        'email': emailAddress,
        'preferences': '', // Optional field
        'password': password, // Store securely if needed
        'isOwner': 0, // Default to regular user
        'profilePic': '', // Optional field
        'number': int.parse(phone),
      });
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
