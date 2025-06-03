import 'package:flutter/material.dart';

class GameOver extends StatelessWidget {
  final VoidCallback onReplay;
  final VoidCallback onScoreboard;

  const GameOver({
    super.key,
    required this.onReplay,
    required this.onScoreboard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54, // translucent background
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Game Over',
              style: TextStyle(fontSize: 32, color: Colors.white),
            ),
            const SizedBox(height: 120),
            ElevatedButton(
              onPressed: onReplay, //Replay
              child: Text(
                'Replay',
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: Colors.orangeAccent,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onScoreboard, //Scoreboard
              child: Text(
                'Scoreboard',
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
