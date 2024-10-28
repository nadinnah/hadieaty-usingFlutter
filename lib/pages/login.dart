import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffefefef),
      appBar: AppBar(
        title: Center(
          child: Text(
            'HADIEATY',
            style: GoogleFonts.anticDidone(
              fontSize: 55,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ),
        toolbarHeight: 100,
        backgroundColor: const Color(0xffefefef),
      ),
    body: Column(
      children: [
        Spacer(),
        Container(
          child: Image.asset(
          'lib/assets/giftBox.png', // Replace with your image URL.
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          ),
        ),
      ],
    ));
  }
}
