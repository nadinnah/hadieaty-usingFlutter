import 'package:flutter/material.dart';
import 'sharedPrefs.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class GiftDetailPage extends StatefulWidget {
  const GiftDetailPage({super.key});

  @override
  State<GiftDetailPage> createState() => _GiftDetailPageState();
}

class _GiftDetailPageState extends State<GiftDetailPage> {
  GlobalKey<FormState> myKey = GlobalKey();

  List giftCategories = ['Pick a Category', 'Birthday', 'Eid', 'Christmas'];
  String selectedCategory = 'Pick a Category';

  TextEditingController giftName = TextEditingController();
  TextEditingController giftDescription = TextEditingController();
  TextEditingController giftCategory = TextEditingController();
  TextEditingController giftPrice = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var preferences = Provider.of<PreferencesService>(context);
    return Scaffold(
      backgroundColor:  preferences.isDarkMode ?  Color(0xff1e1e1e) : const Color(0xffefefef),
      appBar: AppBar(
        title: Center(
          child: Text('Gift Details Form',
              style: GoogleFonts.anticDidone(
                fontSize: 35,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              )),
        ),
      ),
      body: Column(
        children: [
          Form(
            key: myKey,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 40, 30, 0),
              child: Column(children: [
                TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Gift Name:',
                      border: OutlineInputBorder(),
                      hintText: 'Enter gift name',
                      helperText: 'The gift name should be here'),
                  controller: giftName,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return ('Gift Name can not be empty');
                    } else {
                      return null;
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                  child: TextFormField(
                    decoration: InputDecoration(
                        labelText: 'Gift Descrption:',
                        border: OutlineInputBorder(),
                        hintText: 'Enter gift description',
                        helperText: 'The gift Description should be here'),
                    controller: giftDescription,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return ('Gift Description can not be empty');
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                  child: DropdownButtonFormField(
                      value: selectedCategory,
                      items: giftCategories.map((x) {
                        return DropdownMenuItem(
                          value: x,
                          child: Text(x),
                        );
                      }).toList(),
                      onChanged: (var x) {
                        setState(() {
                          selectedCategory = x as String;
                        });
                      }),
                )
              ]),
            ),
          ),

          //DropdownButtonFormField(items: items, onChanged: onChanged)
          Spacer(),
          Container(
            child: Image.asset(
              'lib/assets/giftBox.png',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
