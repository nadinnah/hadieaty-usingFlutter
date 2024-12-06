import 'package:flutter/material.dart';

import '../models/gift.dart';
import '../services/sqlite_service.dart';
import 'gift_details_page.dart';

class GiftListPage extends StatefulWidget {
  final String eventName;
  final bool isOwnEvent;
  final int eventId;  // Pass eventId to fetch related gifts

  GiftListPage({required this.eventName, required this.isOwnEvent, required this.eventId});

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  final LocalDatabase _localDatabase = LocalDatabase();
  List<Gift> _giftsList = [];

  @override
  void initState() {
    super.initState();
    _loadGifts();  // Load gifts related to the event from the local database
  }

  // Load gifts related to the event from the local database
  void _loadGifts() async {
    var giftsData = await _localDatabase.getGiftsByEventId(widget.eventId);
    setState(() {
      _giftsList = giftsData.map((e) => Gift.fromMap(e)).toList();  // Include the id from the map
    });
  }

  // Pledge a gift (change status)
  void _pledgeGift(Gift gift) async {
    if (gift.status != 'pledged') {
      setState(() {
        gift.status = 'pledged';
      });
      await _localDatabase.updateGift(gift.id!, gift);  // Update the gift status in the database
      print("Gift '${gift.name}' pledged");
    } else {
      print("Gift is already pledged!");
    }
  }

  // Handle edit and delete buttons for gifts
  Widget? privilege(Gift gift, int index) {
    if (widget.isOwnEvent && gift.status != "pledged") {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Edit Gift
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              Gift? updatedGift = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GiftDetailsPage(
                    gift: gift,
                    isOwnEvent: widget.isOwnEvent,
                  ),
                ),
              );
              if (updatedGift != null) {
                setState(() {
                  _giftsList[index] = updatedGift;
                });
                await _localDatabase.updateGift(gift.id!, updatedGift); // Update the gift in the database
              }
            },
          ),
          // Delete Gift
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              await _localDatabase.deleteGift(gift.id!); // Delete the gift from the database
              setState(() {
                _giftsList.removeAt(index);
              });
            },
          ),
        ],
      );
    } else if (widget.isOwnEvent && gift.status == "pledged") {
      return Row(mainAxisSize: MainAxisSize.min, children: [
        // Only edit when the gift is pledged
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () async {
            Gift? updatedGift = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GiftDetailsPage(
                  gift: gift,
                  isOwnEvent: widget.isOwnEvent,
                ),
              ),
            );
            if (updatedGift != null) {
              setState(() {
                _giftsList[index] = updatedGift;
              });
              await _localDatabase.updateGift(gift.id!,updatedGift); // Update the gift in the database
            }
          },
        ),
      ]);
    } else if (!widget.isOwnEvent && gift.status != "pledged") {
      return ElevatedButton(
        onPressed: () => _pledgeGift(gift),
        child: Text("Pledge"),
      );
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.eventName} Gifts"),
      ),
      body: ListView.builder(
        itemCount: _giftsList.length,
        itemBuilder: (context, index) {
          Gift gift = _giftsList[index];
          return Card(
            color: gift.status == "pledged" ? Colors.red[100] : Colors.green[100],
            child: ListTile(
              title: Text(gift.name),
              subtitle: Text(
                "Category: ${gift.category}\nPrice: \$${gift.price}\nStatus: ${gift.status}",
                style: TextStyle(
                  color: gift.status == "pledged" ? Colors.red : Colors.green,
                ),
              ),
              trailing: privilege(gift, index),
            ),
          );
        },
      ),
    );
  }
}
