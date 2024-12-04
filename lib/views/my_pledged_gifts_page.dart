
// Dummy Pledged Gifts Page
import '../models/gift.dart';
import 'package:flutter/material.dart';

class PledgedGiftsPage extends StatelessWidget {
  final List<Gift> pledgedGifts;

  PledgedGiftsPage({required this.pledgedGifts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Pledged Gifts"),
      ),
      body: pledgedGifts.isEmpty
          ? Center(child: Text("You have not pledged any gifts."))
          : ListView.builder(
        itemCount: pledgedGifts.length,
        itemBuilder: (context, index) {
          var gift = pledgedGifts[index];
          return Card(
            child: ListTile(
              title: Text(gift.name),
              subtitle: Text("Category: ${gift.category}\nPrice: \$${gift.price}"),
            ),
          );
        },
      ),
    );
  }
}
