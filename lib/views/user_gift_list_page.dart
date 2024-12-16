import 'package:flutter/material.dart';
import '../models/gift.dart';
import '../services/sqlite_service.dart';
import 'gift_details_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserGiftListPage extends StatefulWidget {
  final String eventName;
  final int eventId; // Pass eventId to fetch related gifts

  UserGiftListPage({
    required this.eventName,
    required this.eventId,
  });

  @override
  _UserGiftListPageState createState() => _UserGiftListPageState();
}

class _UserGiftListPageState extends State<UserGiftListPage> {
  final LocalDatabase _localDatabase = LocalDatabase();
  List<Gift> _giftsList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadGifts(); // Load gifts related to the event from the local database
  }

  // Load gifts related to the event from the local database
  void _loadGifts() async {
    var giftsData = await _localDatabase.getGiftsByEventId(widget.eventId);
    setState(() {
      _giftsList = giftsData.map((e) => Gift.fromMap(e)).toList();
    });
  }

  void _addGift() async {
    // Navigate to GiftDetailsPage to input gift data
    Gift? newGift = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              GiftDetailsPage(gift: Gift(
                name: '',
                category: '',
                price: 0.0,
                status: 'available',
                eventId: widget.eventId,
                syncStatus: false,
                description: '',
                imageUrl: '',
              ))),
    );

    // If the user didn't cancel the action and the gift is not null, save it
    if (newGift != null) {
      await _localDatabase.insertGift(newGift); // Insert the new gift into local DB
      _loadGifts(); // Reload the gifts after insertion
    }
  }

  Future<void> _publishGiftsToFirebase() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("User not authenticated.")));
        return;
      }

      String userId = user.uid;

      // Iterate through all gifts and sync them with Firebase
      for (var gift in _giftsList) {
        if (!gift.syncStatus) {
          var userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
          var docRef = await userDocRef.collection('events').doc(widget.eventId.toString()).collection('gifts').add({
            'name': gift.name,
            'category': gift.category,
            'price': gift.price,
            'status': gift.status,
            'createdAt': FieldValue.serverTimestamp(),
          });

          // After successful upload, mark the gift as synced
          setState(() {
            gift.syncStatus = true; // Update the gift's sync status locally
          });

          // Now update the gift in the local database
          await _localDatabase.updateTheGift(gift.id!, gift); // Ensure the gift object is updated correctly
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gifts published to Firebase!")));
    } catch (e) {
      print("Error publishing gifts: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error publishing gifts.")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateGiftStatus(Gift gift, bool value) async {
    setState(() {
      gift.status = value ? "pledged" : "available"; // Toggle the status
    });

    // Update the status in the local database
    await _localDatabase.updateTheGift(gift.id!, gift);

    try {
      // Update Firestore directly
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User not authenticated.")));
        return;
      }

      String userId = user.uid;

      // Convert the gift's ID to a String if it's an integer
      String giftIdString = gift.id.toString();

      // Update the status in the Firestore document for this specific gift
      var userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
      var giftDocRef = userDocRef
          .collection('events')
          .doc(widget.eventId.toString())
          .collection('gifts')
          .doc(giftIdString);  // Use the gift's ID (converted to String)

      await giftDocRef.update({
        'status': gift.status,  // Update the status field in Firestore
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gift status updated in Firebase!")));
    } catch (e) {
      print("Error updating gift status in Firebase: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error updating status in Firebase.")));
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xffefefef),
      appBar: AppBar(
        backgroundColor: const Color(0xffefefef),
        title: Text(
          "${widget.eventName} Gifts",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _addGift,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xff273331),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Add Gift",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _publishGiftsToFirebase,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xff273331),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    "Publish Gifts to Firebase",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _giftsList.length,
                itemBuilder: (context, index) {
                  Gift gift = _giftsList[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: gift.status == "pledged" ? Colors.red[100] : Colors.green[100],
                    child: ListTile(
                      leading: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          Gift? updatedGift = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GiftDetailsPage(gift: gift),
                            ),
                          );
                          if (updatedGift != null) {
                            setState(() {
                              _giftsList[index] = updatedGift;
                            });
                            await _localDatabase.updateTheGift(gift.id!, updatedGift);
                          }
                        },
                      ),
                      title: Text(gift.name),
                      subtitle: Text(
                        "Category: ${gift.category ?? 'N/A'}\nPrice: \$${gift.price ?? 0.0}",
                        style: TextStyle(
                          color: gift.status == "pledged" ? Colors.red : Colors.green,
                        ),
                      ),
                      trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Add the status toggle switch
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Switch(
                              value: gift.status == "pledged", // Map pledged status to true
                              onChanged: (value) {
                                _updateGiftStatus(gift, value);
                              },
                            ),
                            Text(
                              gift.status == "pledged" ? "Pledged" : "Available",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            await _localDatabase.deleteGift(gift.id!); // Delete the gift from the database
                            setState(() {
                              _giftsList.removeAt(index);
                            });
                          },
                        ),

                      ],
                    ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
