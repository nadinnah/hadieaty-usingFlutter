import 'package:flutter/material.dart';
import '../models/gift.dart';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/shared_preference.dart';

class PledgedGiftsPage extends StatefulWidget {
  @override
  _PledgedGiftsPageState createState() => _PledgedGiftsPageState();
}

class _PledgedGiftsPageState extends State<PledgedGiftsPage> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Gift> _pledgedGifts = [];
  bool _isLoading = true;

  // Get the current logged-in user's UID
  String get currentUserId => FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _fetchPledgedGifts();
  }

  Future<void> _fetchPledgedGifts() async {
    setState(() => _isLoading = true);

    try {
      // Fetch pledged gifts from Firestore
      var pledgedGifts = await _firestoreService.getPledgedGiftsByUser(
          currentUserId);
      setState(() {
        _pledgedGifts = pledgedGifts;
      });
    } catch (e) {
      print("Error fetching pledged gifts: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching pledged gifts: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var preferences = Provider.of<PreferencesService>(context);
    var isDarkMode = preferences.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xff1e1e1e) : const Color(0xffefefef),
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xff1e1e1e) : const Color(0xffefefef),
        title: Text(
          "My Pledged Gifts",
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchPledgedGifts, // Refresh pledged gifts
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pledgedGifts.isEmpty
          ? Center(
        child: Text(
          "You have not pledged any gifts.",
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
      )
          : ListView.builder(
        itemCount: _pledgedGifts.length,
        itemBuilder: (context, index) {
          var gift = _pledgedGifts[index];
          return Card(
            color: isDarkMode ? const Color(0xffcfcfcf) : Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            elevation: 3,
            child: ListTile(
              title: Text(
                gift.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.black : Colors.black,
                ),
              ),
              subtitle: Text(
                "Category: ${gift.category ?? 'N/A'}\n"
                    "Price: \$${gift.price ?? 0.0}\n"
                    "Status: ${gift.status}",
                style: TextStyle(color: isDarkMode ? Colors.black54 : Colors.black),
              ),
            ),
          );
        },
      ),
    );
  }
}
