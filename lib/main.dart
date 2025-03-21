import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const BriteApp());
}

class BriteApp extends StatelessWidget {
  const BriteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brite - WLED Control',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const HomeScreen(),
    );
  }
}