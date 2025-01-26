import 'package:cloud_firestore/cloud_firestore.dart';

class PhotoController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Fetches the photo URLs for gifts and profiles from Firestore.
  Future<Map<String, String>> fetchPhotoURLs() async {
    try {
      var docSnapshot = await _firestore.collection('Photo').doc('PNUFME1MeUm2wLsSd9Vp').get();

      if (docSnapshot.exists) {
        var data = docSnapshot.data() as Map<String, dynamic>;
        return {
          'giftURL': data['giftURL'] ?? '',
          'profileURL': data['profileURL'] ?? '',
        };
      } else {
        throw Exception('Photo document does not exist.');
      }
    } catch (e) {
      throw Exception('Error fetching photo URLs: $e');
    }
  }
}
