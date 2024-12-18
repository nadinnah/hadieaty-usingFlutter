import 'package:flutter/material.dart';
import '../models/gift.dart';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      var pledgedGifts = await _firestoreService.getPledgedGiftsByUser(currentUserId);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Pledged Gifts"),
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
          ? const Center(child: Text("You have not pledged any gifts."))
          : ListView.builder(
        itemCount: _pledgedGifts.length,
        itemBuilder: (context, index) {
          var gift = _pledgedGifts[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            elevation: 3,
            child: ListTile(
              title: Text(
                gift.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "Category: ${gift.category ?? 'N/A'}\nPrice: \$${gift.price ?? 0.0}\nStatus: ${gift.status}",
              ),
            ),
          );
        },
      ),
    );
  }
}
