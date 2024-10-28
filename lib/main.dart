import 'package:flutter/material.dart';
import 'package:hadieaty/pages/eventList.dart';
import 'package:hadieaty/pages/giftDetail.dart';
import 'package:hadieaty/pages/home.dart';
import 'package:hadieaty/pages/login.dart';
import 'package:hadieaty/pages/login.dart';
import 'package:hadieaty/pages/profile.dart';


void main() {
  runApp(MaterialApp(title: 'Flutter Demo',
    theme: ThemeData(
      useMaterial3: true,
    ),
    home: const GiftDetailPage(),));
}
