import 'package:flutter/material.dart';
import '../models/gift.dart';
import 'gift_details_page.dart';

class GiftListPage extends StatefulWidget {
  final String eventName;
  final bool isOwnEvent;

  GiftListPage({required this.eventName, required this.isOwnEvent});

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  List<Gift> _giftsList = [
    Gift(
        name: "Smartphone",
        description: "A brand-new smartphone",
        category: "Electronics",
        price: 699.99,
        imageUrl: "",
        status: "available"),
    Gift(
        name: "Book",
        description: "A thriller novel",
        category: "Books",
        price: 19.99,
        imageUrl: "",
        status: "pledged"),
  ];

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
              trailing: widget.isOwnEvent && gift.status != "pledged"
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _giftsList.removeAt(index);
                      });
                    },
                  ),
                ],
              )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
