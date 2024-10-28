import 'package:flutter/material.dart';
import 'package:hadieaty/navigationMenu.dart';

import 'package:google_fonts/google_fonts.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Event List',
            style: GoogleFonts.anticDidone(
              fontSize: 35,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: const Padding(
        padding:EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sort By'),
            SizedBox(
              height: 20,
            ),
            Row(children: [])
          ],
        ),
      ),
      bottomNavigationBar: NavigationMenu(),
    );
  }
}
