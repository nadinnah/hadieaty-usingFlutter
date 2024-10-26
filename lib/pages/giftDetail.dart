import 'package:flutter/material.dart';
import 'package:hadieaty/navigationMenu.dart';


class GiftDetailPage extends StatefulWidget {
  const GiftDetailPage({super.key});

  @override
  State<GiftDetailPage> createState() => _GiftDetailPageState();
}

class _GiftDetailPageState extends State<GiftDetailPage> {
  GlobalKey<FormState> myKey=GlobalKey();

  TextEditingController giftName= TextEditingController();
  TextEditingController giftDescription= TextEditingController();
  TextEditingController giftCategory= TextEditingController();
  TextEditingController giftPrice= TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gift Details Form:', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),),
        toolbarHeight: 60,
        backgroundColor:const Color(0xff4e615a),
      ),

      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Form(key:myKey,child: Column(children: [
          Text('Add Gift Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
          SizedBox(height: 40,),
          TextFormField(
            decoration: InputDecoration(labelText: 'Gift Name:',border: OutlineInputBorder(),
                hintText: 'Enter gift name',
              helperText: 'The gift name should be here'
           ),
            controller: giftName,
            validator: (value){
              if(value==null||value.isEmpty){
                return ('Gift Name can not be empty');
              }else{
                return null;
              }
            },
          ), SizedBox(
            height: 20,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Gift Descrption:',border: OutlineInputBorder(),hintText: 'Enter gift description',
                helperText: 'The gift Description should be here'
            ),
            controller: giftDescription,
            validator: (value){
              if(value==null||value.isEmpty){
                return ('Gift Description can not be empty');
              }else{
                return null;
              }
            },
          ),SizedBox(
            height: 20,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Gift Descrption:',border: OutlineInputBorder(),hintText: 'Enter gift description',
                helperText: 'The gift Description should be here'
            ),
            controller: giftDescription,
            validator: (value){
              if(value==null||value.isEmpty){
                return ('Gift Description can not be empty');
              }else{
                return null;
              }
            },
          ),
        ],)),
      ),
        bottomNavigationBar: NavigationMenu()
    );
  }
}
