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
      backgroundColor: const Color(0xff000000),
      appBar: AppBar(
        title: Center(
          child: Text(
            'HADIEATY',
            style: GoogleFonts.anticDidone(
              fontSize: 35,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ),
        toolbarHeight: 100,
        backgroundColor: const Color(0xffefefef),
      ),
    );
  }
}
