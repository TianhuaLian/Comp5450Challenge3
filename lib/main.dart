import 'package:flutter/material.dart';
import 'start_screen.dart';
import 'components/pins/pins.dart';

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
        onStart: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BowlingGamePage()),
          );
        },
      ),
    );
  }
}

