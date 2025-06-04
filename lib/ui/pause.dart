import 'package:flutter/material.dart';

class Pause extends StatelessWidget {
  final VoidCallback onResume;

  const Pause({
    super.key,
    required this.onResume,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Game Paused',
              style: TextStyle(fontSize: 32, color: Colors.white),
            ),
            const SizedBox(height: 120),
            ElevatedButton(
              onPressed: onResume,
              child: Text(
                'Resume',
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: Colors.orangeAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
