import 'package:flutter/material.dart';
import 'package:leaf/home.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Leaf Disease Detection',
      home: const Home(),
      theme: ThemeData(
        primaryColor: Colors.lightGreen[700],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
