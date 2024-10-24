import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchGiftList = TextEditingController().text;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: Text(
              'Hadieaty',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
            )),
        toolbarHeight: 50,
        backgroundColor: Colors.amber,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.person_add,
                        size: 30,
                      )),
                  ElevatedButton(
                      onPressed: () {},
                      child: const Row(
                        children: [
                          Icon(
                            Icons.add,
                            size: 30,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Create new event/list',
                            style: TextStyle(fontSize: 20),
                          )
                        ],
                      ))
                ],
              ),
            ),
            ListView(

            )
          ],

        ),
      ),

    );
  }
}
