import 'package:cloud_firestore/cloud_firestore.dart';

class PhotoController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch URLs from Firestore
  Future<Map<String, String>> fetchPhotoURLs() async {
    try {
      // Fetch the specific document containing URLs
      var docSnapshot = await _firestore.collection('Photo').doc('PNUFME1MeUm2wLsSd9Vp').get();

      if (docSnapshot.exists) {
        var data = docSnapshot.data() as Map<String, dynamic>;
        return {
          'giftURL': data['giftURL'] ?? '',
          'profileURL': data['profileURL'] ?? '',
        };
      } else {
        print('Document does not exist');
        return {'giftURL': '', 'profileURL': ''};
      }
    } catch (e) {
      print('Error fetching photo URLs: $e');
      return {'giftURL': '', 'profileURL': ''};
    }
  }
}
