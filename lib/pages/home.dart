import 'package:flutter/material.dart';
import 'package:hadieaty/navigationMenu.dart';
import 'package:google_fonts/google_fonts.dart';


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
        title: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xff273331), width: 5,),
                   borderRadius: BorderRadius.all(Radius.circular(15)),

              ) ,
              child: Padding(
                padding: EdgeInsets.fromLTRB(45,22,45,22),
                child: Text(
                  'HADIEATY',
                  style: GoogleFonts.anticDidone(
                    fontSize: 35,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),

                ),
              ),
            )),
      toolbarHeight: 100,
        backgroundColor:const Color(0xffefefef),
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
                            backgroundColor: Color(0xff273331),
                            //side: const BorderSide(width: 1.0, color: Color(
                              //  0xFF000000)),
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.add,
                            size: 30,
                            color: Color(0xFFD8D7D7),
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Create new event/list',
                            style: TextStyle(fontSize: 20, color: Color(
                                0xFFD8D7D7)),
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
