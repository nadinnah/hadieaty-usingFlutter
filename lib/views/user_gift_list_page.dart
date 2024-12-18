import 'package:flutter/material.dart';
import '../controllers/gift_controller.dart';
import '../models/gift.dart';
import '../services/sqlite_service.dart';
import 'gift_details_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserGiftListPage extends StatefulWidget {
  final String eventName;
  final String firebaseEventId; // Firestore Event ID

  UserGiftListPage({
    required this.eventName,
    required this.firebaseEventId,
  });

  @override
  _UserGiftListPageState createState() => _UserGiftListPageState();
}

class _UserGiftListPageState extends State<UserGiftListPage> {
  final LocalDatabase _localDatabase = LocalDatabase();
  final GiftController _giftController = GiftController(localdb: LocalDatabase());
  List<Gift> _giftsList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadGifts();
  }

  // Simulating the logged-in user's ID for this example
  final String currentUserId = "USER_FIREBASE_ID"; // Replace with actual Firebase UID

  void _publishGift(Gift gift) async {
    try {
      await _giftController.syncGiftToFirebase(gift);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${gift.name} published successfully!")),
      );
      _loadGifts(); // Reload gifts to reflect changes
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error publishing ${gift.name}: $e")),
      );
    }
  }

  // Load gifts from the local database
  void _loadGifts() async {
    setState(() => _isLoading = true);
    var giftsData = await _localDatabase.getGiftsByEventId(widget.firebaseEventId);
    setState(() {
      _giftsList = giftsData.map((e) => Gift.fromMap(e)).toList();
      _isLoading = false;
    });
  }

  // Add a new gift
  void _addGift() async {
    Gift? newGift = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiftDetailsPage(
          gift: Gift(
            name: '',
            category: '',
            price: 0.0,
            status: 'Available',
            eventId: widget.firebaseEventId,
            syncStatus: "Unsynced",
            description: '',
            imageUrl: '',
          ),
        ),
      ),
    );

    if (newGift != null) {
      await _localDatabase.insertGift(newGift);
      _loadGifts();
    }
  }


  // Delete a gift locally and from Firestore if synced
  void _deleteGift(Gift gift) async {
    try {
      await _giftController.deleteGift(gift);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${gift.name} deleted successfully!")),
      );
      _loadGifts(); // Reload gifts
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting ${gift.name}: $e")),
      );
    }
  }

  // Edit a gift locally
  void _editGift(Gift gift) async {
    Gift? updatedGift = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GiftDetailsPage(gift: gift)),
    );

    if (updatedGift != null) {
      await _localDatabase.updateGift(updatedGift);
      _loadGifts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffefefef),
      appBar: AppBar(
        backgroundColor: const Color(0xffefefef),
        title: Text(
          "${widget.eventName} Gifts",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Add Gift Button
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(
              onPressed: _addGift,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff273331),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              child: const Text(
                "Add Gift",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
            child: ListView.builder(
              itemCount: _giftsList.length,
              itemBuilder: (context, index) {
                var gift = _giftsList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  elevation: 3,
                  child: ListTile(
                    leading: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.green),
                      onPressed: () => _editGift(gift),
                    ),
                    title: Text(
                      gift.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Category: ${gift.category}\nPrice: \$${gift.price}\nStatus: ${gift.status}",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Publish Button
                        if (gift.syncStatus == "Unsynced")
                          ElevatedButton(
                            onPressed: () => _publishGift(gift),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                            child: const Text("Publish"),
                          ),

                        // Delete Button
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteGift(gift),
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
    );
  }
}
