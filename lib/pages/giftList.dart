import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class GiftList extends StatefulWidget {
  const GiftList({super.key});

  @override
  State<GiftList> createState() => _GiftListState();
}

class _GiftListState extends State<GiftList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Gift List',
              style: GoogleFonts.anticDidone(
                fontSize: 35,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              )),
        ),
      ),
      body: Column(
        children: [

          Spacer(),
          Container(
            child: Image.asset(
              'lib/assets/giftBox.png',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),],
      ),);
  }
}
