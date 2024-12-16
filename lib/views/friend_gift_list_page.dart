import 'package:flutter/material.dart';
import '../models/gift.dart';
import '../services/sqlite_service.dart';
import 'gift_details_page.dart';

class FriendGiftListPage extends StatefulWidget {
  final String eventName;
  final int eventId; // Pass eventId to fetch related gifts

  FriendGiftListPage({
    required this.eventName,
    required this.eventId,
  });

  @override
  _FriendGiftListPageState createState() => _FriendGiftListPageState();
}

class _FriendGiftListPageState extends State<FriendGiftListPage> {
  final LocalDatabase _localDatabase = LocalDatabase();
  List<Gift> _giftsList = [];

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

  // Pledge a gift (change status)
  void _pledgeGift(Gift gift) async {
    if (gift.status != 'pledged') {
      setState(() {
        gift.status = 'pledged';
      });
      await _localDatabase.updateTheGift(gift.id!, gift); // Update the gift status in the database
      print("Gift '${gift.name}' pledged");
    } else {
      print("Gift is already pledged!");
    }
  }

  // Display pledge button for non-pledged gifts
  Widget _privilege(Gift gift) {
    if (gift.status != 'pledged') {
      return ElevatedButton(
        onPressed: () => _pledgeGift(gift),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Color(0xff273331),
        ),
        child: Text("Pledge"),
      );
    }
    return SizedBox.shrink();  // Return an empty box when no button is needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xffefefef),
      appBar: AppBar(
        backgroundColor: Color(0xffefefef),
        title: Text(
          "${widget.eventName} Gifts",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _giftsList.length,
                itemBuilder: (context, index) {
                  Gift gift = _giftsList[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    color: gift.status == "pledged" ? Colors.red[100] : Colors.green[100],
                    child: ListTile(
                      title: Text(gift.name),
                      subtitle: Text(
                        "Category: ${gift.category}\nPrice: \$${gift.price}\nStatus: ${gift.status}",
                        style: TextStyle(
                          color: gift.status == "pledged" ? Colors.red : Colors.green,
                        ),
                      ),
                      trailing: _privilege(gift),
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
