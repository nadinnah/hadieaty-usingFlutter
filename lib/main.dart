import 'package:flutter/material.dart';
import 'package:hadieaty/pages/home.dart';

void main() {
  runApp(MaterialApp(title: 'Flutter Demo',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: const HomePage(),));
}
