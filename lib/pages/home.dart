import 'package:flutter/material.dart';
import 'package:hadieaty/navigationMenu.dart';


List friends=["Nadin", "W", "haji", "l", "y"];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //String searchGiftList = TextEditingController().text;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color(0xffefefef),
      appBar: AppBar(
        title: const Center(
            child: Text(
              'Hadieaty',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, color: Colors.black),
            )),
      toolbarHeight: 60,
        backgroundColor:const Color(0xff4e615a),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.person_add,
                      size: 30,
                      color: Color(0xFF000000),
                    )),
                SizedBox(
                  width: 250,
                  child: OutlinedButton(
                      onPressed: () {},
                      style:
                          OutlinedButton.styleFrom(
                            backgroundColor: Color(0xff738881),
                            side: const BorderSide(width: 2.0, color: Color(
                                0xFF000000)),
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.add,
                            size: 30,
                            color: Color(0xFF0B0A0A),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Create new event/list',
                            style: TextStyle(fontSize: 20, color: Color(
                                0xFF000000)),
                          )
                        ],
                      )),
                )
              ],
            ),
          ),
        // Row(children: [
        //
        // ],), search implementation later, will make a class for it

        Expanded(child: ListView.builder(itemCount: friends.length, itemBuilder: (context,index){
          return Card(
            color:  Color(0xfffbfafa),
            margin: EdgeInsets.fromLTRB(30, 10, 30, 10), //30 margin left and right, keeping it consistent
            child: ListTile(
              contentPadding: EdgeInsets.all(15.0),
              onTap: (){},

              leading: CircleAvatar(radius: 30,backgroundColor: Colors.black,),
              title: Text(friends[index]),
              subtitle: Text('phone number'),
              trailing: Text('upcoming events:'),




            ),
          );
        },),),

        ],

      ),
    bottomNavigationBar:  NavigationMenu(),

    );
  }
}
