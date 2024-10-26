import 'package:flutter/material.dart';
import 'package:hadieaty/navigationMenu.dart';



class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event List:'),),
      body: Column(
        children: [
          Text('Sort By'),
          Row(
            children: [
              ElevatedButton(style: ButtonStyle(
          shape:WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        side: BorderSide(color: Colors.red)
    )
    )
    ),onPressed: (){}, child: Icon(Icons.percent))
            ]
          )
        ],
      ),
      bottomNavigationBar: NavigationMenu(),
    );
  }
}
