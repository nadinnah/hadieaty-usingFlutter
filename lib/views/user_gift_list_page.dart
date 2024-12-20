import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/gift_controller.dart';
import '../models/gift.dart';
import '../services/sqlite_service.dart';
import '../services/shared_preference.dart';
import 'gift_details_page.dart';

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
  String _sortOption = 'Name'; // Default sorting option

  @override
  void initState() {
    super.initState();
    _loadGifts();
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

  // Add gift functionality
  void _addGift() async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid; // Get the current user's ID

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
            createdBy: currentUserId,
          ),
        ),
      ),
    );

    if (newGift != null) {
      await _localDatabase.insertGift(newGift); // Save to SQLite
      _loadGifts(); // Reload gifts
    }
  }

  // Sort gifts
  void _sortGifts(String option) {
    setState(() {
      _sortOption = option;
      switch (option) {
        case 'Name':
          _giftsList.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'Status':
          const statusOrder = {'Available': 0, 'Reserved': 1, 'Gifted': 2, 'Pledged': 3};
          _giftsList.sort((a, b) =>
              statusOrder[a.status]!.compareTo(statusOrder[b.status]!));
          break;
      }
    });
  }

  // Publish gift functionality
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

  // Delete a gift functionality
  void _deleteGift(Gift gift) async {
    if (gift.status == "Pledged") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${gift.name} cannot be deleted as it is pledged.")),
      );
      return;
    }

    try {
      await _giftController.deleteGift(gift);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${gift.name} deleted successfully!")),
      );
      _loadGifts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting ${gift.name}: $e")),
      );
    }
  }

  // Edit a gift functionality
  void _editGift(Gift gift) async {
    if (gift.status == "Pledged") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${gift.name} cannot be edited as it is pledged.")),
      );
      return;
    }

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
    var preferences = Provider.of<PreferencesService>(context);
    var isDarkMode = preferences.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xff1e1e1e) : const Color(0xffefefef),
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed:(){
              setState(() {

              });
            },
          ),
        ],
        backgroundColor: isDarkMode ? const Color(0xff1e1e1e) : const Color(0xffefefef),
        title: Text(
          "${widget.eventName} Gifts",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _addGift,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? Colors.grey : const Color(0xff273331),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Add New Gift",
                    style: TextStyle(fontSize: 18, color: Colors.white ),
                  ),
                ),
                DropdownButton<String>(
                  value: _sortOption,
                  onChanged: (value) {
                    if (value != null) _sortGifts(value);
                  },
                  items: const [
                    DropdownMenuItem(value: 'Name', child: Text('Sort by Name')),
                    DropdownMenuItem(value: 'Status', child: Text('Sort by Status')),
                  ],
                  underline: Container(),
                  style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white : Colors.black),
                ),
              ],
            ),
          ),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
            child: ListView.builder(
              itemCount: _giftsList.length,
              itemBuilder: (context, index) {
                var gift = _giftsList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  elevation: 3,
                  color: isDarkMode ? const Color(0xff2a2a2a) : Colors.white,
                  child: ListTile(
                    leading: IconButton(
                      icon: Icon(Icons.edit, color: isDarkMode ? Colors.white : Colors.green),
                      onPressed: gift.status != "Pledged" ? () => _editGift(gift) : null,
                    ),
                    title: Text(
                      gift.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      "Category: ${gift.category}\nPrice: \$${gift.price}\nStatus: ${gift.status}",
                      style: TextStyle(color: isDarkMode ? Colors.grey : Colors.black),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (gift.syncStatus == "Unsynced")
                          ElevatedButton(
                            onPressed: () => _publishGift(gift),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDarkMode ? Colors.grey : const Color(0xff4CC1FF),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Publish"),
                          ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: gift.status != "Pledged" ? () => _deleteGift(gift) : null,
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
