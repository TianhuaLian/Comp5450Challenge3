import 'package:flutter/material.dart';
import 'start_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ten-Pin Bowling',
      home: StartScreen(
        onStart: () {
          // Navigate to main screen from here.
          // Navigator.push(context, MaterialPageRoute(builder: (_) => GameScreen()));
        },
      ),
    );
  }
}
